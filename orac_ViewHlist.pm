package orac_ViewHlist;

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
sub view_orac {
   $local_top = $_[0];
   $dbh = $_[1];
   $this_title = "Orac View SQL $v_db";
   $top = 
    $local_top->DialogBox( -title => $this_title, -buttons => [ "Dismiss" ]);

   my(@layout_menu_bar) = qw/-side top -padx 5 -expand yes -fill both/;

   $menu_bar = $top->Frame(width => 100)->pack(@layout_menu_bar);
   $menu_bar->Label(  
        -text        => 'Views',
        -font        => '-adobe-helvetica-bold-r-narrow--18-120-75-75-p-46-*-1',
        -borderwidth => 2,
        -relief      => 'flat',
        )->pack(-side => 'right', -anchor => 'e');
   $help_mb = $menu_bar->Menubutton(text        => 'Help',
                                    relief      => 'raised',
                                    borderwidth => 2,
                                     )->pack('-side' => 'left',
                                             '-padx' => 2,
                                            );
   $help_mb->command(-label         => 'Help on Screen',
     -underline => 0,
     -command   => sub { $top->Busy;
                         orac_UnixHelp::help_orac($top,
                                                  'orac_ViewHlist',
                                                  'view_orac',
                                                  '1');
                         $top->Unbusy } );
   
   $hlist = $top->Scrolled('HList',
                           drawbranch   => 1,
                           separator    => '.',
                           indent       => 50,
                           width        => 70,
                           height       => 20,
                           background   => $main::this_is_the_colour,
                           foreground   => $main::this_is_the_forecolour,
                           command      => \&show_or_hide_tab);
   $hlist->pack(fill => 'both', expand => 'y');
   
   $open_folder_bitmap = $top->Bitmap(-file => "orac_images/openfolder.xbm");
   $closed_folder_bitmap = $top->Bitmap(-file => "orac_images/folder.xbm");
   $file_bitmap = $top->Bitmap(-file => "orac_images/file.xbm");

   %all_the_owners = undef;

   my $v_command = 
          orac_Utils::file_string('sql_files', 'orac_ViewHlist',
                                  'view_orac','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      my $owner = $v_this_text[0];
      $hlist->add($owner, -itemtype => 'imagetext',
                          -image    => $closed_folder_bitmap,
                          -text     => $owner);
      $all_the_owners{"$owner"} = 'closed';
   }
   $rc = $sth->finish;
   $top->Show();
}
sub show_or_hide_tab {
   my $hlist_thing = $_[0];
   if(!$all_the_owners{"$hlist_thing"}){
      &process_view($hlist_thing);
      return;
   }
   else {
      if($all_the_owners{"$hlist_thing"} eq 'closed'){
         $next_entry = $hlist->info('next', $hlist_thing);
         $hlist->entryconfigure($hlist_thing, -image => $open_folder_bitmap);
       
         $all_the_owners{"$hlist_thing"} = 'open';
         &add_views($hlist_thing);
      }
      else {
         $hlist->entryconfigure($hlist_thing, -image => $closed_folder_bitmap);
         $hlist->delete('offsprings', $hlist_thing);
         $all_the_owners{"$hlist_thing"} = 'closed';
      }
   }
}
sub add_views {
   my $owner = $_[0];
   $top->Busy;

   my $v_command = 
          orac_Utils::file_string('sql_files', 'orac_ViewHlist',
                                  'add_views','1','sql');
   $v_command =~ s/orac_insert_owner/$owner/g;

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   my $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      my $view = "$owner" . '.' . "$v_this_text[0]";
      $hlist->add($view, -itemtype => 'imagetext',
                         -image    => $file_bitmap,
                         -text     => $view);
   }
   my $rc = $sth->finish;
   $top->Unbusy;
}
sub process_view {
   $top->Busy;
   my $input = $_[0];
   my($owner, $view, $dummy) = split(/\./, $input);
   do_a_view($input);
   $top->Unbusy;
}
sub do_a_view {
   my $input = $_[0];
   my($owner, $view, $the_task_ahead, $dummy) = split(/\./, $input);

   my $v_command = orac_Utils::file_string('sql_files', 'orac_ViewHlist',
                                           'do_a_view','1','sql');
   $v_command =~ s/orac_insert_owner/$owner/g;
   $v_command =~ s/orac_insert_view/$view/g;

   $dbh->func(30000, 'dbms_output_enable');
   my $second_sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   my $second_rv = $second_sth->execute;

   my $dialog = $top->DialogBox( -title => 'Orac Dialog', 
                                 -buttons => [ "Dismiss" ]);

   $dialog->add("Label", 
                -text => "View SQL for $owner.$view", 
                -height => 1)->pack(side => 'top');

   $v_text = 
     $dialog->Scrolled('Text', background => $main::this_is_the_colour,
                       foreground => $main::this_is_the_forecolour);

   $v_text->pack(-expand => 1, -fil    => 'both');
   tie (*TEXT, 'Tk::Text', $v_text);

   my $j_counter = 0;
   my $full_list;

   while($j_counter < 500){
      $full_list = scalar $dbh->func('dbms_output_get');
      $my_god = length($full_list);
      if ($my_god == 0){
         last;
      }
      $full_list =~ s/ as / as \n/g;
      print TEXT "$full_list\n";
      $j_counter++;
   }
   my $v_bouton = 
        $v_text->Button(-text => "See PL/SQL",
                        -command => sub { $dialog->Busy;
                                          main::see_sql($v_command);
                                          $dialog->Unbusy },
	                -cursor  => 'top_left_arrow');

   print TEXT "\n\n  ";
   $v_text->window('create', 'end', -window => $v_bouton);
   print TEXT "\n\n";

   $dialog->Show;
}
1;
