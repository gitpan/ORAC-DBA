package orac_TabSpHlist;

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
use Tk::Balloon;
sub tablespace_orac {
   $local_top = $_[0];
   $dbh = $_[1];
   $Block_Size = $_[2];
   $this_title = "Orac Tablespace Examiner $v_db";
   $top = $local_top->DialogBox( -title => $this_title,
                                    -buttons => [ "Dismiss" ]);
   my(@layout_menu_bar) = qw/-side top -padx 5 -expand yes -fill both/;
   $menu_bar = $top->Frame(width => 100)->pack(@layout_menu_bar);
   $menu_bar->Label(  
      -text        => 'Tablespace Examiner',
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
     -underline     => 0,
     -command   => sub { $top->Busy;
                         orac_UnixHelp::help_orac($top,
                                                  'orac_TabSpHlist',
                                                  'tablespace_orac',
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
   
   %all_the_tabspaces = undef;

   my $v_command = 
          orac_Utils::file_string('sql_files', 'orac_TabSpHlist',
                                  'tablespace_orac','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      my $tabspace = $v_this_text[0];
      $hlist->add($tabspace, -itemtype => 'imagetext',
                             -image    => $closed_folder_bitmap,
                             -text     => $tabspace);
      $all_the_tabspaces{"$tabspace"} = 'closed';
   }
   $rc = $sth->finish;
   $top->Show();
}
sub show_or_hide_tab {
   my $hlist_thing = $_[0];
   if(!$all_the_tabspaces{"$hlist_thing"}){
      if(!$all_the_tabinds{"$hlist_thing"}){
         if(!$all_the_owners{"$hlist_thing"}){
            &process_stuff($hlist_thing);
            return;
         }
         else {
            if($all_the_owners{"$hlist_thing"} eq 'closed'){
               $next_entry = $hlist->info('next', $hlist_thing);
               $hlist->entryconfigure(
                          $hlist_thing, 
                          -image => $open_folder_bitmap);
             
               $all_the_owners{"$hlist_thing"} = 'open';
               &add_stuff($hlist_thing);
            }
            else {
               $hlist->entryconfigure(
                          $hlist_thing, 
                          -image => $closed_folder_bitmap);
               $hlist->delete('offsprings', $hlist_thing);
               $all_the_owners{"$hlist_thing"} = 'closed';
            }
         }
      }
      else {
         if($all_the_tabinds{"$hlist_thing"} eq 'closed'){
            $next_entry = $hlist->info('next', $hlist_thing);
            $hlist->entryconfigure(
                          $hlist_thing, 
                          -image => $open_folder_bitmap);
          
            $all_the_tabinds{"$hlist_thing"} = 'open';
            &add_owners($hlist_thing);
         }
         else {
            $hlist->entryconfigure(
                          $hlist_thing, 
                          -image => $closed_folder_bitmap);
            $hlist->delete('offsprings', $hlist_thing);
            $all_the_tabinds{"$hlist_thing"} = 'closed';
         }
      }
   }
   else {
      if($all_the_tabspaces{"$hlist_thing"} eq 'closed'){
         $next_entry = $hlist->info('next', $hlist_thing);
         $hlist->entryconfigure($hlist_thing, -image => $open_folder_bitmap);
       
         $all_the_tabspaces{"$hlist_thing"} = 'open';
         &add_tabinds($hlist_thing);
      }
      else {
         $hlist->entryconfigure($hlist_thing, -image => $closed_folder_bitmap);
         $hlist->delete('offsprings', $hlist_thing);
         $all_the_tabspaces{"$hlist_thing"} = 'closed';
      }
   }
}
sub add_tabinds {
   my $tabspace = $_[0];
   $top->Busy;
   my $tabind = "$tabspace" . '.' . 'TABLE';
   $hlist->add($tabind, -itemtype => 'imagetext',
                        -image    => $closed_folder_bitmap,
                        -text     => $tabind);
   $all_the_tabinds{"$tabind"} = 'closed';
   my $tabind = "$tabspace" . '.' . 'INDEX';
   $hlist->add($tabind, -itemtype => 'imagetext',
                        -image    => $closed_folder_bitmap,
                        -text     => $tabind);
   $all_the_tabinds{"$tabind"} = 'closed';
   $top->Unbusy;
}
sub add_stuff {
   my $full_tabind = $_[0];
   $top->Busy;
   my($tabspace, $tabind, $owner) = split(/\./, $full_tabind);

   my $v_command = 
          orac_Utils::file_string('sql_files', 'orac_TabSpHlist',
                                  'add_stuff','1','sql');
   $v_command =~ s/orac_insert_tabspace/$tabspace/g;

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   my $rv = $sth->execute;

   my($vsize,$dummy) = $sth->fetchrow;
   my $rc = $sth->finish;

   my $v_command =
          orac_Utils::file_string('sql_files', 'orac_TabSpHlist',
                                  'add_stuff','2','sql');
   $v_command =~ s/orac_insert_tabspace/$tabspace/g;
   $v_command =~ s/orac_insert_owner/$owner/g;
   $v_command =~ s/orac_insert_vsize/$vsize/g;
   $v_command =~ s/orac_insert_tabind/$tabind/g;

   $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      my $stuff = "$full_tabind" . '.' . $v_this_text[0];
      $hlist->add($stuff, -itemtype => 'imagetext',
                          -image    => $file_bitmap,
                          -text     => $stuff);
   }
   $rc = $sth->finish;
   $top->Unbusy;
}
sub add_owners {
   my $full_tabind = $_[0];
   $top->Busy;
   my($tabspace, $tabind) = split(/\./, $full_tabind);

   my $v_command = 
          orac_Utils::file_string('sql_files', 'orac_TabSpHlist',
                                  'add_owners','1','sql');
   $v_command =~ s/orac_insert_tabspace/$tabspace/g;

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   my $rv = $sth->execute;

   my($vsize,$dummy) = $sth->fetchrow;
   my $rc = $sth->finish;

   my $v_command =
           orac_Utils::file_string('sql_files', 'orac_TabSpHlist',
                                  'add_owners','2','sql');
   $v_command =~ s/orac_insert_tabspace/$tabspace/g;
   $v_command =~ s/orac_insert_vsize/$vsize/g;
   $v_command =~ s/orac_insert_tabind/$tabind/g;

   $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      my $owner = "$full_tabind" . '.' . $v_this_text[0];
      $hlist->add($owner, -itemtype => 'imagetext',
                          -image    => $closed_folder_bitmap,
                          -text     => $owner);
      $all_the_owners{"$owner"} = 'closed';
   }
   $rc = $sth->finish;
   $top->Unbusy;
}
sub process_stuff {
   my $input = $_[0];
   my($tabspace, $tabind, $owner, $object) = split(/\./, $input);
   
   $top->Busy;
   my $dialog_text =
      "This Report on $owner.$object could " .
      "take SOME TIME to run.\nAre you sure you wish to run it?";

   my $check_dialog = $top->DialogBox( -title => "Orac Dialog",
                                       -buttons => [ "Yes", "No" ]);

   $check_dialog->add("Label", -text => $dialog_text)->pack();
   my $button = $check_dialog->Show;

   if($button eq 'Yes'){
      my $dialog = $top->DialogBox( -title => 'Orac Dialog',
                                 -buttons => [ "Dismiss" ]);
      $dialog->add("Label", 
                   -text => "$tabspace $tabind Info on $owner.$object", 
                   -height => 1)->pack(side => 'top');
      
      $v_text = 
         $dialog->Scrolled('Text', background => $main::this_is_the_colour,
                           foreground => $main::this_is_the_forecolour);

      $v_text->pack(-expand => 1, -fil => 'both');
      tie (*TEXT, 'Tk::Text', $v_text);
   
      if($tabind eq 'TABLE'){

         my $v_command =
          orac_Utils::file_string('sql_files', 'orac_TabSpHlist',
                                  'process_stuff','1','sql');
         $v_command =~ s/orac_insert_owner/$owner/g;
         $v_command =~ s/orac_insert_object/$object/g;
         $v_command =~ s/orac_insert_Block_Size/$Block_Size/g;

         print TEXT "\n$tabspace $tabind Info on $owner.$object\n\n";
         &tab_print('Block_Size', 'Allocated_Blocks', 'Blocks_Used', 
                    'Pct_Used%', 'SizexAllctd', 'SizexUsed');
         &tab_print('----------', '----------------', '-----------', 
                    '---------', '-----------', '---------');
         
         my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
         my $rv = $sth->execute;

         while (@v_this_text = $sth->fetchrow) {
            my $size_all = ($v_this_text[0] * $v_this_text[1]);
            my $size_use = ($v_this_text[0] * $v_this_text[2]);
            &tab_print($v_this_text[0],
                       $v_this_text[1],
                       $v_this_text[2],
                       $v_this_text[3],
                       $size_all,
                       $size_use);
         }
         my $rc = $sth->finish;
      }
      print TEXT "\n\nMuch more will be added here to Orac, " .
                 "when time allows.\n";
      $dialog->Show;
   }
   $top->Unbusy;
}
sub tab_print {
   my($Block_Size,$Allocated_Blocks,$Blocks_Used,
      $Pct_Used,$SizexAllctd,$SizexUsed,$dummy) = @_;
$^A = "";
$str = formline <<'END',$Block_Size,$Allocated_Blocks,$Blocks_Used,$Pct_Used,$SizexAllctd,$SizexUsed;
^>>>>>>>>> ^>>>>>>>>>>>>>>> ^>>>>>>>>>> ^>>>>>>>> ^>>>>>>>>>>>> ^>>>>>>>>>>>> ~~
END
print TEXT "$^A";
}
1;
