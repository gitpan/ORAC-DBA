package orac_ProfsHlist;

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
sub prof_orac {
   $local_top = $_[0];
   $local_dbh = $_[1];
   $this_title = "Orac Profiles SQL $v_db";
   $dialog = $local_top->DialogBox( -title => $this_title,
                                       -buttons => [ "Dismiss" ]);
   my(@layout_menu_bar) = qw/-side top -padx 5 -expand yes -fill both/;
   $menu_bar = $dialog->Frame(width => 100)->pack(@layout_menu_bar);
   $menu_bar->Label(  
      -text        => 'Profiles',
      -borderwidth => 2,
      -relief      => 'flat',
      )->pack(-side => 'right', -anchor => 'e');
   my $help_mb = $menu_bar->Menubutton(text        => 'Help',
                                       relief      => 'raised',
                                       borderwidth => 2,
                                        )->pack('-side' => 'left',
                                                '-padx' => 2,
                                               );
   
   $help_mb->command(
     -label => 'Help on Screen',
     -underline => 0,
     -command   => sub { $dialog->Busy;
                         orac_UnixHelp::help_orac($dialog,
                                                  'orac_ProfsHlist',
                                                  'prof_orac',
                                                  '1');            
                         $dialog->Unbusy } );
   
   $hlist = $dialog->Scrolled('HList',
                           drawbranch   => 1,
                           separator    => '.',
                           indent       => 50,
                           width        => 70,
                           height       => 20,
                           background   => $main::this_is_the_colour,
                           foreground   => $main::this_is_the_forecolour,
                           command      => \&show_or_hide_tab);
   $hlist->pack(fill => 'both', expand => 'y');
   
   $open_folder_bitmap = $dialog->Bitmap(-file => "orac_images/openfolder.xbm");
   $closed_folder_bitmap = $dialog->Bitmap(-file => "orac_images/folder.xbm");
   $file_bitmap = $dialog->Bitmap(-file => "orac_images/file.xbm");
   
   my $v_command = orac_Utils::file_string('sql_files', 'orac_ProfsHlist',
                                           'prof_orac', '1','sql');

   my $sth = $local_dbh->prepare( $v_command ) || die $local_dbh->errstr; 
   %all_the_profile = undef;
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      my $profile = "$v_this_text[0]";
      $hlist->add($profile, -itemtype => 'imagetext',
                            -image    => $closed_folder_bitmap,
                            -text     => $profile);
      $all_the_profile{"$profile"} = 'closed';
   }
   $rc = $sth->finish;
   $dialog->Show;
}
sub show_or_hide_tab {
   my $hlist_thing = $_[0];
   if(!$all_the_profile{"$hlist_thing"}){
      &process_profile($hlist_thing);
      return;
   }
   else {
      if($all_the_profile{"$hlist_thing"} eq 'closed'){
         $next_entry = $hlist->info('next', $hlist_thing);
         $hlist->entryconfigure($hlist_thing, -image => $open_folder_bitmap);
       
         $all_the_profile{"$hlist_thing"} = 'open';
         &add_bits($hlist_thing);
      }
      else {
         $hlist->entryconfigure($hlist_thing, -image => $closed_folder_bitmap);
         $hlist->delete('offsprings', $hlist_thing);
         $all_the_profile{"$hlist_thing"} = 'closed';
      }
   }
}
sub add_bits {
   my $profile = $_[0];
   $dialog->Busy;
   my $bit = "$profile" . '.' . "sql";
   $hlist->add($bit, -itemtype => 'imagetext',
                     -image    => $file_bitmap,
                     -text     => $bit);
   $dialog->Unbusy;
}
sub process_profile {
   $dialog->Busy;
   my $input = $_[0];
   my($profile, $bit, $dummy) = split(/\./, $input);
   do_a_profile($input);
   $dialog->Unbusy;
}
sub do_a_profile {
   my $input = $_[0];
   my($profile, $bit, $the_task_ahead, $dummy) = split(/\./, $input);

   my $v_command = orac_Utils::file_string('sql_files', 'orac_ProfsHlist',
                                           'do_a_profile','1','sql');
   $v_command =~ s/orac_insert_profile/$profile/g;

   $local_dbh->func(30000, 'dbms_output_enable');
   my $second_sth = $local_dbh->prepare( $v_command ) 
         || die $local_dbh->errstr; 
   my $second_rv = $second_sth->execute;

   my $local_dialog = 
        $dialog->DialogBox( -title => 'Orac Dialog', -buttons => [ "Dismiss" ]);

   $local_dialog->add("Label", 
                      -text => "Profiles SQL for $profile.$bit", 
                      -height => 1)->pack(side => 'top');

   $v_text = 
      $local_dialog->Scrolled('Text', 
                              background => $main::this_is_the_colour,
                              foreground => $main::this_is_the_forecolour);

   $v_text->pack(-expand => 1, -fil    => 'both');
   tie (*TEXT, 'Tk::Text', $v_text);

   my $j_counter = 0;
   my $full_list;
   while($j_counter < 500){
      $full_list = scalar $local_dbh->func('dbms_output_get');
      $my_god = length($full_list);
      if ($my_god == 0){
         last;
      }
      print TEXT "$full_list\n";
      $j_counter++;
   }
   my $v_bouton = $v_text->Button(-text => "See SQL",
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
