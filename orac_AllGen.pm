package orac_AllGen; 

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
use Tk::HList;
sub all_grants {
   package main;
   print 
      TEXT "rem  All the Grants statements in " .
           "the $v_db database,\nrem  except " .
           "those granted by the SYS user.\n\n";

   my $v_command = orac_Utils::file_string('sql_files', 'orac_AllGen',
                                           'all_grants','1','sql');

   $dbh->func(100000, 'dbms_output_enable');
   my $second_sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   my $second_rv = $second_sth->execute;

   my $j_counter = 0;
   my $full_list;
   while($j_counter < 20000){
      $full_list = scalar $dbh->func('dbms_output_get');
      $my_god = length($full_list);
      if ($my_god == 0){
         last;
      }
      $full_list =~ s/ as / as \n/g;
      unless ($full_list =~ /alter user/){
         print TEXT "$full_list\n";
      }
      $j_counter++;
   }
   &see_plsql($v_command);
}
sub all_syns {
   package main;
   print TEXT "rem  All the Grants " .
              "statements in the $v_db " .
              "database,\nrem  except " .
              "those granted by the SYS user.\n\n";

   my $v_command = orac_Utils::file_string('sql_files', 'orac_AllGen',
                                           'all_syns','1','sql');

   $dbh->func(100000, 'dbms_output_enable');
   my $second_sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   my $second_rv = $second_sth->execute;

   my $j_counter = 0;
   my $full_list;
   while($j_counter < 20000){
      $full_list = scalar $dbh->func('dbms_output_get');
      $my_god = length($full_list);
      if ($my_god == 0){
         last;
      }
      $full_list =~ s/ as / as \n/g;
      unless ($full_list =~ /alter user/){
         print TEXT "$full_list\n";
      }
      $j_counter++;
   }
   &see_plsql($v_command);
}
1;
