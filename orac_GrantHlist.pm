package orac_GrantHlist;

################################################################################
# Copyright (c) 1998,1999 Andy Duncan
#
# You may distribute under the terms of either the GNU General Public License
# or the Artistic License, as specified in the Perl README file, with the
# exception that it cannot be placed on a CD-ROM or similar media for commercial
# distribution without the prior approval of the author.
#
# This code is provided with no warranty of any kind, and is used entirely at
# your own risk.
#
# This code was written by the author as a private individual, and is in no way
# endorsed or warrantied by any other company
#
# Support questions and suggestions can be directed to andy_j_duncan@yahoo.com
#
################################################################################

use Tk;
use Cwd;
require Tk::HList;
use DBI;
use Tk::DialogBox;
sub grant_orac {
   $local_top = $_[0];
   $local_dbh = $_[1];
   $this_title = "Orac Grants SQL $v_db";
   $dialog = $local_top->DialogBox( -title => $this_title,
                                       -buttons => [ "Dismiss" ]);
   my(@layout_menu_bar) = qw/-side top -padx 5 -expand yes -fill both/;
   $menu_bar = $dialog->Frame(width => 100)->pack(@layout_menu_bar);
   $menu_bar->Label(  
      -text        => 'Grants',
      -font        => '-adobe-helvetica-bold-r-narrow--18-120-75-75-p-46-*-1',
      -borderwidth => 2,
      -relief      => 'flat',
      )->pack(-side => 'right', -anchor => 'e');
   my $help_mb = $menu_bar->Menubutton(text        => 'Help',
                                       relief      => 'raised',
                                       borderwidth => 2,
                                        )->pack('-side' => 'left',
                                                '-padx' => 2,
                                               );
   
   $help_mb->command(-label         => 'Help on Screen',
      -underline => 0,
      -command   => sub { $dialog->Busy;
                          orac_UnixHelp::help_orac($dialog,
                                                   'orac_GrantHlist',
                                                   'grant_orac','1');
                          $dialog->Unbusy } );
   
   $hlist = $dialog->Scrolled('HList',
                           drawbranch   => 1,
                           separator    => '.',
                           indent       => 50,
                           width        => 70,
                           height       => 20,
                           background   => $main::this_is_the_colour,
                           foreground   => $main::this_is_the_forecolour,
                           command      => \&show_or_hide_roleuser);
   $hlist->pack(fill => 'both', expand => 'y');
   
   $open_folder_bitmap = $dialog->Bitmap(-file => "orac_images/openfolder.xbm");
   $closed_folder_bitmap = $dialog->Bitmap(-file => "orac_images/folder.xbm");
   $file_bitmap = $dialog->Bitmap(-file => "orac_images/file.xbm");
   
   %all_roleuser = undef;
   $hlist->add('ROLE', -itemtype => 'imagetext',
                       -image    => $closed_folder_bitmap,
                       -text     => 'ROLE');
   $all_roleuser{"ROLE"} = 'closed';
   $hlist->add('USER', -itemtype => 'imagetext',
                       -image    => $closed_folder_bitmap,
                       -text     => 'USER');
   $all_roleuser{"USER"} = 'closed';
   $dialog->Show;
}
sub show_or_hide_roleuser {
   my $hlist_thing = $_[0];
   if(!$all_roleuser{"$hlist_thing"}){
      &process_grantee($hlist_thing);
      return;
   }
   else {
      if($all_roleuser{"$hlist_thing"} eq 'closed'){
         $next_entry = $hlist->info('next', $hlist_thing);
         $hlist->entryconfigure($hlist_thing, -image => $open_folder_bitmap);
       
         $all_roleuser{"$hlist_thing"} = 'open';
         &add_grantees($hlist_thing);
      }
      else {
         $hlist->entryconfigure($hlist_thing, -image => $closed_folder_bitmap);
         $hlist->delete('offsprings', $hlist_thing);
         $all_roleuser{"$hlist_thing"} = 'closed';
      }
   }
}
sub add_grantees {
   my $roleuser = $_[0];
   $dialog->Busy;
   my $v_command;
   if ($roleuser eq 'ROLE'){
      $v_command = orac_Utils::file_string('sql_files', 'orac_GrantHlist',
                                           'add_grantees','1','sql');
   }
   else {
      $v_command = orac_Utils::file_string('sql_files', 'orac_GrantHlist',
                                           'add_grantees','2','sql');
   }
   my $sth = $local_dbh->prepare( $v_command ) || die $local_dbh->errstr; 
   my $rv = $sth->execute;
   while (@v_this_text = $sth->fetchrow) {
      my $grantee = "$roleuser" . '.' . "$v_this_text[0]";
      $hlist->add($grantee, -itemtype => 'imagetext',
                            -image    => $file_bitmap,
                            -text     => $grantee);
   }
   my $rc = $sth->finish;
   $dialog->Unbusy;
}
sub process_grantee {
   $dialog->Busy;
   do_a_grantee(@_);
   $dialog->Unbusy;
}
sub do_a_grantee {
   my $input = $_[0];
   my($roleuser, $grantee, $dummy) = split(/\./, $input);

   my $v_command = orac_Utils::file_string('sql_files', 'orac_GrantHlist',
                                           'do_a_grantee','1','sql');
   $v_command =~ s/orac_insert_grantee/$grantee/g;

   $local_dbh->func(100000, 'dbms_output_enable');
   my $second_sth = $local_dbh->prepare( $v_command ) 
                           || die $local_dbh->errstr; 
   my $second_rv = $second_sth->execute;

   my $local_dialog = $dialog->DialogBox( -title => 'Orac Dialog',
                                          -buttons => [ "Dismiss" ]);
   $local_dialog->add("Label", 
                      -text => "Grants SQL for $roleuser.$grantee", 
                      -height => 1)->pack(side => 'top');
   
   $v_text = 
      $local_dialog->Scrolled('Text', 
                              background => $main::this_is_the_colour,
                              foreground => $main::this_is_the_forecolour);

   $v_text->pack(-expand => 1, -fil => 'both');
   tie (*TEXT, 'Tk::Text', $v_text);
   my $j_counter = 0;
   my $full_list;
   while($j_counter < 1000){
      $full_list = scalar $local_dbh->func('dbms_output_get');
      $my_god = length($full_list);
      if ($my_god == 0){
         last;
      }
      $full_list =~ s/ as / as \n/g;
      unless ($full_list =~ /alter user/){
         print TEXT "$full_list\n";
      }
      $j_counter++;
   }
   my $v_bouton = $v_text->Button(-text => "See PL/SQL",
      -command => sub { $local_dialog->Busy;
                        main::see_sql($v_command);
                        $local_dialog->Unbusy },
      -cursor  => 'top_left_arrow');
   print TEXT "\n\n  ";
   $v_text->window('create', 'end', -window => $v_bouton);
   print TEXT "\n\n";
   $local_dialog->Show;
}
1;
