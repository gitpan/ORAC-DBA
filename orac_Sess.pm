package orac_Sess;

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
sub conn_orac {
   package main;
   printf TEXT "\nConnections\n\n%5s %5s %5s %10s %10s %20s %20s\n\n", 
               'PID', 'SPID', 'SID', 'ORA_USER', 'UNIX_USER', 
               'WHEN_USER_LOGGED_ON', 'WHEN_LAST_ACTIVITY';
   
   my $v_command = orac_Utils::file_string('sql_files', 'orac_Sess',
                                           'conn_orac', '1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      printf TEXT "%5s %5s %5s %10s %10s %20s %20s\n", 
         $v_this_text[0],
         $v_this_text[1],
         $v_this_text[2],
         $v_this_text[3],
         $v_this_text[4],
         $v_this_text[5],
         $v_this_text[6];
      }
   $rc = $sth->finish;
   &see_plsql($v_command);
}
sub spin_orac {
   package main;

   my $first_sth = $dbh->prepare(
         orac_Utils::file_string('sql_files','orac_Sess','spin_orac','1','sql')
                                ) || die $dbh->errstr;
   $rv = $first_sth->execute;

   $v_counter = 0;
   while ($v_this_text = $first_sth->fetchrow) {
      $v_this_text[$v_counter] = $v_this_text;
      $v_counter++;
   }
   $rc = $first_sth->finish;
   printf TEXT "\nProcesses\n\n%8s %3s %5s %8s %7s %12s %30s %10s %9s %9s\n\n", 
      $v_this_text[0],
      $v_this_text[1],
      $v_this_text[2],
      $v_this_text[3],
      $v_this_text[4],
      $v_this_text[5],
      $v_this_text[6],
      $v_this_text[7],
      $v_this_text[8],
      $v_this_text[9];
   
   my $v_command =
         orac_Utils::file_string('sql_files','orac_Sess','spin_orac','2','sql');

   my $sth = $dbh->prepare($v_command) || die $dbh->errstr;
   
   $rv = $sth->execute;
   while (@v_this_text = $sth->fetchrow) {
      printf TEXT "%8s %3s %5s %8s %7s %12s %30s %10s %9s %9s\n", 
         $v_this_text[0],
         $v_this_text[1],
         $v_this_text[2],
         $v_this_text[3],
         $v_this_text[4],
         $v_this_text[5],
         $v_this_text[6],
         $v_this_text[7],
         $v_this_text[8],
         $v_this_text[9];
      }
   $rc = $sth->finish;
   &see_plsql($v_command);
}
1;
