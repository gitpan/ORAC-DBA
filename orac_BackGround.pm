package orac_BackGround;

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
use DBI;
use Tk::DialogBox;
sub dbwr_monitor {
   package main;

   my $v_command = orac_Utils::file_string('sql_files', 'orac_BackGround',
                                           'dbwr_monitor','1','sql');

   print TEXT "Monitoring DBWR Activity in $v_db\n\n";
   orac_BackGround::dbwr_print_act("Name", "Value");
   orac_BackGround::dbwr_print_act("----", "-----");

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   $buffer_scanned = 0.0;
   $lru_scans = 0.0;
   $free_buffers = 0.0;
   $make_free = 0.0;
   while (@v_this_text = $sth->fetchrow) {
      orac_BackGround::dbwr_print_act($v_this_text[0], $v_this_text[1]);
      if($v_this_text[0] =~ /^DBWR buffers scanned$/){
         $buffer_scanned = $v_this_text[1];
      }
      if($v_this_text[0] =~ /^DBWR lru scans$/){
         $lru_scans = $v_this_text[1];
      }
      if($v_this_text[0] =~ /^DBWR free buffers found$/){
         $free_buffers = $v_this_text[1];
      }
      if($v_this_text[0] =~ /^DBWR make free requests$/){
         $make_free = $v_this_text[1];
      }
   }
   $rc = $sth->finish;
   print TEXT "\n\nSecondary Values:\n\n";
   orac_BackGround::dbwr_print_act("Name", "Value");
   orac_BackGround::dbwr_print_act("----", "-----");
   if (($buffer_scanned != 0.0) && ($lru_scans != 0.0)){
      my $text = 'Average Number of Buffers being Scanned ' .
                 '(DBWR buffers scanned/DBWR lru scans)';
      orac_BackGround::dbwr_print_act($text, ($buffer_scanned/$lru_scans));
   }
   if (($free_buffers != 0.0) && ($make_free != 0.0)){
      my $text = 'Average Number of Free Buffers at the end of the LRU ' .
                 '(DBWR free buffers found/DBWR make free requests)';
      orac_BackGround::dbwr_print_act($text, ($free_buffers/$make_free));
   }
   main::see_plsql($v_command);
}
sub dbwr_print_act {
   package main;
   my($name, $value, $dummy) = @_;
$^A = "";
$str = formline <<'END',$name, $value;
^>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ~~
END
print TEXT "$^A";
      
}
sub dbwr_fileio {
   package main;
   my $this_title = "Orac DBWR I/O Report $v_machine $v_db";

   my $dialog = $top->DialogBox( 
      -title => $this_title, 
      -buttons => [ "Dismiss" ]);

   my $canvas_frame = $dialog->Frame;
   $canvas_frame->pack(-expand => '1', -fill => 'both');

   my $canvas = $canvas_frame->Scrolled('Canvas',
                                      -relief => 'sunken', 
                                      -background => $main::this_is_the_colour,
                                      -bd => 2, width => 700, height => 500);
   
   my $v_command = orac_Utils::file_string('sql_files', 'orac_BackGround',
                                           'dbwr_fileio','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;
   my $counter = 0;
   my $max_value = 0;
   my $i;
   while (@v_this_text = $sth->fetchrow) {
      $dbwr_fileio[$counter] = [ @v_this_text ];
      $counter++;
      for $i (0 .. 6){
         if ($v_this_text[$i] > $max_value){
            $max_value = $v_this_text[$i];
         }
      }
   }
   $rc = $sth->finish;
   if($counter > 0){
      $counter--;
      for $i (0 .. $counter){
         orac_BackGround::dbwr_print_fileio($canvas, $max_value, $i, 
         $dbwr_fileio[$i][0],
         $dbwr_fileio[$i][1],
         $dbwr_fileio[$i][2],
         $dbwr_fileio[$i][3],
         $dbwr_fileio[$i][4],
         $dbwr_fileio[$i][5],
         $dbwr_fileio[$i][6]);
      }
   }
   my $c_button = 
          $canvas->Button(
                     -text => 'See SQL',
                     -command => sub { main::banana_see_sql($v_command) } );

   my $y_start = orac_BackGround::this_pak_get_y(($counter + 1));
   $canvas->create('window', '1c', "$y_start" . 'c', -window => $c_button,
	           qw/-anchor nw -tags item/);
   $canvas->configure(-scrollregion => [ $canvas->bbox("all") ]);
   $canvas->pack(-expand => 'yes', -fill => 'both');
   $dialog->Show();
}
sub this_pak_get_y {
   my $input_y = $_[0];
   return (($input_y * 2.5) + 0.2);
}

sub dbwr_print_fileio {
   package main;
   my ($canvas,$max_value,$y_start,
       $name,$phyrds,$phywrts,$phyblkrd,$phyblkwrt,$readtim,$writetim) = @_;
   $stuff[1] = $phyrds;
   $stuff[2] = $phywrts;
   $stuff[3] = $phyblkrd;
   $stuff[4] = $phyblkwrt;
   $stuff[5] = $readtim;
   $stuff[6] = $writetim;
   my $local_max = $stuff[1];
   for $i (2 .. 6){
      if($stuff[$i] > $local_max){
         $local_max = $stuff[$i];
      }
   }
   $text_stuff[1] = "phyrds";
   $text_stuff[2] = "phywrts";
   $text_stuff[3] = "phyblkrd";
   $text_stuff[4] = "phyblkwrt";
   $text_stuff[5] = "readtim";
   $text_stuff[6] = "writetim";

   my $screen_ratio = 0.00;
   $screen_ratio = ($max_value/15.00);
   $text_name_start = 0.1;

   $x_start = 2;
   $y_start = orac_BackGround::this_pak_get_y($y_start);

   $act_figure_pos = $x_start + ($local_max/$screen_ratio) + 0.5;
   my $i;
   
   for $i (1 .. 6){
   
      $x_stop = $x_start + ($stuff[$i]/$screen_ratio);
      $y_end = $y_start + 0.2;

      $canvas->create(( 
          'rectangle', 
          "$x_start" . 'c', 
          "$y_start" . 'c', 
          "$x_stop" . 'c', 
          "$y_end" . 'c'),
          -fill => $main::this_is_the_forecolour);

      $text_y_start = $y_start - 0.15;

      $canvas->create(
           'text', 
           "$text_name_start" . 'c', 
           "$text_y_start" . 'c', 
           -anchor => 'nw',
           -justify => 'left',
           -text => "$text_stuff[$i]" , 
           -fill => $main::this_is_the_forecolour);

      $canvas->create(
            'text', 
            "$act_figure_pos" . 'c', 
            "$text_y_start" . 'c', 
            -anchor => 'nw',
            -justify => 'left',
            -text => "$stuff[$i]" , -fill => $main::this_is_the_forecolour);

      $y_start = $y_start + 0.3;
   }
   $text_y_start = $y_start - 0.10;

   $canvas->create(
      'text', 
      "$x_start" . 'c', 
      "$text_y_start" . 'c', 
      -anchor => 'nw',
      -justify => 'left',
      -text => "$name" , 
      -fill => $main::this_is_the_forecolour);
}

sub dbwr_lru_latch {
   package main;

   my $v_command = orac_Utils::file_string('sql_files', 'orac_BackGround',
                                           'dbwr_lru_latch','1','sql');

   print TEXT "LRU Latches in $v_db\n\n";
   orac_BackGround::dbwr_print_latch("Name", "Gets", "Misses", 
                                     "Sleeps", "Imgets", "Immisses", '');
   orac_BackGround::dbwr_print_latch("----", "----", "------", 
                                     "------", "------", "--------", '');
   
   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      my $the_end = '';
      if($v_this_text[0] =~ /^cache buffers lru chain$/){
         $v_this_text[6] = '(*LRU latches*)';
      }
      orac_BackGround::dbwr_print_latch( @v_this_text );
   }
   $rc = $sth->finish;
   main::see_plsql($v_command);
}
sub dbwr_print_latch {
   package main;
   ($name, $gets, $misses, $sleeps, $imgets, $immisses, $the_end) = @_;
#234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
$^A = "";
$str = formline <<'THISEND',$name,$gets,$misses,$sleeps,$imgets,$immisses,$the_end;
^>>>>>>>>>>>>>>>>>>>>>> ^>>>>>>>>>> ^>>>>>>>>>> ^>>>>>>>>>> ^>>>>>>>>>> ^>>>>>>>>>  ^<<<<<<<<<<<<<< ~~
THISEND
print TEXT "$^A";
      
}
sub lgwr_monitor {
   package main;

   my $v_command = orac_Utils::file_string('sql_files', 'orac_BackGround',
                                           'lgwr_monitor','1','sql');

   print TEXT "LGWR Monitoring the Redo Buffer in $v_db\n\n";
   orac_BackGround::lgwr_redo_buff("Name", "Value");
   orac_BackGround::lgwr_redo_buff("----", "----");
   
   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      orac_BackGround::lgwr_redo_buff( $v_this_text[0], $v_this_text[1]);
   }
   $rc = $sth->finish;
   main::see_plsql($v_command);
}
sub lgwr_redo_buff {
   package main;
   ($name, $value) = @_;
$^A = "";
$str = formline <<'END', $name, $value;
^>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ~~
END
print TEXT "$^A";
      
}
sub lgwr_buff_latch {
   package main;

   my $v_command = orac_Utils::file_string('sql_files', 'orac_BackGround',
                                           'lgwr_buff_latch','1','sql');

   print TEXT "Redo Log Buffer Latches in $v_db\n\n";
   orac_BackGround::lgwr_print_latch("Name", "Gets", "Misses", 
                                     "Imgets", "Immisses", '');
   orac_BackGround::lgwr_print_latch("----", "----", "------", 
                                     "------", "--------", '');
   
   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      my $the_end = '';
      if($v_this_text[0] =~ /^redo writing$/){
         $the_end = '(*Oracle8 latch*)';
      }
      orac_BackGround::lgwr_print_latch(
         $v_this_text[0],
         $v_this_text[1],
         $v_this_text[2],
         $v_this_text[3],
         $v_this_text[4],
         $the_end);
   }
   $rc = $sth->finish;
   main::see_plsql($v_command);
}
sub lgwr_print_latch {
   package main;
   ($name, $gets, $misses, $imgets, $immisses, $the_end) = @_;
$^A = "";
$str = formline <<'THISEND', $name,$gets,$misses, $imgets, $immisses, $the_end;
^>>>>>>>>>>>>>>>>>>>>>> ^>>>>>>>>>> ^>>>>>>>>>> ^>>>>>>>>>> ^>>>>>>>>>>  ^<<<<<<<<<<<<<<<< ~~
THISEND
print TEXT "$^A";
      
}
sub lgwr_and_dbwr_wait {
   package main;

   my $v_command = orac_Utils::file_string('sql_files', 'orac_BackGround',
                                           'lgwr_and_dbwr_wait','1','sql');

   print TEXT "DBWR & LGWR Waits in $v_db\n\n";
   orac_BackGround::dbwr_lgwr_wait_print("Event", "Total_Waits", "Time_Waited");
   orac_BackGround::dbwr_lgwr_wait_print("-----", "-----------", "-----------");
   
   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
     orac_BackGround::dbwr_lgwr_wait_print(
         $v_this_text[0],
         $v_this_text[1],
         $v_this_text[2]);
   }
   $rc = $sth->finish;
   main::see_plsql($v_command);
}
sub dbwr_lgwr_wait_print {
   package main;
   ($event, $total_waits, $time_waited) = @_;
$^A = "";
$str = formline <<'THISEND', $event, $total_waits, $time_waited;
^>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ^>>>>>>>>>>>>>>> ^>>>>>>>>>>>>>>> ~~
THISEND
print TEXT "$^A";
      
}
sub where_sorts {
   package main;

   my $v_command = orac_Utils::file_string('sql_files', 'orac_BackGround',
                                           'where_sorts','1','sql');

   print TEXT "SORT monitor for $v_db\n\n";
   orac_BackGround::sort_print("Name", "Value");
   orac_BackGround::sort_print("----", "-----");
   
   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
     orac_BackGround::sort_print(
         $v_this_text[0],
         $v_this_text[1]);
   }
   $rc = $sth->finish;
   main::see_plsql($v_command);
}
sub sort_print{
   package main;
   ($name, $value) = @_;
$^A = "";
$str = formline <<'THISEND', $name, $value;
^>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ^>>>>>>>>>>>>>>>>>> ~~
THISEND
print TEXT "$^A";
      
}
sub who_sorts {
   package main;

   my $v_command = orac_Utils::file_string('sql_files', 'orac_BackGround',
                                           'who_sorts','1','sql');

   print TEXT "Identifying SORT Users for $v_db\n\n";
   orac_BackGround::sort_who_print("Username", "Osuser", "Name", "Value");
   orac_BackGround::sort_who_print("--------", "------", "----", "-----");
   
   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
     orac_BackGround::sort_who_print(
         $v_this_text[0],
         $v_this_text[1],
         $v_this_text[2],
         $v_this_text[3]);
   }
   $rc = $sth->finish;
   main::see_plsql($v_command);
}
sub sort_who_print{
   package main;
   ($username, $osuser, $name, $value) = @_;
$^A = "";
$str = formline <<'THISEND', $username, $osuser, $name, $value;
^>>>>>>>>>>>>>>>>>>>>>>>> ^<<<<<<<<<<<<<<<<<<<  ^<<<<<<<<<<<<< ^>>>>>>>>> ~~
THISEND
print TEXT "$^A";
      
}
1;
