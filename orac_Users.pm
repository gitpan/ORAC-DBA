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
      printf TEXT "User Process SQL on $v_db:\n\n";
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
         orac_Users::print_what_sql( @v_this_text );
      }
      $rc = $sth->finish;
      &see_plsql($v_command);
   }
}
sub print_what_sql {
   package main;
   my($SID,$OSUser,$Username,$Machine,$Program,
      $Fground,$Bground,$Sql_Text) = @_;
#234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
$^A = "";
$str = formline <<'END',$SID,$OSUser,$Username,$Machine,$Program,$Fground,$Bground,$Sql_Text;
^>> ^<<<<<<< ^<<<<<<<<< ^<<<<<<<< ^<<<<<<<<<<< ^>>>>>> ^>>>>>> ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ~~
END
print TEXT "$^A";
}
sub user_io_orac {
   package main;
   printf TEXT "User Processes Currently Performing I/O on $v_db:\n\n";
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
      orac_Users::print_io_orace( @v_this_text );
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
   printf TEXT "Users Currently Updating $v_db:\n\n";
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
      orac_Users::print_upd_orace( @v_this_text );
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

   printf TEXT "Users Report - List of All Users\n\n";

   my @titles = ( 'Username', 'User_id', 'Default_tablespace', 
                  'Temporary_tablespace', 'Profile', 'Created');
   orac_Users::print_rep_users ( @titles );

   my @titles = ( '--------', '-------', '------------------', 
                  '--------------------', '-------', '-------');
   orac_Users::print_rep_users ( @titles );

   my $v_command =
          orac_Utils::file_string('sql_files', 'orac_Users',
                                  'user_rep_orac','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr;
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      orac_Users::print_rep_users ( @v_this_text );
   }
   $rc = $sth->finish;
   &see_plsql($v_command);
}
sub print_rep_users {
   package main;

   my ($Username,$User_id,$Df_tab,$Tmp_tab,$Prof,$Creat) = @_;

#234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
$^A = "";
$str = formline <<'END',$Username,$User_id,$Df_tab,$Tmp_tab,$Prof,$Creat;
^<<<<<<<<<<<<< ^>>>>>>> ^>>>>>>>>>>>>>>>>>>>>> ^>>>>>>>>>>>>>>>>>>> ^<<<<<<<<<<< ^>>>>>>>>> ~~
END
print TEXT "$^A";
}

sub role_rep_orac {
   package main;
   printf TEXT "Role Report - List of All Roles\n\n";

   my @titles = ( 'Role', 'Password Protected', 'Grantee', 
                  'Admin Option', 'Default Role?');
   orac_Users::print_rol_rep ( @titles );

   my @titles = ( '----', '---------', '-------', 
                  '------', '-------');
   orac_Users::print_rol_rep ( @titles );

   my $v_command =
          orac_Utils::file_string('sql_files', 'orac_Users',
                                  'role_rep_orac','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr;
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      orac_Users::print_rol_rep ( @v_this_text );
   }
   $rc = $sth->finish;
   &see_plsql($v_command);
}
sub print_rol_rep {
   package main;

   my($Role, $Password, $Grantee, $Admin, $Default) = @_;

#234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
$^A = "";
$str = formline <<'END',$Role,$Password,$Grantee,$Admin,$Default;
^<<<<<<<<<<<<<<<<<<<<<<<<<< ^>>>>>>>> ^>>>>>>>>>>>>>>>>>>>>>>>>>> ^>>>>> ^>>>>>> ~~
END
print TEXT "$^A";
}

sub curr_users_orac {
   package main;
   printf TEXT "Current Database Users on " .
               "$v_db:\n\n";

   my @titles = ('Oracle Username', 'O/S Username', 'Sid', 'Stat', 
                 'Type', 'O/S Pid', 'Term', 'Lock Wait', 'Command');
   orac_Users::print_curr_users ( @titles );

   my @titles = ('---------------', '------------', '---', '----', 
                 '----', '-------', '----', '---------', '-------');
   orac_Users::print_curr_users ( @titles );

   my $v_command =
          orac_Utils::file_string('sql_files', 'orac_Users',
                                  'curr_users_orac','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr;
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      orac_Users::print_curr_users ( @v_this_text );
   }
   $rc = $sth->finish;

   &see_plsql($v_command);
}
sub print_curr_users {
   package main;

   my($Ora_Use, $OS_Use, $Sid, $Stat, $Typ, $Pid, $Trm, $Lck, $Comm) = @_;

#234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
$^A = "";
$str = formline <<'END',$Ora_Use,$OS_Use,$Sid,$Stat,$Typ,$Pid,$Trm,$Lck,$Comm;
^<<<<<<<<<<<<<< ^>>>>>>>>>>> ^>>>> ^<<<<<<< ^<<<<< ^>>>>>> ^>>>>>>>>>>>> ^>>>>>>>> ^>>>>>>>>>>>>> ~~
END
print TEXT "$^A";
}

sub prof_rep_orac {
   package main;

   printf TEXT "Profile Report - List of All Profiles\n\n";

   my @titles = ('Profile_Name', 'Resource_Name', 'Limit');
   orac_Users::print_profs ( @titles );

   my @titles = ('------------', '-------------', '-----');
   orac_Users::print_profs ( @titles );

   my $v_command =
          orac_Utils::file_string('sql_files', 'orac_Users',
                                  'prof_rep_orac','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr;
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      orac_Users::print_profs ( @v_this_text );
   }
   $rc = $sth->finish;
   &see_plsql($v_command);
}
sub print_profs {
   package main;

   my($prof, $res, $limit) = @_;

#234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
$^A = "";
$str = formline <<'END',$prof, $res, $limit;
^<<<<<<<<<<<<<<<<<<<<<<<< ^<<<<<<<<<<<<<<<<<<<<<<<< ^>>>>>>>>>>>>>>>>>>>>>>>> 
END
print TEXT "$^A";
}

sub quot_rep_orac {
   package main;
   printf TEXT "Quota Report\n\n";

   my @titles = ('UserName', 'TableSpace Name', 'MB Quota', 'Max MB Quota');
   orac_Users::print_quot ( @titles );

   my @titles = ('--------', '---------------', '--------', '------------');
   orac_Users::print_quot ( @titles );

   my $v_command =
          orac_Utils::file_string('sql_files', 'orac_Users',
                                  'quot_rep_orac','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr;
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      orac_Users::print_quot ( @v_this_text );
   }
   $rc = $sth->finish;
   &see_plsql($v_command);
}
sub print_quot {
   package main;

   my($user, $tabsp, $mb, $maxmb) = @_;

#234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
$^A = "";
$str = formline <<'END',$user, $tabsp, $mb, $maxmb;
^<<<<<<<<<<<<<<<<<<<<< ^>>>>>>>>>>>>>>>>>>>>> ^>>>>>>>>>>>>>> ^>>>>>>>>>>>>>>
END
print TEXT "$^A";
}

1;
