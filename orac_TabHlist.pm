package orac_TabHlist;

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
use orac_TabHlist2;
sub tables_orac {
   $local_top = $_[0];
   $dbh = $_[1];
   $this_title = "Orac Table SQL $v_db";
   $top = 
     $local_top->DialogBox( -title => $this_title, -buttons => [ "Dismiss" ]);

   my(@layout_menu_bar) = qw/-side top -padx 5 -expand yes -fill both/;
   $menu_bar = $top->Frame(width => 100)->pack(@layout_menu_bar);
   $menu_bar->Label(  
       -text        => 'Tables',
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
                                                  'orac_TabHlist',
                                                  'tables_orac','1');
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
   
   $v_usesegs = 'N';
   $no_radio = $top->Radiobutton ( variable => \$v_usesegs,
                                   text     => 'Original Extents',
                                   value    => 'N');
      $no_radio->pack (side => 'left');
   
   $yes_radio = $top->Radiobutton ( variable => \$v_usesegs,
                                    text     => 'Compressed Extents',
                                    value    => 'Y');
   $yes_radio->pack (side => 'left');
   
   my $balloon = $top->Balloon();

   my $text_msg =  orac_Utils::file_string('help_files', 'orac_TabHlist',
                                           'tables_orac','1','help');
   $balloon->attach($no_radio, -msg => $text_msg);
   
   $text_msg = orac_Utils::file_string('help_files', 'orac_TabHlist', 
                                       'tables_orac','2','help');
   $balloon->attach($yes_radio, -msg => $text_msg);

   %all_the_owners = undef;

   my $v_command = 
          orac_Utils::file_string('sql_files', 'orac_TabHlist',
                                  'tables_orac','1','sql');

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
      if(!$all_the_tables{"$hlist_thing"}){
         &process_stuff($hlist_thing);
         return;
      }
      if($all_the_tables{"$hlist_thing"} eq 'closed'){
         $next_entry = $hlist->info('next', $hlist_thing);
         $hlist->entryconfigure($hlist_thing, -image => $open_folder_bitmap);
       
         $all_the_tables{"$hlist_thing"} = 'open';
         &add_stuff($hlist_thing);
      }
      else {
         $hlist->entryconfigure($hlist_thing, -image => $closed_folder_bitmap);
         $hlist->delete('offsprings', $hlist_thing);
         $all_the_tables{"$hlist_thing"} = 'closed';
      }
   }
   else {
      if($all_the_owners{"$hlist_thing"} eq 'closed'){
         $next_entry = $hlist->info('next', $hlist_thing);
         $hlist->entryconfigure($hlist_thing, -image => $open_folder_bitmap);
       
         $all_the_owners{"$hlist_thing"} = 'open';
         &add_tables($hlist_thing);
      }
      else {
         $hlist->entryconfigure($hlist_thing, -image => $closed_folder_bitmap);
         $hlist->delete('offsprings', $hlist_thing);
         $all_the_owners{"$hlist_thing"} = 'closed';
      }
   }
}
sub add_tables {
   my $owner = $_[0];
   $top->Busy;

   my $v_command = 
          orac_Utils::file_string('sql_files', 'orac_TabHlist',
                                  'add_tables','1','sql');
   $v_command =~ s/orac_insert_owner/$owner/g;

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   my $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      my $table = "$owner" . '.' . "$v_this_text[0]";
      $hlist->add($table, -itemtype => 'imagetext',
                          -image    => $closed_folder_bitmap,
                          -text     => $table);
      $all_the_tables{"$table"} = 'closed';
   }
   my $rc = $sth->finish;
   $top->Unbusy;
}
sub add_stuff {
   my $full_table = $_[0];
   $top->Busy;
   my($owner, $table) = split(/\./, $full_table);

   my $v_command = 
          orac_Utils::file_string('sql_files', 'orac_TabHlist',
                                  'add_stuff','1','sql');
   $v_command =~ s/orac_insert_owner/$owner/g;
   $v_command =~ s/orac_insert_table/$table/g;

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   my $rv = $sth->execute;

   if (@v_this_text = $sth->fetchrow) {
      my $stuff = "$full_table" . '.' . 'table';
      $hlist->add($stuff, -itemtype => 'imagetext',
                          -image    => $file_bitmap,
                          -text     => $stuff);
   }
   my $rc = $sth->finish;

   $v_command = 
          orac_Utils::file_string('sql_files', 'orac_TabHlist',
                                  'add_stuff','2','sql');
   $v_command =~ s/orac_insert_owner/$owner/g;
   $v_command =~ s/orac_insert_table/$table/g;

   $sec_sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sec_sth->execute;

   if (@v_this_text = $sec_sth->fetchrow) {
      my $stuff = "$full_table" . '.' . 'indexes';
      $hlist->add($stuff, -itemtype => 'imagetext',
                          -image    => $file_bitmap,
                          -text     => $stuff);
   }
   $rc = $sec_sth->finish;

   $v_command = 
          orac_Utils::file_string('sql_files', 'orac_TabHlist',
                                  'add_stuff','3','sql');
   $v_command =~ s/orac_insert_owner/$owner/g;
   $v_command =~ s/orac_insert_table/$table/g;

   $thi_sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $thi_sth->execute;

   if (@v_this_text = $thi_sth->fetchrow) {
      my $stuff = "$full_table" . '.' . 'constraints';
      $hlist->add($stuff, -itemtype => 'imagetext',
                          -image    => $file_bitmap,
                          -text     => $stuff);
   }
   $rc = $thi_sth->finish;

   $v_command = 
          orac_Utils::file_string('sql_files', 'orac_TabHlist',
                                  'add_stuff','4','sql');
   $v_command =~ s/orac_insert_owner/$owner/g;
   $v_command =~ s/orac_insert_table/$table/g;

   $fou_sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $fou_sth->execute;

   if (@v_this_text = $fou_sth->fetchrow) {
      my $stuff = "$full_table" . '.' . 'triggers';
      $hlist->add($stuff, -itemtype => 'imagetext',
                          -image    => $file_bitmap,
                          -text     => $stuff);
   }
   $rc = $fou_sth->finish;

   $v_command = 
          orac_Utils::file_string('sql_files', 'orac_TabHlist',
                                  'add_stuff','5','sql');
   $v_command =~ s/orac_insert_owner/$owner/g;
   $v_command =~ s/orac_insert_table/$table/g;

   $fiv_sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $fiv_sth->execute;

   if (@v_this_text = $fiv_sth->fetchrow) {
      my $stuff = "$full_table" . '.' . 'comments';
      $hlist->add($stuff, -itemtype => 'imagetext',
                          -image    => $file_bitmap,
                          -text     => $stuff);
   }
   $rc = $fiv_sth->finish;
   my $anal_stuff = "$full_table" . '.' . 'analysis';
   $hlist->add($anal_stuff, -itemtype => 'imagetext',
                            -image    => $file_bitmap,
                            -text     => $anal_stuff);
   my $index_build = "$full_table" . '.' . 'index_build';
   $hlist->add($index_build, -itemtype => 'imagetext',
                             -image    => $file_bitmap,
                             -text     => $index_build);
   my $universal_form = "$full_table" . '.' . 'universal_form';
   $hlist->add($universal_form, -itemtype => 'imagetext',
                             -image    => $file_bitmap,
                             -text     => $universal_form);
   $top->Unbusy;
}
sub process_stuff {
   $top->Busy;
   my $input = $_[0];
   my($owner, $table, $the_task_ahead, $dummy) = split(/\./, $input);
   if ($the_task_ahead eq 'table'){
      do_a_table($input);
   }
   elsif ($the_task_ahead eq 'indexes'){
      do_an_index($input);
   }
   elsif ($the_task_ahead eq 'constraints'){
      do_a_constr($input);
   }
   elsif ($the_task_ahead eq 'triggers'){
      do_a_trigger($input);
   }
   elsif ($the_task_ahead eq 'comments'){
      do_comments($input);
   }
   elsif ($the_task_ahead eq 'blocks'){
      do_blocks($input);
   }
   elsif ($the_task_ahead eq 'space'){
      do_space($input);
   }
   elsif ($the_task_ahead eq 'analysis'){
      do_analysis($input);
   }
   elsif ($the_task_ahead eq 'index_build'){
      do_index_build($input);
   }
   elsif ($the_task_ahead eq 'universal_form'){
      orac_TabHlist2::do_universal_form($top, $dbh, $input);
   }
   $top->Unbusy;
}
sub do_a_table {
   my $input = $_[0];
   my($owner, $table, $the_task_ahead, $dummy) = split(/\./, $input);

   my $v_command = orac_Utils::file_string('sql_files', 'orac_TabHlist',
                                           'do_a_table','1','sql');
   $v_command =~ s/orac_insert_owner/$owner/g;
   $v_command =~ s/orac_insert_table/$table/g;
   $v_command =~ s/orac_insert_v_usesegs/$v_usesegs/g;

   $dbh->func(30000, 'dbms_output_enable');
   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   my $rv = $sth->execute;
   my $j_counter = 0;
   my $my_god;
   my $full_list;
   while($j_counter < 500){
      $_ = scalar $dbh->func('dbms_output_get');
      $my_god = length($_);
      if ($my_god == 0){
         last;
      }
      $full_list = $full_list . $_;
      $j_counter++;
   }
   my $dialog = 
       $top->DialogBox( -title => 'Orac Dialog', -buttons => [ "Dismiss" ]);
   $dialog->add("Label", 
                -text => "Table Schema for $owner.$table", 
                -height => 1)->pack(side => 'top');
   $v_text = $dialog->Scrolled('Text', 
                               background => $main::this_is_the_colour,
                               foreground => $main::this_is_the_forecolour);

   $v_text->pack(-expand => 1, -fil    => 'both');
   tie (*TEXT, 'Tk::Text', $v_text);

   $full_list =~ s/\n//g;
   $_ = $full_list;
   $field_count = (($speech_count = tr/"//)/2);
   $speech_pos2 = 0;
   $starter = 0;
   for ($i_count = 1;$i_count <= $field_count;$i_count++){
      $speech_pos1 = index($full_list, "\"", 1);
      $speech_pos2 = index($full_list, "\"", ($speech_pos1 + 1));
      print TEXT substr($full_list, $starter, $speech_pos1) . "\n";
      $field_name = sprintf("   %-30s", 
                            substr($full_list, 
                                   $speech_pos1, 
                                   ($speech_pos2 - $speech_pos1 + 1)));
      print TEXT $field_name;
      $full_list = substr($full_list, ($speech_pos2 + 1));
   }
   $this_str = sprintf("\n  %-22s", 'PCTFREE');
   $full_list =~ s/PCTFREE/$this_str/;
   $this_str = sprintf("\n  %-22s", 'PCTUSED');
   $full_list =~ s/PCTUSED/$this_str/;
   $this_str = sprintf("\n  %-22s", 'INITRANS');
   $full_list =~ s/INITRANS/$this_str/;
   $this_str = sprintf("\n  %-22s", 'MAXTRANS');
   $full_list =~ s/MAXTRANS/$this_str/;
   $this_str = sprintf("\n  %-22s", 'TABLESPACE');
   $full_list =~ s/TABLESPACE/$this_str/;
   $this_str = sprintf("\n  %s", 'STORAGE');
   $full_list =~ s/STORAGE/$this_str/;
   $this_str = sprintf("\n            %-18s", 'INITIAL');
   $full_list =~ s/INITIAL/$this_str/;
   $this_str = sprintf("\n            %-18s", 'NEXT');
   $full_list =~ s/NEXT/$this_str/;
   $this_str = sprintf("\n            %-18s", 'MINEXTENTS');
   $full_list =~ s/MINEXTENTS/$this_str/;
   $this_str = sprintf("\n            %-18s", 'MAXEXTENTS');
   $full_list =~ s/MAXEXTENTS/$this_str/;
   $this_str = sprintf("\n            %-18s", 'PCTINCREASE');
   $full_list =~ s/PCTINCREASE/$this_str/;
   $this_str = sprintf("\n            %-18s", 'FREELISTS');
   $full_list =~ s/FREELISTS/$this_str/;
   $this_str = sprintf("\n            %-18s", 'FREELIST GROUPS');
   $full_list =~ s/FREELIST GROUPS/$this_str/;
   print TEXT "$full_list\n";

   my $v_bouton = $v_text->Button(
                      -text => "See PL/SQL",
                      -command => sub { $dialog->Busy;
                                        main::see_sql($v_command);
                                        $dialog->Unbusy },
                      -cursor  => 'top_left_arrow');

   print TEXT "\n\n  ";
   $v_text->window('create', 'end', -window => $v_bouton);
   print TEXT "\n\n";
   $dialog->Show;
}
sub do_an_index {
   my $input = $_[0];
   my($owner, $table, $the_task_ahead, $dummy) = split(/\./, $input);

   my $v_command = orac_Utils::file_string('sql_files', 'orac_TabHlist',
                                           'do_an_index','1','sql');
   $v_command =~ s/orac_insert_owner/$owner/g;
   $v_command =~ s/orac_insert_table/$table/g;
   $v_command =~ s/orac_insert_v_usesegs/$v_usesegs/g;

   $dbh->func(30000, 'dbms_output_enable');
   my $second_sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   my $second_rv = $second_sth->execute;

   my $dialog = 
        $top->DialogBox( -title => 'Orac Dialog', -buttons => [ "Dismiss" ]);

   $dialog->add("Label", 
                -text => "Indexes for $owner.$table", 
                -height => 1)->pack(side => 'top');

   $v_text = 
       $dialog->Scrolled('Text', 
                         background => $main::this_is_the_colour,
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
      $full_list =~ s/create/\ncreate/g;
      $full_list =~ s/ on /\n   on /g;
      print TEXT "$full_list\n";
      $j_counter++;
   }
   my $v_bouton = 
          $v_text->Button(
                  -text => "See PL/SQL",
                  -command => sub { $dialog->Busy;
                                    main::see_sql($v_command);
                                    $dialog->Unbusy },
                  -cursor  => 'top_left_arrow');

   print TEXT "\n\n  ";
   $v_text->window('create', 'end', -window => $v_bouton);
   print TEXT "\n\n";
   $dialog->Show;
}
sub do_a_constr {
   my $input = $_[0];
   my($owner, $table, $the_task_ahead, $dummy) = split(/\./, $input);

   my $v_command = orac_Utils::file_string('sql_files', 'orac_TabHlist',
                                           'do_a_constr','1','sql');
   $v_command =~ s/orac_insert_owner/$owner/g;
   $v_command =~ s/orac_insert_table/$table/g;

   $dbh->func(30000, 'dbms_output_enable');
   my $second_sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   my $second_rv = $second_sth->execute;

   my $dialog = 
       $top->DialogBox( 
           -title => 'Orac Dialog', 
           -buttons => [ "Dismiss" ]);

   $dialog->add("Label", 
                -text => "Constraints for $owner.$table", 
                -height => 1)->pack(side => 'top');

   $v_text = $dialog->Scrolled('Text', 
                               background => $main::this_is_the_colour,
                               foreground => $main::this_is_the_forecolour);

   $v_text->pack(-expand => 1, -fil => 'both');
   tie (*TEXT, 'Tk::Text', $v_text);

   my $j_counter = 0;
   my $full_list;
   while($j_counter < 500){
      $full_list = scalar $dbh->func('dbms_output_get');
      $my_god = length($full_list);
      if ($my_god == 0){
         last;
      }
      $full_list =~ s/alter table/\nalter table/g;
      print TEXT "$full_list\n";
      $j_counter++;
   }
   my $v_bouton = 
       $v_text->Button(
            -text => "See PL/SQL",
            -command => sub { $dialog->Busy;
                              main::see_sql($v_command);
                              $dialog->Unbusy },
            -cursor  => 'top_left_arrow');

   print TEXT "\n\n  ";
   $v_text->window('create', 'end', -window => $v_bouton);
   print TEXT "\n\n";

   $dialog->Show;
}
sub do_a_trigger {
   my $input = $_[0];
   my($owner, $table, $the_task_ahead, $dummy) = split(/\./, $input);

   my $v_command = orac_Utils::file_string('sql_files', 'orac_TabHlist',
                                           'do_a_trigger','1','sql');
   $v_command =~ s/orac_insert_owner/$owner/g;
   $v_command =~ s/orac_insert_table/$table/g;

   $dbh->func(30000, 'dbms_output_enable');
   my $second_sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   my $second_rv = $second_sth->execute;

   my $dialog = 
        $top->DialogBox( -title => 'Orac Dialog', -buttons => [ "Dismiss" ]);

   $dialog->add("Label", 
                -text => "Triggers for $owner.$table", 
                -height => 1)->pack(side => 'top');
   
   $v_text = $dialog->Scrolled('Text', 
                               background => $main::this_is_the_colour,
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
      $full_list =~ s/create/\ncreate/g;
      print TEXT "$full_list\n";
      $j_counter++;
   }
   my $v_bouton = 
          $v_text->Button(
               -text => "See PL/SQL",
               -command => sub { $dialog->Busy;
                                 main::see_sql($v_command);
                                 $dialog->Unbusy },
               -cursor  => 'top_left_arrow');

   print TEXT "\n\n  ";
   $v_text->window('create', 'end', -window => $v_bouton);
   print TEXT "\n\n";

   $dialog->Show;
}
sub do_comments {
   my $input = $_[0];
   my($owner, $table, $the_task_ahead, $dummy) = split(/\./, $input);

   my $v_command = orac_Utils::file_string('sql_files', 'orac_TabHlist',
                                           'do_comments','1','sql');
   $v_command =~ s/orac_insert_owner/$owner/g;
   $v_command =~ s/orac_insert_table/$table/g;

   $dbh->func(30000, 'dbms_output_enable');
   my $second_sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   my $second_rv = $second_sth->execute;

   my $dialog = 
        $top->DialogBox( -title => 'Orac Dialog', -buttons => [ "Dismiss" ]);

   $dialog->add("Label", 
                -text => "Comments for $owner.$table", 
                -height => 1)->pack(side => 'top');

   $v_text = $dialog->Scrolled(
                 'Text', 
                 background => $main::this_is_the_colour,
                 foreground => $main::this_is_the_forecolour);

   $v_text->pack(-expand => 1, -fil => 'both');
   tie (*TEXT, 'Tk::Text', $v_text);

   my $j_counter = 0;
   my $full_list;
   while($j_counter < 500){
      $full_list = scalar $dbh->func('dbms_output_get');
      $my_god = length($full_list);
      if ($my_god == 0){
         last;
      }
      $full_list =~ s/COMMENT  ON/\nCOMMENT  ON/g;
      print TEXT "$full_list\n";
      $j_counter++;
   }
   my $v_bouton = 
         $v_text->Button(
                -text => "See PL/SQL",
                -command => sub { $dialog->Busy;
                                  main::see_sql($v_command);
                                  $dialog->Unbusy },
                -cursor  => 'top_left_arrow');

   print TEXT "\n\n  ";
   $v_text->window('create', 'end', -window => $v_bouton);
   print TEXT "\n\n";
   $dialog->Show;
}
sub do_space {
   my $input = $_[0];
   my($owner, $table, $the_task_ahead, $dummy) = split(/\./, $input);

   my $v_command =
          orac_Utils::file_string('sql_files', 'orac_TabHlist',
                                  'do_space','1','sql');
   $v_command =~ s/orac_insert_owner/$owner/g;
   $v_command =~ s/orac_insert_table/$table/g;

   my $dialog = 
       $top->DialogBox( -title => 'Orac Dialog', -buttons => [ "Dismiss" ]);

   $dialog->add("Label", 
                -text => "Blocks $owner.$table", 
                -height => 1)->pack(side => 'top');
   
   $v_text = $dialog->Scrolled(
                'Text', 
                background => $main::this_is_the_colour,
                foreground => $main::this_is_the_forecolour);

   $v_text->pack(-expand => 1, -fil => 'both');
   tie (*TEXT, 'Tk::Text', $v_text);
   print TEXT "Space Use for $owner.$table:\n\n";

   printf TEXT "%-20s %10s %10s\n\n", 'ALLOCATED_BLOCKS', 'USED', 'PCT_USED';

   my $second_sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   my $second_rv = $second_sth->execute;

   my $counter = 0;
   while (@v_this_text = $second_sth->fetchrow) {
      printf TEXT "%-20d %10d %10.2f\n", 
         $v_this_text[0],
         $v_this_text[1],
         $v_this_text[2];
      $counter++;
   }
   if($counter == 0){
      print TEXT "\nno rows found\n";
   }
   $rc = $second_sth->finish;
   $dialog->Show;
}
sub do_blocks {
   my $input = $_[0];
   my($owner, $table, $the_task_ahead, $dummy) = split(/\./, $input);

   my $v_command =
          orac_Utils::file_string('sql_files', 'orac_TabHlist',
                                  'do_blocks','1','sql');
   $v_command =~ s/orac_insert_owner/$owner/g;
   $v_command =~ s/orac_insert_table/$table/g;
   
   my $dialog = $top->DialogBox( -title => 'Orac Dialog',
                              -buttons => [ "Dismiss" ]);
   $dialog->add("Label", 
                -text => "Blocks $owner.$table", 
                -height => 1)->pack(side => 'top');
   
   $v_text = $dialog->Scrolled(
                'Text', 
                background => $main::this_is_the_colour,
                foreground => $main::this_is_the_forecolour);

   $v_text->pack(-expand => 1, -fil => 'both');
   tie (*TEXT, 'Tk::Text', $v_text);

   print TEXT "Blocks and Row Count for $owner.$table:\n\n";

   my $second_sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   my $second_rv = $second_sth->execute;

   my $counter = 0;
   my $row_counter = 0;
   while (@v_this_text = $second_sth->fetchrow) {
      printf TEXT "       Block: %-18s   Rows in this Block: %d\n", 
                  $v_this_text[0], $v_this_text[1];
      $counter++;
      $row_counter = $row_counter + $v_this_text[1];
   }
   if($counter == 0){
      print TEXT "\nno rows found\n";
   }
   else {
      printf TEXT "\nTotal Blocks: %-18d           Total Rows: %d\n", 
                  $counter, $row_counter;
      printf TEXT "\n              %-18s   Average Rows/Block: %f", 
                  '', ($row_counter/$counter);
   }
   $rc = $second_sth->finish;
   $dialog->Show;
}
sub do_index_build {
   my $input = $_[0];
   ($ind_owner, $ind_table, $the_task_ahead, $dummy) = split(/\./, $input);
   my $done = 0;
   do {
      $build_dialog = $top->DialogBox( -title => 'Orac Dialog',
                                    -buttons => [ "Build Index","Dismiss" ]);
      my $label = $build_dialog->Label( 
          text   => "Select $ind_owner.$ind_table Columns & then Build Index",
          font   => '-adobe-helvetica-bold-r-narrow--14-120-75-75-p-46-*-1',
          anchor => 'n',
          height => 1);

      $label->pack();
      my $tiler = $build_dialog->Scrolled('Tiler');
      $tiler->configure(-rows => 10, 
                        -columns => 4);
      my $v_command =
          orac_Utils::file_string('sql_files', 'orac_TabHlist',
                                  'do_index_build','1','sql');
      $v_command =~ s/orac_insert_ind_owner/$ind_owner/g;
      $v_command =~ s/orac_insert_ind_table/$ind_table/g;

      my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr;
      my $rv = $sth->execute;

      my(@pl) = qw/-side left -pady 2 -anchor w/;
      $tiler->Manage( $tiler->Label(
               -text     => 'Select',
               -font => '-adobe-helvetica-bold-r-normal--10-80-75-75-p-46-*-1',
               -relief   => 'groove')->pack(@pl));

      $tiler->Manage( $tiler->Label(
                -text     => 'Column',
                -font => '-adobe-helvetica-bold-r-normal--10-80-75-75-p-46-*-1',
                -relief   => 'groove')->pack(@pl));
      $tiler->Manage( $tiler->Label(
                -text     => 'Datatype',
                -font => '-adobe-helvetica-bold-r-normal--10-80-75-75-p-46-*-1',
                -relief   => 'groove')->pack(@pl));
      $tiler->Manage( $tiler->Label(
                -text     => 'Nullable',
                -font => '-adobe-helvetica-bold-r-normal--10-80-75-75-p-46-*-1',
	        -relief   => 'groove')->pack(@pl));
      @ind_use_cols;
      @ind_actual_cols;
      my @v_this_text;
      $ind_build_count = 0;
      while (@v_this_text = $sth->fetchrow) {
         $ind_use_cols[$ind_build_count] = 0;
         $this_text = sprintf("%-30s", $v_this_text[0]);
         $tiler->Manage( $tiler->Checkbutton(
                  -variable => \$ind_use_cols[$ind_build_count],
	          -relief   => 'flat')->pack(@pl));
         $tiler->Manage( $tiler->Label(
              -text     => $v_this_text[0],
              -font => '-adobe-helvetica-bold-r-normal--10-80-75-75-p-46-*-1',
	      -relief   => 'flat')->pack(@pl));
         $tiler->Manage( $tiler->Label(
              -text     => $v_this_text[1],
              -font => '-adobe-helvetica-bold-r-normal--10-80-75-75-p-46-*-1',
	      -relief   => 'flat')->pack(@pl));
         $tiler->Manage( $tiler->Label(
              -text     => $v_this_text[2],
              -font => '-adobe-helvetica-bold-r-normal--10-80-75-75-p-46-*-1',
	      -relief   => 'flat')->pack(@pl));
         $ind_actual_cols[$ind_build_count] = "$v_this_text[0]";
         $ind_build_count++;
      }
      $ind_build_count--;
      $rc = $sth->finish;
      $tiler->pack();
      my $decision = $build_dialog->Show;
      if ($decision eq "Build Index") {
         &build_index;
      }
      else {
         $done = 1;
      }
   } until $done;
}
sub build_index {
   
   my $this_checker = 0;
   for $i (0..$ind_build_count){
      if ($ind_use_cols[$i] == 1){
         $this_checker = 1;
      }
   }
   if ($this_checker == 1){
      &now_build_index_ord();
   }
   else {
      my $check_dialog = $top->DialogBox( -title => "Orac Dialog",
                                          -buttons => [ "Dismiss" ]);
      $check_dialog->add("Label", -text => 'No Columns Selected')->pack();
      my $button = $check_dialog->Show;
   }
}
sub really_build_index {
   my $dialog = 
       $top->DialogBox( -title => 'Orac Dialog', -buttons => [ "Dismiss" ]);

   $dialog->add("Label", 
                -text => "Index Creation Report for $ind_owner.$ind_table", 
                -height => 1)->pack(side => 'top');
   
   my $v_text = 
       $dialog->Scrolled('Text', background => $main::this_is_the_colour,
                         foreground => $main::this_is_the_forecolour);

   $v_text->pack(-expand => 1, -fil => 'both');
   tie (*BANANA_TEXT, 'Tk::Text', $v_text);

   my $v_command = orac_Utils::file_string('sql_files', 'orac_TabHlist',
                                           'really_build_index','1','sql');
   $v_command =~ s/orac_insert_ind_owner/$ind_owner/g;
   $v_command =~ s/orac_insert_ind_table/$ind_table/g;

   for my $column (1..$total_ind_count){
      
      # Ooer Mrs, a bit of PL/SQL

      my $bit_string = 
         " v_this_build($column) := " .
         "'$total_ind_array[$jesus_christ[$column]]'; ";
      $v_command = $v_command . $bit_string;
   }
   $v_command = $v_command . "\n";
   open(SQL_FILE, "sql_files/orac_TabHlist.really_build_index.2.sql");
   while(<SQL_FILE>){
      $v_command = $v_command . $_;
   }
   close(SQL_FILE);
   $v_command =~ s/orac_insert_total_ind_count/$total_ind_count/g;

   $dbh->func(30000, 'dbms_output_enable');
   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   my $rv = $sth->execute;

   my $j_counter = 0;
   my $full_list;
   my $we_have_failed = 0;
   $full_list = scalar $dbh->func('dbms_output_get');
   $my_god = length($full_list);
   if ($my_god != 0){
      $avg_entry_size = $full_list + 0.00;

      $next_command =
          orac_Utils::file_string('sql_files', 'orac_TabHlist',
                                  'really_build_index','3','sql');
      $next_command =~ s/orac_insert_ind_owner/$ind_owner/g;
      $next_command =~ s/orac_insert_ind_table/$ind_table/g;

       my $pct_sth = $dbh->prepare( $next_command ) || die $dbh->errstr; 
       my $pct_rv = $pct_sth->execute;

       if (@v_this_text = $pct_sth->fetchrow) {
         ($pct_free, $initrans,$dummy) = @v_this_text;
       }
       else {
          $we_have_failed = 1;
       }
       $pct_rc = $pct_sth->finish;
       if ($we_have_failed == 0){

          $next_command =
             orac_Utils::file_string('sql_files', 'orac_TabHlist',
                                     'really_build_index','4','sql');

          $blk_sth = $dbh->prepare( $next_command ) || die $dbh->errstr; 
          $blk_rv = $blk_sth->execute;

          if (@v_this_text = $blk_sth->fetchrow) {
             ($blk_size, $dummy) = @v_this_text;
          }
          else {
             $we_have_failed = 2;
          }
          $blk_rc = $blk_sth->finish;
       }
       if ($we_have_failed == 0){

          $next_command =
             orac_Utils::file_string('sql_files', 'orac_TabHlist',
                                     'really_build_index','5','sql');
          $next_command =~ s/orac_insert_ind_owner/$ind_owner/g;
          $next_command =~ s/orac_insert_ind_table/$ind_table/g;

          $cnt_sth = $dbh->prepare( $next_command ) || die $dbh->errstr; 
          $cnt_rv = $cnt_sth->execute;

          if (@v_this_text = $cnt_sth->fetchrow) {
             ($n_rows, $dummy) = @v_this_text;
          }
          else {
             $we_have_failed = 3;
          }
          $cnt_rc = $cnt_sth->finish;
       }
       if ($we_have_failed == 0){

          $next_command =
             orac_Utils::file_string('sql_files', 'orac_TabHlist',
                                     'really_build_index','6','sql');
          $next_command =~ s/orac_insert_blk_size/$blk_size/g;
          $next_command =~ s/orac_insert_initrans/$initrans/g;
          $next_command =~ s/orac_insert_pct_free/$pct_free/g;

          $ads_sth = $dbh->prepare( $next_command ) || die $dbh->errstr; 
          $ads_rv = $ads_sth->execute;

          if (@v_this_text = $ads_sth->fetchrow) {
             ($avail_data_space, $dummy) = @v_this_text;
          }
          else {
             $we_have_failed = 4;
          }
          $ads_rc = $ads_sth->finish;
       }
       if ($we_have_failed == 0){

          $next_command =
             orac_Utils::file_string('sql_files', 'orac_TabHlist',
                                     'really_build_index','7','sql');
          $next_command =~ s/orac_insert_avail_data_space/$avail_data_space/g;
          $next_command =~ s/orac_insert_avg_entry_size/$avg_entry_size/g;

          $spa_sth = $dbh->prepare( $next_command ) || die $dbh->errstr; 
          $spa_rv = $spa_sth->execute;

          if (@v_this_text = $spa_sth->fetchrow) {
             ($space, $dummy) = @v_this_text;
          }
          else {
             $we_have_failed = 5;
          }
          $spa_rc = $spa_sth->finish;
       }
       if ($we_have_failed == 0){

          $next_command =
             orac_Utils::file_string('sql_files', 'orac_TabHlist',
                                     'really_build_index','8','sql');
          $next_command =~ s/orac_insert_n_rows/$n_rows/g;
          $next_command =~ s/orac_insert_avg_entry_size/$avg_entry_size/g;
          $next_command =~ s/orac_insert_space/$space/g;

          $blo_sth = $dbh->prepare( $next_command ) || die $dbh->errstr; 
          $blo_rv = $blo_sth->execute;

          if (@v_this_text = $blo_sth->fetchrow) {
             ($blocks_req, $dummy) = @v_this_text;
          }
          else {
             $we_have_failed = 6;
          }
          $blo_rc = $blo_sth->finish;
       }
       if ($we_have_failed == 0){

          $next_command =
             orac_Utils::file_string('sql_files', 'orac_TabHlist',
                                     'really_build_index','9','sql');
          $next_command =~ s/orac_insert_blocks_req/$blocks_req/g;
          $next_command =~ s/orac_insert_blk_size/$blk_size/g;

          $ini_sth = $dbh->prepare( $next_command ) || die $dbh->errstr; 
          $ini_rv = $ini_sth->execute;

          if (@v_this_text = $ini_sth->fetchrow) {
             ($initial_extent, $dummy) = @v_this_text;
          }
          else {
             $we_have_failed = 7;
          }
          $ini_rc = $ini_sth->finish;
       }
       if ($we_have_failed == 0){

          $next_command =
             orac_Utils::file_string('sql_files', 'orac_TabHlist',
                                     'really_build_index','10','sql');
          $next_command =~ s/orac_insert_initial_extent/$initial_extent/g;

          $ini_sth = $dbh->prepare( $next_command ) || die $dbh->errstr; 
          $ini_rv = $ini_sth->execute;

          if (@v_this_text = $ini_sth->fetchrow) {
             ($next_extent, $dummy) = @v_this_text;
          }
          else {
             $we_have_failed = 8;
          }
          $ini_rc = $ini_sth->finish;
       }
       if ($we_have_failed == 0){

          $next_command =
             orac_Utils::file_string('sql_files', 'orac_TabHlist',
                                     'really_build_index','11','sql');

          $sys_sth = $dbh->prepare( $next_command ) || die $dbh->errstr; 
          $sys_rv = $sys_sth->execute;

          if (@v_this_text = $sys_sth->fetchrow) {
             ($sysdate, $dummy) = @v_this_text;
          }
          else {
             $we_have_failed = 9;
          }
          $sys_rc = $sys_sth->finish;
       }
       if ($we_have_failed == 0){
          print BANANA_TEXT "rem\n";
          print BANANA_TEXT "rem  Index Script for new " .
                            "index ${the_index_name} " .
                            "on ${ind_owner}.${ind_table}\n";
          print BANANA_TEXT "rem  (Generated by Orac: ${sysdate})\n";
          print BANANA_TEXT "rem\n\n";
          print BANANA_TEXT "create index ${ind_owner}.${the_index_name} on\n";
          print BANANA_TEXT "   ${ind_owner}.${ind_table} (\n";
          for my $column (1..$total_ind_count){
             my $bit_string;
             if ($column != $total_ind_count){
                $bit_string = 
                    "      $total_ind_array[$jesus_christ[$column]] ,\n";
             } else {
                $bit_string = 
                    "      $total_ind_array[$jesus_christ[$column]]\n";
             }
             print BANANA_TEXT $bit_string;
          }
          print BANANA_TEXT "   ) tablespace ${the_tabspace_name}\n";
          print BANANA_TEXT "   storage (initial " .
                            "${initial_extent}K " .
                            "next ${next_extent}K pctincrease 0)\n";
          print BANANA_TEXT "   pctfree ${pct_free};\n\n";
          print BANANA_TEXT "rem\n";
          print BANANA_TEXT "rem Average Index Entry Size:  " .
                            "${avg_entry_size}   ";

          my $v_bouton = 
              $v_text->Button(
           -text => "SQL calculating Average Index Entry Size",
           -font => '-adobe-helvetica-medium-r-normal--10-80-75-75-p-46-*-1',
           -command => sub { $top->Busy;
                             main::see_sql($v_command);
                             $top->Unbusy },
           -cursor  => 'top_left_arrow');

          $v_text->window('create', 'end', -window => $v_bouton);
          print BANANA_TEXT "\n";

          print BANANA_TEXT "rem Database Block Size:       ${blk_size}\n";
          print BANANA_TEXT "rem Current Table Row Count:   ${n_rows}\n";
          print BANANA_TEXT "rem Available Space Per " .
                            "Block: ${avail_data_space}\n";
          print BANANA_TEXT "rem Space For Each Index:      ${space}\n";
          print BANANA_TEXT "rem Blocks Required:           ${blocks_req}\n";
          print BANANA_TEXT "rem\n";
       }
   }
   else {
      $we_have_failed = 10;
   }
   if ($we_have_failed != 0){
      # How dare it
      print BANANA_TEXT "Index Script generation has failed at stage $we_have_failed.\n";
   }
   $dialog->Show;
}
sub now_build_index_ord {
   
   $total_ind_count = 0;
   @total_ind_array;
   for $i (0..$ind_build_count){
      if ($ind_use_cols[$i] == 1){
         $total_ind_count++;
         $total_ind_array[$total_ind_count] = $ind_actual_cols[$i];
      }
   }
   my $done = 0;
   $the_index_name = "";
   do {
      my $bot_dialog = 
            $top->DialogBox( -title => 'Orac Dialog',
                             -buttons => [ "Build Index","Dismiss" ]);

      my $label = 
          $bot_dialog->Label( 
              text   => "Please Insert Index Name, Tablespace, " .
                        "Index Order and then Build Index",
              font   => '-adobe-helvetica-bold-r-narrow--14-120-75-75-p-46-*-1',
              anchor => 'n',
              height => 1);
      $label->pack(-side => 'top');
      my $index_label = $bot_dialog->Label(-text => 'Index Name:');
      my $index_entry = $bot_dialog->add("Entry", -width => 24, 
                                      -background => 'white',
                                      -foreground => 'black');
      my $tabspace_label = $bot_dialog->Label(-text => "Tablespace:");
      my $blank_spacer = $bot_dialog->Label(-text => " ");
      $the_tabspace_name = "";
      $ts_list = $bot_dialog->BrowseEntry(
                    -background => 'white', 
                    -foreground => 'black',
                    -variable => \$the_tabspace_name,
                 );
   
      my $counter = 0;
      my @total_nonce;

      my $v_tabsp_command = 
          orac_Utils::file_string('sql_files', 'orac_TabHlist',
                                  'now_build_index_ord','1','sql');

      my $tabsp_sth = $dbh->prepare( $v_tabsp_command ) || die $dbh->errstr; 
      $tabsp_rv = $tabsp_sth->execute;

      while (@v_tabsp_text = $tabsp_sth->fetchrow) {
         $total_nonce[$counter] = $v_tabsp_text[0];
         $counter++;
      }
      $tabsp_rc = $tabsp_sth->finish;
      my @full_nonce = sort @total_nonce;
      
      $counter = 0;
      foreach(@full_nonce){
         $ts_list->insert('end', $_);
      }
      my $tiler = $bot_dialog->Scrolled('Tiler');
      $tiler->configure(-rows => ($total_ind_count + 1), 
                        -columns => ($total_ind_count + 1));
      my(@pl) = qw/-side left -pady 2 -anchor w/;
      for $i (1..($total_ind_count + 1)){
         if ($i <= $total_ind_count){
            $tiler->Manage( $tiler->Label(
               -text     => "Pos $i",
               -font => '-adobe-helvetica-bold-r-normal--10-80-75-75-p-46-*-1',
               -relief   => 'groove')->pack(@pl));
         }
         else {
            $tiler->Manage( $tiler->Label(
               -text     => "Col",
               -font => '-adobe-helvetica-bold-r-normal--10-80-75-75-p-46-*-1',
               -relief   => 'groove')->pack(@pl));
         }
      }
      @jesus_christ;
      for $jesus_row (1..$total_ind_count){
         $jesus_christ[$jesus_row] = $jesus_row;
         $old_jesus_christ[$jesus_row] = $jesus_christ[$jesus_row];
         for $jesus_column (1..($total_ind_count + 1)){
            if ($jesus_column <= $total_ind_count){
               $tiler->Manage( $tiler->Radiobutton(
                                  -relief   => 'flat',
                                  -variable => \$jesus_christ[$jesus_column],
                                  -command => [\&jesus_inri],
                                  -value    => $jesus_row)->pack(@pl));
            }
            else {
               $tiler->Manage( $tiler->Label(
                -text => $total_ind_array[$jesus_row],
                -font => '-adobe-helvetica-bold-r-normal--10-80-75-75-p-46-*-1',
                -justify  => 'left',
                -relief   => 'flat')->pack(@pl));
            }
         }
      }
      $index_label->form(-left => '%0', -right => '%50', 
                         -bottom => $tabspace_label);
      $index_entry->form(-left => $index_label, -right => '%100', 
                         -bottom => $ts_list);
      $tabspace_label->form(-top => $index_label, -left => '%0', 
                            -right => '%50', -bottom => $blank_spacer);
      $ts_list->form(-top => $index_entry, -left => $tabspace_label, 
                     -right => '%100', -bottom => $blank_spacer);

      $blank_spacer->form(-left => '%0', -right => '%100', -bottom => $tiler);
      $tiler->form(-left => '%0', -right => '%100', -bottom => '%100');
      $index_entry->focusForce;

      # How do you get this forcing to work on a Dialog?

      $index_entry->focus;
      $index_label->pack();
      $index_entry->pack();
      $tabspace_label->pack();
      $ts_list->pack();
      $blank_spacer->pack();
      $tiler->pack();
      $index_entry->focusForce;
      my $main_button = $bot_dialog->Show;
      $index_entry->focusForce;
      if ($main_button eq "Build Index") {
         $the_index_name = $index_entry->get;
         if (defined($the_index_name) && length($the_index_name)){
            if (defined($the_tabspace_name) && length($the_tabspace_name)){
               $build_dialog->Busy;
               &really_build_index;
               $build_dialog->Unbusy;
            }
            else {
               &please_enter('Tablespace');
            }
         }
         else {
            &please_enter('Index');
         }
      }
      else {
            $done = 1;
      }
   } until $done;
}
sub please_enter {
   my($banana,$dummy) = @_;
   my $dialog = $top->DialogBox( -title => "Orac Warning",
                                 -buttons => [ "Dismiss" ]);
   $dialog->add(
      "Label", 
      -text => "Please enter $banana Name, and re-insert information")->pack;
   $dialog->Show;
}
sub jesus_inri {
   my $spank_changed = 0;
   my $column = 0;
   for $column (1..$total_ind_count){
      if ($old_jesus_christ[$column] != $jesus_christ[$column]){
         $spank_changed = $column;
         last;
      }
   }
   if ($spank_changed > 0){
      for $column (1..$total_ind_count){
         unless ($column == $spank_changed){
            if ($jesus_christ[$column] == $jesus_christ[$spank_changed]){
                $jesus_christ[$column] = $old_jesus_christ[$spank_changed];
                $old_jesus_christ[$column] = $jesus_christ[$column];
                last;
            }
         }
      }
      $old_jesus_christ[$spank_changed] = $jesus_christ[$spank_changed];
   }
   # Feck, feck, feck it finally works!!!
}
sub do_analysis {
   my $input = $_[0];
   my($owner, $table, $the_task_ahead, $dummy) = split(/\./, $input);

   my $v_command = 
          orac_Utils::file_string('sql_files', 'orac_TabHlist',
                                  'do_analysis','2','sql');

   my $full_command = $v_command . "\n\n";

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   my $rv = $sth->execute;

   my($blksiz, $dummy) = $sth->fetchrow;
   my $rc = $sth->finish;

   $v_command = 
          orac_Utils::file_string('sql_files', 'orac_TabHlist',
                                  'do_analysis','3','sql');
   $v_command =~ s/orac_insert_owner/$owner/g;
   $v_command =~ s/orac_insert_table/$table/g;

   $full_command = $full_command . $v_command . "\n\n";

   $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   my($free, $dummy) = $sth->fetchrow;
   $rc = $sth->finish;

   $v_command = 
          orac_Utils::file_string('sql_files', 'orac_TabHlist',
                                  'do_analysis','4','sql');
   $v_command =~ s/orac_insert_owner/$owner/g;
   $v_command =~ s/orac_insert_table/$table/g;

   $full_command = $full_command . $v_command . "\n\n";

   $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   my($kount, $dummy) = $sth->fetchrow;
   $rc = $sth->finish;

   $v_command = 
          orac_Utils::file_string('sql_files', 'orac_TabHlist',
                                  'do_analysis','5','sql');
   $v_command =~ s/orac_insert_owner/$owner/g;
   $v_command =~ s/orac_insert_table/$table/g;

   $full_command = $full_command . $v_command . "\n\n";
   $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   my($blox, $dummy) = $sth->fetchrow;
   $rc = $sth->finish;
   $percent_of_distinct_cols = 'Y';

   my $v_command = orac_Utils::file_string('sql_files', 'orac_TabHlist',
                                           'do_analysis','1','sql');
   $v_command =~ s/orac_insert_owner/$owner/g;
   $v_command =~ s/orac_insert_table/$table/g;
   $v_command =~ s/orac_insert_kount/$kount/g;
   $v_command =~ 
       s/orac_insert_percent_of_distinct_cols/$percent_of_distinct_cols/g;

   $dbh->func(30000, 'dbms_output_enable');
   $full_command = $full_command . $v_command . "\n\n";
   $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   my $dialog = $top->DialogBox( -title => 'Orac Dialog', 
                                 -buttons => [ "Dismiss" ]);

   $dialog->add( "Label", 
                 -text => "Table Analysis for $owner.$table", 
                 -height => 1)->pack(side => 'top');
   
   $v_text = $dialog->Scrolled(
                 'Text', 
                 background => $main::this_is_the_colour,
                 foreground => $main::this_is_the_forecolour);

   $v_text->pack(-expand => 1, -fil => 'both');
   tie (*TEXT, 'Tk::Text', $v_text);

   my $this_text = sprintf ("%s %.2f %s %.2f %s %.2f%%\n\n", 
                            "$owner.$table contains $kount rows in",
                            ($blox * $blksiz),
                            "bytes,\nDB_BLOCK_SIZE of",
                            $blksiz,
                            ', PCTFREE of ',
                            $free);
   print TEXT $this_text;
   my $j_counter = 0;
   my $full_list;
   while($j_counter < 1000){
      $full_list = scalar $dbh->func('dbms_output_get');
      $my_god = length($full_list);
      if ($my_god == 0){
         last;
      }
      print TEXT "$full_list\n";
      $j_counter++;
   }
   my $v_bouton = 
        $v_text->Button(
            -text => "See SQL & PL/SQL",
            -command => sub { $dialog->Busy;
                              main::see_sql($full_command);
                              $dialog->Unbusy },
            -cursor  => 'top_left_arrow');
   print TEXT "\n\n  ";
   $v_text->window('create', 'end', -window => $v_bouton);
   print TEXT "\n\n";
   $dialog->Show;
}
1;
