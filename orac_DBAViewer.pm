package orac_DBAViewer; 

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
use orac_TabHlist2;
use Cwd;
use DBI;
use Tk::DialogBox;
use Tk::HList;
use Tk::Balloon;
sub dbas_orac {
   package main;
   my $v_command = orac_Utils::file_string('sql_files', 'orac_DBAViewer',
                                           'dbas_orac','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   my $detected = 0;
   while (@v_this_text = $sth->fetchrow) {
      $detected++;
      if($detected == 1){
         $dbaed_top = MainWindow->new();
         my $this_title = "Orac DBA Table Viewer: $v_db";
         $dbaed_top->title($this_title);
         $label = $dbaed_top->Label( 
                      text   => '  Double-Click Required DBA Table  ',
                      anchor => 'n',
                      relief => 'groove',
                      height => 1,
                       )->pack();
         $orac_DBAViewer::dbaed_list = 
            $dbaed_top->ScrlListbox(
                "height" => 30, 
                "width" => (length($this_title) + 10), 
                "background" => $main::this_is_the_colour,
                "foreground" => $main::this_is_the_forecolour,
                );
         $dismiss_button = 
            $dbaed_top->Button( 
               text    => 'Dismiss',
               command => sub { $dbaed_top->withdraw();
                                $grey_dbas->configure(-state => 'active') } 
                  )->pack(-side => 'bottom', -anchor => 'se');
         my $icon_img = 
              $dbaed_top->Pixmap('-file' => 'orac_images/orac_smid.bmp');
         $dbaed_top->Icon('-image' => $icon_img);
         $dbaed_top->iconname('DBA');
      }
      $orac_DBAViewer::dbaed_list->insert('end', @v_this_text);
   }
   $rc = $sth->finish;
   $grey_dbas->configure(-state => 'disabled');
   $orac_DBAViewer::dbaed_list->pack();
   $orac_DBAViewer::dbaed_list->bind('<Double-1>', 
     sub { $top->Busy;orac_DBAViewer::selected_dba($top,$dbh);$top->Unbusy});
}
sub selected_dba {
   ($top,$dbh) = @_;
   $dbaed_bit = $dbaed_list->get('active');
   $max_width_of_form = 24;
   $max_height_of_form = 8;

   $main_uni_title = "Orac DBA Form for $dbaed_bit";
   my $build_dialog = $top->DialogBox( 
                        -title => $main_uni_title, 
                        -buttons => [ "Dismiss" ]);
   my $label = $build_dialog->Label( 
         text   => "Provide SQL for Columns, indicate " .
                   "selection order & then press 'Select Information'",
         anchor => 'n',
         height => 1);
   $label->pack();
   my $tiler = $build_dialog->Scrolled('Tiler');
   $tiler->configure(-rows => $max_height_of_form, -columns => 4);

   my $v_command = orac_Utils::file_string('sql_files', 'orac_DBAViewer',
                                           'selected_dba','1','sql');
   $v_command =~ s/orac_insert_dbaed_bit/$dbaed_bit/g;

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr;
   my $rv = $sth->execute;

   (@global_pl) = qw/-side left -pady 2 -anchor w/;
   $tiler->Manage( $tiler->Label(
                      -text     => 'Order By',
                      -relief   => 'groove')->pack(@global_pl));
   $tiler->Manage( $tiler->Label(
                      -text     => 'Column',
                      -relief   => 'groove')->pack(@global_pl));
   $tiler->Manage( $tiler->Label(
                      -text     => 'Select SQL',
                      -relief   => 'groove')->pack(@global_pl));
   $tiler->Manage( $tiler->Label(
                      -text     => 'Datatype',
                      -relief   => 'groove')->pack(@global_pl));
   @ind_use_cols;
   @ind_actual_cols;
   my @v_this_text;
   $ind_build_count = 0;
   while (@v_this_text = $sth->fetchrow) {
      $ind_use_cols[$ind_build_count] = 0;
      $this_text = sprintf("%-30s", $v_this_text[0]);
      $tiler->Manage( $tiler->Checkbutton(
                                -variable => \$ind_use_cols[$ind_build_count],
	                        -relief   => 'flat')->pack(@global_pl));
      $tiler->Manage( $tiler->Label(
                                -text   => $v_this_text[0],
	                        -relief => 'flat')->pack(@global_pl));
      $sql_entry[$ind_build_count] = "";

      $tiler->Manage ( $tiler->Entry(
         -textvariable => \$sql_entry[$ind_build_count],
         -background => 'white',
         -foreground => 'black'));
      $tiler->Manage( $tiler->Label(
         -text     => "$v_this_text[1] $v_this_text[2]",
	 -relief   => 'flat')->pack(@global_pl));

      $ind_actual_cols[$ind_build_count] = "$v_this_text[0]";
      $ind_data_length[$ind_build_count] = "$v_this_text[3]";
      $ind_build_count++;
   }
   $ind_build_count--;
   $rc = $sth->finish;
   $tiler->pack();
   my(@layout_bot_bar) = qw/-side bottom -padx 5/;
   my $bot_bar = $build_dialog->Frame->pack(@layout_bot_bar);
   $help_button = 
      $bot_bar->Button( text    => '  Help on Select SQL  ',
       command => sub { $build_dialog->Busy;
                        orac_UnixHelp::help_orac(
                                  $build_dialog,
                                  'orac_DBAViewer',
                                  'selected_dba', 
                                  '1');
                        $build_dialog->Unbusy });
   $help_button->pack(side => 'left', anchor => 'w');

   $go_button = $bot_bar->Button( 
                    text    => '  Select Information  ',
                    command => sub { 
                       $build_dialog->Busy;
                       orac_DBAViewer::selector();
                       $build_dialog->Unbusy });
   $go_button->pack(side => 'right', anchor => 'e');

   $build_dialog->Show;
}
sub selector {
   $this_select_str = ' select ';
   $this_count_str = ' select count(*) ';
   for $i (0..$ind_build_count){
      if ($i != $ind_build_count){
         $this_select_str = $this_select_str . "$ind_actual_cols[$i], ";
      }
      else {
         $this_select_str = $this_select_str . "$ind_actual_cols[$i] ";
      }
   }
   $this_select_str = $this_select_str . "\nfrom $dbaed_bit ";
   $this_count_str = $this_count_str . "\nfrom $dbaed_bit ";
   my $flag = 0;
   my $last_one = 0;
   for $i (0..$ind_build_count){
      if ($ind_use_cols[$i] == 1){
         $flag = 1;
         $last_one = $i;
      }
   }

   # This is as bad as it looks.  You have been warned.

   my $where_bit = "\nwhere ";
   for $i (0..$ind_build_count){
      my $sql_bit = $sql_entry[$i];
      if (defined($sql_bit) && length($sql_bit)){
         $this_select_str = $this_select_str . 
                            $where_bit . 
                            "$ind_actual_cols[$i] $sql_bit ";
         $this_count_str =  $this_count_str . 
                            $where_bit . 
                            "$ind_actual_cols[$i] $sql_bit ";
         $where_bit = "\nand ";
      }
   }

   &build_ordering;
   @row_ary = $dbh->selectrow_array($this_count_str);
   $rows_counted = $row_ary[0];
   $max_rows_allowed = 10000;
   $rows_counted = $row_ary[0];
   if ($rows_counted > $max_rows_allowed){
      my $warn_text = 
           "$rows_counted rows in this selection." . "\n" .
           "Only $max_rows_allowed rows allowed within Orac." . "\n" .
           "Please refine your SQL to come"  . "\n" .
           "within this limit.";
      my $warn_dialog = $top->DialogBox( -title => "Orac Warning",
                                      -buttons => [ "Dismiss" ]);
      my $warn_label = $warn_dialog->Label( 
                       text   => $warn_text);
      $warn_label->pack();
      $warn_dialog->Show;
   }
      else {
      if ($rows_counted < 1.0){
         my $warn_text = "$rows_counted rows in this selection." . "\n" .
                         "Please refine your SQL to get some rows.";
         my $warn_dialog = $top->DialogBox( -title => "Orac Warning",
                                            -buttons => [ "Dismiss" ]);
         my $warn_label = $warn_dialog->Label( 
                          text   => $warn_text);
         $warn_label->pack();
         $warn_dialog->Show;
      }
      else {
         &and_finally($rows_counted, $this_select_str);
      }
   }
}
sub and_finally {
   my($rows_first_counted, $select_str, $dummy) = @_;
   my $fancy_help = "";

   my $v_command = orac_Utils::file_string('sql_files', 'orac_DBAViewer',
                                           'and_finally','1','sql');

   $v_command =~ s/orac_insert_dbaed_bit/$dbaed_bit/g;

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      $fancy_help = $v_this_text[0];
   }
   $rc = $sth->finish;
   my $fancy_length = length($fancy_help);
   $ary_ref = $dbh->selectall_arrayref($select_str);
   $min_row = 0;
   $max_row = @$ary_ref;
   $max_row--;
   $glob_curr_rec = $min_row;
   $curr_dialog = 
      $top->DialogBox( -title => $main_uni_title, -buttons => [ "Dismiss" ]);
   my(@layout_top_bar) = qw/-side top -padx 5 -expand yes -fill both/;
   my $top_frame = $curr_dialog->Frame->pack(@layout_top_bar);
   my $top_label = $top_frame->Label( 
                 -text   => "$dbaed_bit Selection Results: ",
                 -anchor => 'w')->pack(-side => 'left', -anchor => 'w');

   my $fancy_width = 80;
   if ($fancy_length > 0){
      my $monkey;
      if ($fancy_length <= $fancy_width){
         $monkey = $top_frame->Entry( -textvariable => \$fancy_help,
                        -width        => $fancy_length,
                        -relief       => 'sunken',
                        -background   => $main::this_is_the_colour,
                        -foreground   => $main::this_is_the_forecolour);
      } else {
         $monkey = $top_frame->Scrolled('Entry', 
                        -textvariable => \$fancy_help,
                        -width        => $fancy_width,
                        -relief       => 'sunken',
                        -background   => $main::this_is_the_colour,
                        -foreground   => $main::this_is_the_forecolour);
      }
      $monkey->pack(-side => 'left', -anchor => 'w');
   }
   my $num_label = $top_frame->Label( 
                 -textvariable   => \$current_counter,
                 -relief         => 'sunken',
                 -anchor         => 'e',
                 -height         => 1)->pack(-side => 'right', -anchor => 'e');
   my $tiler = $curr_dialog->Scrolled('Tiler');
   $tiler->configure(-rows => $max_height_of_form, -columns => 3);
   @large_banana;

   $v_command = orac_Utils::file_string('sql_files', 'orac_DBAViewer',
                                        'and_finally','2','sql');
   $v_command =~ s/orac_insert_dbaed_bit/$dbaed_bit/g;

   $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   my %super_help;
   while (@v_this_text = $sth->fetchrow) {
      $super_help{"$v_this_text[0]"} = $v_this_text[1];
   }
   $rc = $sth->finish;

   for my $i (0..$ind_build_count) {
      $large_banana[$i] = "";
      my $width = $ind_data_length[$i];
      my $within_limits = 1;
      if ($width > $max_width_of_form){
         $width = $max_width_of_form;
         $within_limits = 2;
      }
      $tiler->Manage( $tiler->Label(
                                -text     => $ind_actual_cols[$i],
	                        -relief   => 'groove')->pack(@global_pl));
      my $super_length;
      my $super_width;
      $super_length = length($super_help{"$ind_actual_cols[$i]"});
      $super_width = $max_width_of_form;
      if ($super_length > 0){
         if (($super_length) <= $super_width){
            $tiler->Manage (
                 $tiler->Entry( 
                    -textvariable => \$super_help{"$ind_actual_cols[$i]"},
                    -relief       => 'sunken',
                    -background   => $main::this_is_the_colour,
                    -foreground   => $main::this_is_the_forecolour));
         } else {
            $tiler->Manage ($tiler->Scrolled('Entry', 
                    -textvariable => \$super_help{"$ind_actual_cols[$i]"},
                    -width        => $super_width,
                    -relief       => 'sunken',
                    -background   => $main::this_is_the_colour,
                    -foreground   => $main::this_is_the_forecolour));
         }
      } else {
         $tiler->Manage( $tiler->Label(
                    -text     => "",
	            -relief   => 'sunken')->pack(@global_pl));
      }

      if ($within_limits == 1){
         $tiler->Manage ( $tiler->Entry(
                    -textvariable => \$large_banana[$i],
                    -width        => $width,
                    -background   => 'white',
                    -foreground   => 'black'));
      } else {
         $tiler->Manage ( $tiler->Scrolled('Entry', 
                    -textvariable => \$large_banana[$i],
                    -width        => $width,
                    -background   => 'white',
                    -foreground   => 'black'));
      }
   }
   $tiler->pack();
   my(@layout_controls) = qw/-side bottom -padx 5 -expand yes -fill both/;
   $control_bar = $curr_dialog->Frame->pack(@layout_controls);
   $next_image = $curr_dialog->Photo(-file => "orac_images/next.bmp");
   $first_image = $curr_dialog->Photo(-file => "orac_images/first.bmp");
   $last_image = $curr_dialog->Photo(-file => "orac_images/last.bmp");
   $prev_image = $curr_dialog->Photo(-file => "orac_images/prev.bmp");
   $mid_image = $curr_dialog->Photo(-file => "orac_images/middle.bmp");
   $mid_forw_image = $curr_dialog->Photo(-file => "orac_images/mid_forw.bmp");
   $mid_back_image = $curr_dialog->Photo(-file => "orac_images/mid_back.bmp");

   $first_button = 
      $control_bar->Button( -image => $first_image, 
                            -command => sub { &first_rec });

   $first_button->pack(side => 'left');

   $prev_button = $control_bar->Button( 
                            -image  => $prev_image, 
                            -command => sub { &prev_rec });

   $prev_button->pack(side => 'left');

   $mid_back_button = $control_bar->Button( 
                          -image  => $mid_back_image, 
                          -command => sub { &mid_back_rec });
   $mid_back_button->pack(side => 'left');

   $mid_button = $control_bar->Button( 
                          -image  => $mid_image, 
                          -command => sub { &mid_rec });
   $mid_button->pack(side => 'left');

   $mid_forw_button = $control_bar->Button( 
                          -image  => $mid_forw_image, 
                          -command => sub { &mid_forw_rec });
   $mid_forw_button->pack(side => 'left');

   $next_button = $control_bar->Button( 
                          -image  => $next_image, 
                          -command => sub { &next_rec });
   $next_button->pack(side => 'left');

   $last_button = $control_bar->Button( 
                          -image  => $last_image, 
                          -command => sub { &last_rec });
   $last_button->pack(side => 'left');

   $record_label = "Record of " . ($max_row + 1);
   $generic_scale = $control_bar->Scale( -orient => horizontal, 
                                         -length => 200, 
                                         -label  => $record_label,
                                         -sliderrelief => 'raised',
                                         -from   => 1,
                                         -to     => ($max_row + 1),
                                         -command => [ \&calc_scale_record ],
                                                 )->pack(side => 'left');
   $sql_button = $control_bar->Button( 
                       -text  => 'See SQL', 
                       -command => sub { main::see_sql($this_select_str)});
   $sql_button->pack(side => 'right');
   &go_for_gold();
   $curr_dialog->Show;
   undef $ary_ref;
}
sub calc_scale_record {
   my($scale_value) = @_;
   $glob_curr_rec = $scale_value - 1;
   &go_for_gold();
}

sub go_for_gold {
   my $curr_ref = $ary_ref->[$glob_curr_rec];
   for my $i (0..$ind_build_count) {
      $large_banana[$i] = $curr_ref->[$i];
   }
   $current_counter = ($glob_curr_rec + 1) . " of " . ($max_row + 1);
   $generic_scale->set(($glob_curr_rec + 1));
}
sub next_rec {
   $glob_curr_rec++;
   if($glob_curr_rec >= $max_row){
      $glob_curr_rec = $max_row;
   }
   &go_for_gold();
}
sub prev_rec {
   $glob_curr_rec--;
   if($glob_curr_rec <= $min_row){
      $glob_curr_rec = $min_row;
   }
   &go_for_gold();
}
sub mid_rec {
   $glob_curr_rec = int (($max_row + 1)/2.0);
   if($glob_curr_rec >= $max_row){
      $glob_curr_rec = $max_row;
   }
   if($glob_curr_rec <= $min_row){
      $glob_curr_rec = $min_row;
   }
   &go_for_gold();
}
sub mid_forw_rec {
   $glob_curr_rec = int (($glob_curr_rec + $max_row + 1)/2.0);
   if($glob_curr_rec >= $max_row){
      $glob_curr_rec = $max_row;
   }
   if($glob_curr_rec <= $min_row){
      $glob_curr_rec = $min_row;
   }
   &go_for_gold();
}
sub mid_back_rec {
   $glob_curr_rec = int (($glob_curr_rec + 1)/2.0);
   if($glob_curr_rec >= $max_row){
      $glob_curr_rec = $max_row;
   }
   if($glob_curr_rec <= $min_row){
      $glob_curr_rec = $min_row;
   }
   &go_for_gold();
}
sub first_rec {
   $glob_curr_rec = $min_row;
   &go_for_gold();
}
sub last_rec {
   $glob_curr_rec = $max_row;
   &go_for_gold();
}
sub build_ordering {
   
   my $this_checker = 0;
   for $i (0..$ind_build_count){
      if ($ind_use_cols[$i] == 1){
         $this_checker = 1;
      }
   }
   if ($this_checker == 1){
      &now_build_ord();
      $this_rowid_str = $this_rowid_str . "\norder by ";
      $this_select_str = $this_select_str . "\norder by ";
      for my $column (1..$total_ind_count){
         $this_rowid_str = $this_rowid_str . 
                          "$total_ind_array[$jesus_christ[$column]] ";
         $this_select_str = $this_select_str . 
                            "$total_ind_array[$jesus_christ[$column]] ";
         if ($desc_or_not[$jesus_christ[$column]] == 1){
            $this_rowid_str = $this_rowid_str . "desc ";
            $this_select_str = $this_select_str . "desc ";
         }
         if ($column != $total_ind_count){
            $this_rowid_str = $this_rowid_str . ", ";
            $this_select_str = $this_select_str . ", ";
         }
      }
   }
}
sub now_build_ord {
   
   $total_ind_count = 0;
   @total_ind_array;
   @desc_or_not;
   for $i (0..$ind_build_count){
      if ($ind_use_cols[$i] == 1){
         $total_ind_count++;
         $total_ind_array[$total_ind_count] = $ind_actual_cols[$i];
      }
   }
   my $bot_dialog = 
         $top->DialogBox( -title => $main_uni_title, 
                          -buttons => [ "Continue" ]);

   my $label = $bot_dialog->Label( 
        text   => "Please Arrange Index Order and then press 'Continue'",
        anchor => 'n',
        height => 1);

   $label->pack(-side => 'top');
   my $tiler = $bot_dialog->Scrolled('Tiler');
   $tiler->configure(-rows => ($total_ind_count + 1), 
                     -columns => ($total_ind_count + 2));
   for $i (1..($total_ind_count + 2)){
      if ($i <= $total_ind_count){
         $tiler->Manage( $tiler->Label(
                            -text     => "Order Position $i",
                            -relief   => 'groove')->pack(@global_pl));
      }
      else {
         if ($i == ($total_ind_count + 1)){
            $tiler->Manage( $tiler->Label(
                            -text     => "Column",
                            -relief   => 'groove')->pack(@global_pl));
         } else {
            $tiler->Manage( $tiler->Label(
                            -text     => "Descending?",
                            -relief   => 'groove')->pack(@global_pl));
         }
      }
   }
   @jesus_christ;
   for $jesus_row (1..$total_ind_count + 1){
      $jesus_christ[$jesus_row] = $jesus_row;
      $desc_or_not[$jesus_row] = 0;
      $old_jesus_christ[$jesus_row] = $jesus_christ[$jesus_row];
      for $jesus_column (1..($total_ind_count + 2)){
         if ($jesus_column <= $total_ind_count){
            $tiler->Manage( $tiler->Radiobutton(
                               -relief   => 'flat',
                               -variable => \$jesus_christ[$jesus_column],
                               -command => [\&jesus_inri],
                               -value    => $jesus_row)->pack(@global_pl));
         } else {
            if ($jesus_column == ($total_ind_count + 1)){
               $tiler->Manage( $tiler->Label(
                                  -text     => $total_ind_array[$jesus_row],
                                  -justify  => 'left',
                                  -relief   => 'flat')->pack(@global_pl));
            } else {
               $tiler->Manage( $tiler->Checkbutton(
                                      -variable => \$desc_or_not[$jesus_row],
	                              -relief   => 'flat')->pack(@global_pl));
            }
         }
      }
   }
   $tiler->pack();
   $bot_dialog->Show;
}

# Rest in Peace.  Do not disturb or dwell upon this code.
# It nearly finished me off.

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
}
1;
