package orac_Secur;   

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
sub grant_orac {
   package main;
   printf TEXT "\nDirect Object Grants " .
               "for $v_db:\n\n%4s %14s %29s %18s %10s\n\n", 
               'LVL', 'OWNER', 'TABLE_NAME', 'GRANTEE', 'PRIVILEGE';
   
   my $v_command = orac_Utils::file_string('sql_files', 'orac_Secur',
                                           'grant_orac', '1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      printf TEXT "%4s %14s %29s %18s %10s\n", 
         $v_this_text[0],
         $v_this_text[1],
         $v_this_text[2],
         $v_this_text[3],
         $v_this_text[4];
      }
   $rc = $sth->finish;
   &see_plsql($v_command);
}
sub user_orac {
   package main;
   printf TEXT "\nAll Privs Report for $v_db:\n\n%-8s %24s %4s %9s %30s\n\n", 
               'LEVEL', 'PRIVILEGE', 'GRANTABLE', 'OWNER', 'TABLE_NAME';
   
   my $v_command = orac_Utils::file_string('sql_files', 'orac_Secur',
                                           'user_orac', '1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      printf TEXT "%-8s %24s %4s %9s %30s\n", 
         $v_this_text[0],
         $v_this_text[1],
         $v_this_text[2],
         $v_this_text[3],
         $v_this_text[4];
      }
   $rc = $sth->finish;
   &see_plsql($v_command);
}
sub table_orac {
   package main;
   printf TEXT "\nTable Grants for $v_db:\n\n%10s %18s %35s %10s %10s %3s\n\n",
      'GRANTOR', 'GRANTEE', 'TABLE_NAME', 'PRIVILEGE', 'OWNER', 'GRANTABLE';
   
   my $v_command = orac_Utils::file_string('sql_files', 'orac_Secur',
                                           'table_orac', '1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      printf TEXT "%10s %18s %35s %10s %10s %3s\n",
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
1;
