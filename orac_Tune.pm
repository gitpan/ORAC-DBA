package orac_Tune;

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
sub roll_orac {
   package main;
   print TEXT "\nRollback Stats for $v_machine $v_db:\n\n";

   my $v_command = 
          orac_Utils::file_string('sql_files', 'orac_Tune',
                                  'roll_orac','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      print TEXT "@v_this_text\n" ;
   }
   $rc = $sth->finish;

   &see_plsql($v_command);
   printf TEXT 
     "\n%14s %4s %4s %5s %5s %3s %3s %6s %6s %6s %5s %3s %3s %5s %6s\n",
     '', ' ', '%', '', '', '', 'OPT', 'HI_WTR', '#', '#', 
     'AVGSZ', '#', '#', '', '';
   printf TEXT "%14s %4s %4s %5s %5s %3s " .
               "%3s %6s %6s %6s %5s %3s %3s %5s %6s\n\n",
               'ROLL_SEG_NAME', 'WAIT', 'WAIT', 'GETS', 
               'WRITE', 'MB', 'MB', 'MB', 'SHRINK',
               'EXTEND', 'ACTIV', 'EXT', 'TRN', 'WRAPS', 'AV_SHR';

   $v_command = 
          orac_Utils::file_string('sql_files', 'orac_Tune',
                                  'roll_orac','2','sql');

   my $scn_sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $scn_sth->execute;

   while (@v_this_text = $scn_sth->fetchrow) {
      printf TEXT "%14s %4d %4d %5s %5s %3d %3d " .
                  "%6d %6d %6d %5s %3d %3d %5d %6s\n",
         $v_this_text[0],
         $v_this_text[1],
         $v_this_text[2],
         $v_this_text[3],
         $v_this_text[4],
         $v_this_text[5],
         $v_this_text[6],
         $v_this_text[7],
         $v_this_text[8],
         $v_this_text[9],
         $v_this_text[10],
         $v_this_text[11],
         $v_this_text[12],
         $v_this_text[13],
         $v_this_text[14];
   }
   $rc = $scn_sth->finish;
   &see_plsql($v_command);
   printf TEXT   "\n%14s %15s %16s\n\n", 
                 'ROLL_SEG_NAME', 'TABLESPACE','STATUS';

   my $v_command = 
          orac_Utils::file_string('sql_files', 'orac_Tune',
                                  'roll_orac','3','sql');

   my $thi_sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $thi_sth->execute;

   while (@v_this_text = $thi_sth->fetchrow) {
      printf TEXT "%14s %15s %16s\n",
         $v_this_text[0],
         $v_this_text[1],
         $v_this_text[2];
   }
   $rc = $thi_sth->finish;
   &see_plsql($v_command);
   print TEXT "\n";

   my $v_command = 
          orac_Utils::file_string('sql_files', 'orac_Tune',
                                  'roll_orac','4','sql');

   my $fou_sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $fou_sth->execute;

   while (@v_this_text = $fou_sth->fetchrow) {
      print TEXT "@v_this_text\n";
   }
   $rc = $fou_sth->finish;
   print TEXT "\n";

   my $v_command = 
          orac_Utils::file_string('sql_files', 'orac_Tune',
                                  'roll_orac','5','sql');

   my $fif_sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $fif_sth->execute;

   while (@v_this_text = $fif_sth->fetchrow) {
      $v_this_text[0] = '';
      print TEXT "@v_this_text\n";
   }
   $rc = $fif_sth->finish;
   &see_plsql($v_command);
}
sub lock_orac {
   package main;
   printf TEXT "\nLock report for the $v_db database:\n\n" . 
      "%-16s  %-30s %10s %24s %10s %10s\n", 
      '------O/S-------', 
           '------------ORACLE------------', 
                '', 
                     '', 
                          '', 
                               'LOCK'; 
   printf TEXT 
      "%-10s %5s  %-15s %8s %5s %10s %24s %10s %10s\n", 
      'USERNAME', 'PID',
                'USERNAME', 'ID', 'SER',
                              'TYPE', 
                                   'OBJECT NAME', 
                                        'LOCK HELD', 
                                             'REQUESTED'; 
   printf TEXT 
      "%-16s  %-30s %10s %24s %10s %10s\n", 
      '----------------',
            '------------------------------',
                  '----------',
                       '------------------------',
                            '----------',
                                 '----------';
   my $v_command = 
          orac_Utils::file_string('sql_files', 'orac_Tune',
                                  'lock_orac','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $v_fetch_count = 0;
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      $v_fetch_count++;
      printf TEXT "%-16s  %-30s %10s %24s %10s %10s\n", 
         $v_this_text[0],
         $v_this_text[1],
         $v_this_text[2],
         $v_this_text[3],
         $v_this_text[4],
         $v_this_text[5];
   }
   $rc = $sth->finish;
   if($v_fetch_count == 0){
      print TEXT "no rows found\n";
   }
   &see_plsql($v_command);
}
sub nls_db_param_orac{
   package main;
   printf TEXT "\nNLS_DATABASE_PARAMETERS for $v_db database:\n\n" . 
      "%-30s %-30s\n", 'PARAMETER', 'VALUE';
   printf TEXT "%-30s %-30s\n", 
      '------------------------------',
      '------------------------------';

   my $v_command = 
          orac_Utils::file_string('sql_files', 'orac_Tune',
                                  'nls_db_param_orac','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      printf TEXT "%-30s %-30s\n",
         $v_this_text[0],
         $v_this_text[1];
   }
   $rc = $sth->finish;
   &see_plsql($v_command);
}
sub tab_shortage{
   package main;
   printf TEXT "\nTablespace Space Shortages for $v_db database:\n\n" . 
      "%-15s %10s %10s %10s %10s %10s\n\n",'Tablespace','File_Id','Tot_MB',
                                           'Ora_Blks','Tot_Used','Pct_Used';

   my $v_command = 
          orac_Utils::file_string('sql_files', 'orac_Tune',
                                  'tab_shortage','1','sql');
   $v_command =~ s/orac_insert_Block_Size/$Block_Size/g;

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      printf TEXT "%-15s %10d %10d %10d %10d %10d\n",
         $v_this_text[0],
         $v_this_text[1],
         $v_this_text[2],
         $v_this_text[3],
         $v_this_text[4],
         $v_this_text[5];
   }
   $rc = $sth->finish;
   &see_plsql($v_command);
}
sub defragger{
   package main;
   printf TEXT "\nTablespace Fragmentation for $v_db database:\n\n" . 
      "%-15s %10s %10s %10s %10s %10s %10s %8s\n\n", 
      'Tablespace', 'Blocks', 'Free', 'Pieces',
      'Biggest', 'Smallest', 'Average', 'Dead';

   my $v_command = 
          orac_Utils::file_string('sql_files', 'orac_Tune',
                                  'defragger','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      printf TEXT "%-15s %10d %10d %10d %10d %10d %10d %8d\n",
         $v_this_text[0],
         $v_this_text[1],
         $v_this_text[2],
         $v_this_text[3],
         $v_this_text[4],
         $v_this_text[5],
         $v_this_text[6],
         $v_this_text[7];
   }
   $rc = $sth->finish;
   &see_plsql($v_command);
}
sub nls_inst_param_orac{
   package main;
   printf TEXT "\nNLS_INSTANCE_PARAMETERS for $v_db database:\n\n" . 
      "%-30s %-30s\n", 'PARAMETER', 'VALUE';
   printf TEXT "%-30s %-30s\n", 
      '------------------------------',
      '------------------------------';

   my $v_command = 
          orac_Utils::file_string('sql_files', 'orac_Tune',
                                  'nls_inst_param_orac','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      printf TEXT "%-30s %-30s\n",
         $v_this_text[0],
         $v_this_text[1];
   }
   $rc = $sth->finish;
   &see_plsql($v_command);
}
sub nls_sess_param_orac{
   package main;
   printf TEXT "\nNLS_SESSION_PARAMETERS for $v_db database:\n\n" . 
      "%-30s %-30s\n", 'PARAMETER', 'VALUE';
   printf TEXT "%-30s %-30s\n", 
      '------------------------------',
      '------------------------------';

   my $v_command = 
          orac_Utils::file_string('sql_files', 'orac_Tune',
                                  'nls_sess_param_orac','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      printf TEXT "%-30s %-30s\n",
         $v_this_text[0],
         $v_this_text[1];
   }
   $rc = $sth->finish;
   &see_plsql($v_command);
}
sub vdoll_db_orac{
   package main;
   printf TEXT "\n" . 'v$database' . " information for $v_db:\n\n";

   my $v_command =
          orac_Utils::file_string('sql_files', 'orac_Tune',
                                  'vdoll_db_orac','1','sql');
   my @vdb_cols;
   my @vdb_selection;
   my @vdb_values;
   my $i_counter = 0;
   my $i_length = 0;

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@vdb_selection = $sth->fetchrow) {
      $vdb_cols[$i_counter] = $vdb_selection[0];
      $i_counter++;
   }
   $rc = $sth->finish;

   $v_command = 
          orac_Utils::file_string('sql_files', 'orac_Tune',
                                  'vdoll_db_orac','2','sql');

   $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@vdb_selection = $sth->fetchrow) {
      @vdb_values = @vdb_selection;
      $i_length = @vdb_selection;
   }
   $rc = $sth->finish;
   for ($i_counter = 0;$i_counter < $i_length;$i_counter++){
      orac_Tune::print_vdb($vdb_cols[$i_counter],$vdb_values[$i_counter]);
   }
   &see_plsql($v_command);
}
sub print_vdb {
   package main;
   my($col, $val, $dummy) = @_;
$^A = "";
$str = formline <<'END',$col, $val;
^>>>>>>>>>>>>>>>>>>>>>>> : ^<<<<<<<<<<<<<<<<<<<<<<< ~~
END
print TEXT "$^A";
}
      
sub vdoll_param_orac{
   package main;
   print TEXT "\n" . 'v$parameter' . " information for $v_db:\n\n";
   print TEXT "FLAGS=> ISDEFAULT:ISSES_MODIFIABLE:" .
              "ISSYS_MODIFIABLE:ISMODIFIED:ISADJUSTED\n";
   print TEXT "        (T = TRUE,F = FALSE,I = IMMEDIATE,D = DEFERRED)\n\n";
   orac_Tune::print_complex('NUM','TYP','FLAGS','NAME', 
                            'DESCRIPTION', 'VALUE');
   orac_Tune::print_complex('---','---','-----','----', 
                            '-----------', '-----');
   
   my $v_command =
          orac_Utils::file_string('sql_files', 'orac_Tune',
                                  'vdoll_param_orac','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      orac_Tune::print_complex(
            $v_this_text[0],
            $v_this_text[1],
            $v_this_text[2],
            $v_this_text[3],
            $v_this_text[4],
            $v_this_text[5]);
   }
   $rc = $sth->finish;
   &see_plsql($v_command);
}
 
sub print_complex {
   package main;
   my($num, $typ, $flags, $name, $desc, $value, $dummy) = @_;
$^A = "";
$str = formline <<'END',$num, $typ, $flags, $name, $desc, $value;
^<< ^<< ^<<<<<<<<  ^<<<<<<<<<<<<<<<<<<<<<<<<<<<  ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<  ^<<<<<<<<<<<<<<<<< ~~
END
print TEXT "$^A";
}
      
sub vdoll_param_simp{
   package main;
   print TEXT "\n" . 'Show Parameters' . " for $v_db:\n\n";
   print TEXT "                                     NAME  VALUE\n";
   print TEXT "-----------------------------------------  " .
              "-------------------------------------\n";

   my $v_command = 
          orac_Utils::file_string('sql_files', 'orac_Tune',
                                  'vdoll_param_simp','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      my $name = $v_this_text[0];
      my $value = $v_this_text[1];
$^A = "";
$str = formline <<'END',$name,$value;
^>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ~~
END
print TEXT "$^A";
      
   }

   # I can't remember why I did this, but there must've been
   # a reason, errrrr....?

   $rc = $sth->finish;
   &see_plsql($v_command);
}
sub dc_hit_ratio {
   package main;
   printf TEXT "\nCurrent data dictionary dc_hit_ratio for $v_db:\n\n" .
               "%-12s\n%-12s\n", 'DC_HIT_RATIO','------------';

   my $v_command =
          orac_Utils::file_string('sql_files', 'orac_Tune',
                                  'dc_hit_ratio','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      printf TEXT "%11.2f%%\n", $v_this_text[0];
   }
   print TEXT "\nOracle recommends trying to keep the hit ratio around " .
              "10-15%, or lower.  To improve dictionary cache performance, \n" .
              "you may want to add memory to the " .
              "shared pool by increasing the value " .
              "set for SHARED_POOL_SIZE.\n";

   $rc = $sth->finish;
   &see_plsql($v_command);
}
sub lc_hit_ratio {
   package main;
   printf TEXT "\nCurrent Library cache lc_hit_ratio for $v_db:\n\n" .
               "%-12s\n%-12s\n", 'LC_HIT_RATIO','------------';

   my $v_command =
          orac_Utils::file_string('sql_files', 'orac_Tune',
                                  'lc_hit_ratio','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      printf TEXT "%11.2f%%\n", $v_this_text[0];
   }
   print TEXT "\nIdeally, the library cache miss ratio should be under 1%.  " .
              "Otherwise, you may wish to increase the SHARED_POOL_SIZE \n" .
              "and/or the OPEN_CURSORS parameters.  Alternatively, get your " .
              "applications to use more identical SQL statements.\n";

   $rc = $sth->finish;
   &see_plsql($v_command);
}
sub latch_hit_ratio {
   package main;
   printf TEXT "\nCurrent Latch Wait ratios for $v_db:\n\n" .
               "%64s %10s %10s\n%64s %10s %10s\n", 
               'LATCH NAME', 'PID', 'WAIT_RATIO',
               '--------------------------------------' .
               '--------------------------', '---', '----------';

   my $v_command =
          orac_Utils::file_string('sql_files', 'orac_Tune',
                                  'latch_hit_ratio','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   my $counter = 0;
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      $counter++;
      printf TEXT 
         "%64s %10s %10.2f\n", 
         $v_this_text[0],
         $v_this_text[1],
         $v_this_text[2];
   }
   if ($counter == 0){
      print TEXT "no rows found\n";
   }
   print TEXT "\n" .
              "If the same process shows up " .
              "time and time again as holding the latch " .
              "named, and the wait ratio is " .
              "high for that\nlatch, then there could " .
              "be a problem with an event causing a wait on the system." .
              "\n";

   $rc = $sth->finish;
   &see_plsql($v_command);
}
sub act_latch_hit_ratio {
   package main;
   printf TEXT "\nProcesses experiencing waits for $v_db:\n\n" .
               "%64s %10s %10s\n%64s %10s %10s\n", 
               'LATCH NAME', 'PID', 'WAIT_RATIO',
               '----------------------------------------------------' .
               '------------', '---', '----------';

   my $v_command =
          orac_Utils::file_string('sql_files', 'orac_Tune',
                                  'act_latch_hit_ratio','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   my $counter = 0;
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      $counter++;
      printf TEXT 
         "%64s %10s %10.2f\n", 
         $v_this_text[0],
         $v_this_text[1],
         $v_this_text[2];
   }
   if ($counter == 0){
      print TEXT "no rows found\n";
   }
   $rc = $sth->finish;
   &see_plsql($v_command);
}
sub vdoll_version{
   package main;
   printf TEXT "\n" . 'v$version' . " information for $v_db:\n\n";

   $v_command = orac_Utils::file_string('sql_files', 'orac_Tune',
                                        'vdoll_version','1','sql');

   $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      print TEXT "@v_this_text\n";
   }
   $rc = $sth->finish;
   &see_plsql($v_command);
}
 
sub sgastat {
   package main;
   printf TEXT "\n" . 'v$sgastat' . " information for $v_db:\n\n";
   orac_Tune::print_sgastat('POOL','NAME','BYTES');
   orac_Tune::print_sgastat('----','----','-----');

   my $v_command =
          orac_Utils::file_string('sql_files', 'orac_Tune',
                                  'sgastat','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      orac_Tune::print_sgastat($v_this_text[0],
                               $v_this_text[1],
                               $v_this_text[2]);
   }
   $rc = $sth->finish;
   &see_plsql($v_command);
}
sub print_sgastat {
   package main;
   my($pool, $name, $bytes, $dummy) = @_;
$^A = "";
$str = formline <<'END',$pool, $name, $bytes;
^<<<<<<<<<<   ^<<<<<<<<<<<<<<<<<<<<<<<<<   ^>>>>>>>>> ~~
END
print TEXT "$^A";
}
      
1;
