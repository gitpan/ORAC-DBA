package orac_Users;

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
use Tk::Balloon;
sub what_sql {
   package main;
   my $dialog_text =
      "This Report could take SOME TIME to run on a " .
      "busy database.\nAre you sure you wish to run it?";

   my $check_dialog = $top->DialogBox( -title => "Orac Dialog",
                                       -buttons => [ "Yes", "No" ]);

   $check_dialog->add("Label", -text => $dialog_text)->pack();
   my $button = $check_dialog->Show;
   if($button eq 'Yes'){
      printf TEXT "\nUser Process SQL on $v_db:\n\n";
      orac_Users::print_what_sql('SID','OSUser','Username',
                                 'Machine','Program','Fground',
                                 'Bground','Sql_Text');
      orac_Users::print_what_sql('---','------','--------',
                                 '-------','-------','-------',
                                 '-------','--------');
      my $v_command =
          orac_Utils::file_string('sql_files', 'orac_Users',
                                  'what_sql','1','sql');

      my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr;
      $rv = $sth->execute;

      while (@v_this_text = $sth->fetchrow) {
         orac_Users::print_what_sql($v_this_text[0],
                                     $v_this_text[1],
                                     $v_this_text[2],
                                     $v_this_text[3],
                                     $v_this_text[4],
                                     $v_this_text[5],
                                     $v_this_text[6],
                                     $v_this_text[7]);
      }
      $rc = $sth->finish;
      &see_plsql($v_command);
   }
}
sub print_what_sql {
   package main;
   my($SID,$OSUser,$Username,$Machine,$Program,
      $Fground,$Bground,$Sql_Text) = @_;
$^A = "";
$str = formline <<'END',$SID,$OSUser,$Username,$Machine,$Program,$Fground,$Bground,$Sql_Text;
^>> ^<<<<<<<< ^<<<<<<<<<< ^<<<<<<<<< ^<<<<<<<<<<< ^>>>>>> ^>>>>>> ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ~~
END
print TEXT "$^A";
}
sub user_io_orac {
   package main;
   printf TEXT "\nUser Processes Currently Performing I/O on $v_db:\n\n";
   orac_Users::print_io_orace('SID','OSUser','Username',
                              'Log_Reads','Phy_Reads','Ratio','Phy_Writes');
   orac_Users::print_io_orace('---','------','--------',
                              '---------','---------','-----','----------');
   my $v_command =
          orac_Utils::file_string('sql_files', 'orac_Users',
                                  'user_io_orac','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr;
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      orac_Users::print_io_orace($v_this_text[0],
                                  $v_this_text[1],
                                  $v_this_text[2],
                                  $v_this_text[3],
                                  $v_this_text[4],
                                  $v_this_text[5],
                                  $v_this_text[6]);
   }
   $rc = $sth->finish;
   &see_plsql($v_command);
}
sub print_io_orace {
   package main;
   my($SID,$OSUser,$Username,$Log_Reads,$Phy_Reads,$Ratio,$Phy_Writes) = @_;
$^A = "";
$str = formline <<'END',$SID,$OSUser,$Username,$Log_Reads,$Phy_Reads,$Ratio,$Phy_Writes;
^>>> ^<<<<<<<<<<<<<< ^<<<<<<<<<<<<<<<< ^>>>>>>>> ^>>>>>>>> ^>>>>>>> ^>>>>>>>>> ~~
END
print TEXT "$^A";
}
sub user_upd_orac {
   package main;
   printf TEXT "\nUsers Currently Updating $v_db:\n\n";
   orac_Users::print_upd_orace('ID','Seg','OSuser','Username',
                               'SID','Extents','Extends',
                               'Waits','Shrinks','Wraps');
   orac_Users::print_upd_orace('--','---','------','--------',
                               '---','-------','-------',
                               '-----','-------','-----');
   my $v_command =
          orac_Utils::file_string('sql_files', 'orac_Users',
                                  'user_upd_orac','1','sql');

   # Help!

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr;
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      orac_Users::print_upd_orace($v_this_text[0],
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
   &see_plsql($v_command);
}
sub print_upd_orace {
   package main;
   my($ID,$Seg,$OSuser,$Username,$SID,
      $Extents,$Extends,$Waits,$Shrinks,$Wraps) = @_;
$^A = "";
$str = formline <<'END',$ID,$Seg,$OSuser,$Username,$SID,$Extents,$Extends,$Waits,$Shrinks,$Wraps;
^>> ^<<<<<<<<< ^<<<<<<<<<<< ^<<<<<<<<<<<<< ^>>>> ^>>>>>> ^>>>>>> ^>>>>> ^>>>>>> ^>>>> ~~
END
print TEXT "$^A";
}
sub user_rep_orac {
   package main;
   printf TEXT "\nUsers Report - List of All Users " .
               "in $v_db:\n\n%-15s %7s %20s %20s %20s %15s\n\n",
      'USERNAME', 'USER_ID', 'DEFAULT_TABLESPACE', 
      'TEMPORARY_TABLESPACE', 'PROFILE', 'CREATED';

   my $v_command =
          orac_Utils::file_string('sql_files', 'orac_Users',
                                  'user_rep_orac','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr;
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      printf TEXT "%-15s %7s %20s %20s %20s %15s\n",
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
sub role_rep_orac {
   package main;
   printf TEXT "\nRole Report - List of All Roles " .
               "in $v_db:\n\n%-27s %9s %15s %6s %7s\n",
      '', 'PASSWORD', '', 'ADMIN', 'DEFAULT';

   printf TEXT "%-27s %9s %15s %6s %7s\n\n",
      'ROLE', 'PROTECTED', 'GRANTEE', 'OPTION', 'ROLE?';

   my $v_command =
          orac_Utils::file_string('sql_files', 'orac_Users',
                                  'role_rep_orac','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr;
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      printf TEXT "%-27s %9s %15s %6s %7s\n",
         $v_this_text[0],
         $v_this_text[1],
         $v_this_text[2],
         $v_this_text[3],
         $v_this_text[4];
      }
   $rc = $sth->finish;
   &see_plsql($v_command);
}
sub curr_users_orac {
   package main;
   printf TEXT "\nCurrent Database Users on " .
               "$v_db:\n\n%-12s %8s %5s %5s %4s %6s %10s %4s %12s\n",
      'ORACLE', 'O/S', ' ', ' ', ' ', 'O/S', ' ', 'LOCK', ' ';

   printf TEXT "%-12s %8s %5s %5s %4s %6s %10s %4s %12s\n\n",
      'USERNAME', 'USERNAME', 'SID', 'STAT', 
      'TYPE', 'PID', 'TERM', 'WAIT', 'COMMAND';

   my $v_command =
          orac_Utils::file_string('sql_files', 'orac_Users',
                                  'curr_users_orac','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr;
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      printf TEXT "%-12s %8s %5s %5s %4s %6s %10s %4s %12s\n",
         $v_this_text[0],
         $v_this_text[1],
         $v_this_text[2],
         $v_this_text[3],
         $v_this_text[4],
         $v_this_text[5],
         $v_this_text[6],
         $v_this_text[7],
         $v_this_text[8];
      }
   $rc = $sth->finish;
   &see_plsql($v_command);
}
sub prof_rep_orac {
   package main;
   printf TEXT "\nProfile Report - List of All Profiles\n\n%-15s %25s %20s\n",
      'PROFILE', 'RESOURCE', '';
   printf TEXT "%-15s %25s %20s\n\n",
      'NAME', 'NAME', 'LIMIT';

   my $v_command =
          orac_Utils::file_string('sql_files', 'orac_Users',
                                  'prof_rep_orac','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr;
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      printf TEXT "%-15s %25s %20s\n",
         $v_this_text[0],
         $v_this_text[1],
         $v_this_text[2];
      }
   $rc = $sth->finish;
   &see_plsql($v_command);
}
sub quot_rep_orac {
   package main;
   printf TEXT "\nQuota Report\n\n%-15s %15s %10s %10s\n",
      '', 'TABLESPACE', 'MB', 'MAX_MB';
   printf TEXT "%-15s %15s %10s %10s\n\n",
      'USERNAME', 'NAME', 'QUOTA', 'QUOTA';

   my $v_command =
          orac_Utils::file_string('sql_files', 'orac_Users',
                                  'quot_rep_orac','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr;
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      printf TEXT "%-15s %15s %10d %10s\n",
         $v_this_text[0],
         $v_this_text[1],
         $v_this_text[2],
         $v_this_text[3];
      }
   $rc = $sth->finish;
   &see_plsql($v_command);
}
1;
