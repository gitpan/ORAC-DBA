package orac_Wait;

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
sub who_logged_on {
   package main;

   my $v_command =
          orac_Utils::file_string('sql_files', 'orac_Wait',
                                  'who_logged_on','1','sql');

   print TEXT "Who's logged on? in $v_db\n\n";
   orac_Wait::who_logged_hold( "OS_UserCode","Oracle_UserCode","Serial",
                               "Sid","F_Ground","B_Ground");
   orac_Wait::who_logged_hold( "-----------","---------------","------",
                               "---","--------","--------");
   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;
   my $v_fetch_count = 0;
   while (@v_this_text = $sth->fetchrow) {
      $v_fetch_count++;
      orac_Wait::who_logged_hold( $v_this_text[0],
                                  $v_this_text[1],
                                  $v_this_text[2],
                                  $v_this_text[3],
                                  $v_this_text[4],
                                  $v_this_text[5]);
   }
   $rc = $sth->finish;
   if($v_fetch_count == 0){
      print TEXT "no rows found\n";
   }
   &see_plsql($v_command);
}
sub who_logged_hold {
   package main;
   my($OS_UserCode,$Oracle_UserCode,$Ora_Serial,
      $Oracle_Sid,$F_Ground,$B_Ground,$dummy) = @_;
$^A = "";
$str = formline <<'END',$OS_UserCode,$Oracle_UserCode,$Ora_Serial,$Oracle_Sid,$F_Ground,$B_Ground;
^<<<<<<<<<<<<<<<< ^<<<<<<<<<<<<<<<<<<<< ^>>>>>> ^>>>>>>> ^>>>>>>>>>> ^>>>>>>>>>> ~~
END
print TEXT "$^A";
}
sub lock_objects {
   package main;

   my $v_command =
          orac_Utils::file_string('sql_files', 'orac_Wait',
                                  'lock_objects','1','sql');

   my $access_text =
          orac_Utils::file_string('help_files', 'orac_Wait',
                                  'who_logged_on','1','help');

   print TEXT $access_text;
   orac_Wait::who_locked_obj("OSUser","UserName","Serial",
                             "Sid","Owner.Object","Lock_Mode");
   orac_Wait::who_locked_obj("------","--------","------",
                             "---","------------","---------");
   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;
   my $v_fetch_count = 0;
   while (@v_this_text = $sth->fetchrow) {
      $v_fetch_count++;
      $v_this_text[5] = '=> ' . $v_this_text[5];
      orac_Wait::who_locked_obj( $v_this_text[0],
                                 $v_this_text[1],
                                 $v_this_text[2],
                                 $v_this_text[3],
                                 $v_this_text[4],
                                 $v_this_text[5]);
   }
   $rc = $sth->finish;
   if($v_fetch_count == 0){
      print TEXT "no rows found\n";
   }
   &see_plsql($v_command);
}
sub who_locked_obj {
   package main;
   my($osuser,$username,$serial,$sid,$object_owner,$lock_mode,$dummy) = @_;
$^A = "";
$str = formline <<'END',$osuser,$username,$serial,$sid,$object_owner,$lock_mode;
^<<<<<<<<<<< ^<<<<<<<<<<<<< ^>>>>> ^>>>> ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ^<<<<<<<<<<<<<<<<< ~~
END
print TEXT "$^A";
}
sub rollback_locks {
   package main;

   my $v_command =
          orac_Utils::file_string('sql_files', 'orac_Wait',
                                  'rollback_locks','1','sql');

   print TEXT "Rollback Locks? in $v_db\n\n";
   orac_Wait::roll_print( 
      "Usn","Name","OSUser","UserName",
      "Serial","Sid","Extents","Extends","Waits","Shrinks","Wraps");
   orac_Wait::roll_print( 
      "---","----","------","--------",
      "------","---","-------","-------","-----","-------","-----");

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   my $v_fetch_count = 0;
   while (@v_this_text = $sth->fetchrow) {
      $v_fetch_count++;
      orac_Wait::roll_print( $v_this_text[0],
                             $v_this_text[1],
                             $v_this_text[2],
                             $v_this_text[3],
                             $v_this_text[4],
                             $v_this_text[5],
                             $v_this_text[6],
                             $v_this_text[7],
                             $v_this_text[8],
                             $v_this_text[9],
                             $v_this_text[10]);
   }
   $rc = $sth->finish;
   if($v_fetch_count == 0){
      print TEXT "no rows found\n";
   }
   &see_plsql($v_command);
}
sub roll_print {
   package main;
   my($usn,$name,$osuser,$username,$serial,
      $sid,$extents,$extends,$waits,$shrinks,$wraps) = @_;
$^A = "";
$str = formline <<'END',$usn,$name,$osuser,$username,$serial,$sid,$extents,$extends,$waits,$shrinks,$wraps;
^<<<<<<<<<< ^<<<<<<<<<< ^<<<<<<<<<<< ^<<<<<<<<<<<<< ^>>>>> ^>>>> ^>>>>>> ^>>>>>> ^>>>> ^>>>>>> ^>>>> ~~
END
print TEXT "$^A";
}
sub tune_wait {
   package main;

   my $v_command = orac_Utils::file_string('sql_files', 'orac_Wait',
                                           'tune_wait','1','sql');

   $dbh->func(1000000, 'dbms_output_enable');
   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   my $rv = $sth->execute;
   my $j_counter = 0;
   my $my_god;
   my @this_banana;
   my $lots_of_blanks = 0;
   while($j_counter < 2000){
      $_ = scalar $dbh->func('dbms_output_get');
      print TEXT "$_\n";
      $my_god = length($_);
      if ($my_god == 0){
         $lots_of_blanks++;
         if ($lots_of_blanks > 10){
            last;
         }
      }
      else {
         $lots_of_blanks = 0;
      }
      $j_counter++;
   }
   &see_plsql($v_command);
}
sub wait_hold {
   package main;

   my $v_command =
          orac_Utils::file_string('sql_files', 'orac_Wait',
                                  'wait_hold','1','sql');

   print TEXT "Waiting and Holding Activity in $v_db\n\n";

   orac_Wait::print_wait_hold( 
           0, "WAITING User","OS User","Serial","Sid","PID",
           "HOLDING User","OS User","Serial","Sid","PID");
   orac_Wait::print_wait_hold( 
           0, "------------","-------","------","---","---",
           "------------","-------","------","---","---");

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;
   my $v_fetch_count = 0;
   while (@v_this_text = $sth->fetchrow) {
      $v_fetch_count++;
      orac_Wait::print_wait_hold( 1,
                                  $v_this_text[0],
                                  $v_this_text[1],
                                  $v_this_text[2],
                                  $v_this_text[3],
                                  $v_this_text[4],
                                  $v_this_text[5],
                                  $v_this_text[6],
                                  $v_this_text[7],
                                  $v_this_text[8],
                                  $v_this_text[9]);
   }
   $rc = $sth->finish;
   if($v_fetch_count == 0){
      print TEXT "no rows found\n";
   }
   &see_plsql($v_command);
}
sub print_wait_hold {
   package main;

   my($flag,$wt_user,$wt_os_user,$wt_serial,
      $wt_sid,$wt_pid,$hd_user,$hd_os_user,
      $hd_serial,$hd_sid,$hd_pid,$dummy) = @_;

   my $whatter = $hd_os_user;
   my $oracle_whatter = $hd_user;
   my $oracle_sid = $hd_sid;

$^A = "";
$str = formline <<'END',$wt_user,$wt_os_user,$wt_serial,$wt_sid,$wt_pid,$hd_user,$hd_os_user,$hd_serial,$hd_sid,$hd_pid;
^<<<<<<<<<<< ^<<<<<<< ^>>>>> ^>>>> ^>>>>    ^<<<<<<<<<<< ^<<<<<<< ^>>>>> ^>>>> ^>>>> ~~
END
chomp($^A);
print TEXT "$^A";
      
   if ($flag == 1){
      my $v_bouton = 
           $v_text->Button(
             -text => "What is $whatter doing today, as $oracle_whatter?",
             -command => sub { $top->Busy;
                               orac_Wait::who_what($whatter, 
                                                   $oracle_whatter, 
                                                   $oracle_sid);
                               $top->Unbusy },
	     -cursor  => 'top_left_arrow',
             -padx => 0,
             -pady => 0,
             -font => '-adobe-helvetica-medium-r-normal--8-80-75-75-p-46-*-1');

      $v_text->window('create', 'end', -window => $v_bouton);
   }
   print TEXT "\n";
}
sub who_what {
   package main;
   my ($os_user,$oracle_user,$sid, $dummy) = @_;
   my $dialog = $top->DialogBox( -title   => "Orac Investigation on $os_user",
                                 -buttons => [ "Dismiss" ]);
   my $loc_text = $dialog->Scrolled(
                  'Text', 
                  background => $main::this_is_the_colour,
                  foreground => $main::this_is_the_forecolour);

   $loc_text->pack(-expand => 1, -fil => 'both');
   tie (*THIS_TIME_TEXT, 'Tk::Text', $loc_text);

   my $v_command =
          orac_Utils::file_string('sql_files', 'orac_Wait',
                                  'who_what','1','sql');
   $v_command =~ s/orac_insert_os_user/$os_user/g;
   $v_command =~ s/orac_insert_oracle_user/$oracle_user/g;
   $v_command =~ s/orac_insert_sid/$sid/g;

   print THIS_TIME_TEXT "What is $os_user doing today?\n\n\n";

   orac_Wait::print_whatter1("Sid","UserName","OSUser","Machine",
                             "Program", "F_Ground","B_Ground");
   orac_Wait::print_whatter1("-----","----------","--------",
                            "----------","-------------------",
                            "---------","---------");
   orac_Wait::print_whatter2("SQL_Text");
   orac_Wait::print_whatter2("------------------------------------");
   print THIS_TIME_TEXT "\n";

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   my $v_fetch_count = 0;
   while (@v_this_text = $sth->fetchrow) {
      $v_fetch_count++;
      orac_Wait::print_whatter1( $v_this_text[0],
                                 $v_this_text[1],
                                 $v_this_text[2],
                                 $v_this_text[3],
                                 $v_this_text[4],
                                 $v_this_text[5],
                                 $v_this_text[6]);
      print THIS_TIME_TEXT "\n";
      orac_Wait::print_whatter2( $v_this_text[7]);
   }
   $rc = $sth->finish;
   if($v_fetch_count == 0){
      print THIS_TIME_TEXT "no rows found\n";
   }
   my $v_bouton = 
       $loc_text->Button(-text => "See SQL",
                         -command => sub { $top->Busy;
                                           &see_sql($v_command);
                                           $top->Unbusy },
	                 -cursor  => 'top_left_arrow');

   print THIS_TIME_TEXT "\n\n  ";

   $loc_text->window('create', 'end', -window => $v_bouton);
   print THIS_TIME_TEXT "\n\n";

   $dialog->Show;
}
sub print_whatter1 {
   package main;
   my($sid,$username,$osuser,$machine,$program,
      $f_ground,$b_ground,$dummy) = @_;
$^A = "";
$str = formline <<'END',$sid,$username,$osuser,$machine,$program,$f_ground,$b_ground;
^<<<< ^<<<<<<<<< ^<<<<<<< ^<<<<<<<<< ^<<<<<<<<<<<<<<<<<<   ^<<<<<<<< ^<<<<<<<< ~~
END
print THIS_TIME_TEXT "$^A";
}
sub print_whatter2 {
   package main;
   my($sql_text,$dummy) = @_;
$^A = "";
$str = formline <<'END',$sql_text;
^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ~~
END
print THIS_TIME_TEXT "$^A";
}
1;
