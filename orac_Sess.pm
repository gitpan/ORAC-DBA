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

sub print_conn {
   package main;
   my($Pid,$Spid,$Sid,$Ora,$Unix,$Log,$Last) = @_;
#234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
$^A = "";
$str = formline <<'END',$Pid,$Spid,$Sid,$Ora,$Unix,$Log,$Last;
^<<<< ^>>>> ^>>>> ^>>>>>>>>>>>>> ^>>>>>>>>>>>>> ^>>>>>>>>>>>>>>>>>>>> ^>>>>>>>>>>>>>>>>>>> ~~
END
print TEXT "$^A";
}
sub conn_orac {
   package main;
   printf TEXT "Connection Times\n\n";

   orac_Sess::print_conn('Pid', 'Spid', 'Sid', 'Ora User', 'Unix User', 
                         'When User Logged On', 'When Last Activity');
   orac_Sess::print_conn('---', '----', '---', '--------', '---------', 
                         '-------------------', '------------------');
   
   my $v_command = orac_Utils::file_string('sql_files', 'orac_Sess',
                                           'conn_orac', '1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      orac_Sess::print_conn( @v_this_text );
   }
   $rc = $sth->finish;
   &see_plsql($v_command);
}
sub print_spinns {
   package main;
   my($add,$pid,$spd,$user,$ser,$trm,$prg,$bck,$wt,$spn) = @_;
#234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
$^A = "";
$str = formline <<'END',$add,$pid,$spd,$user,$ser,$trm,$prg,$bck,$wt,$spn;
^<<<<<<<< ^>>>> ^>>>> ^>>>>>>>>>>> ^>>>>> ^>>>>>>>>>>> ^>>>>>>>>>>>>>>>>>>>>>>>>>>> ^>>> ^>>> ^>>> ~~
END
print TEXT "$^A";
}
sub spin_orac {
   package main;

   printf TEXT "Processes currently on database:\n\n";

   my @titles = ('Addr', 'Pid', 'Spid', 'User Name', 'Serial', 'Term', 
                 'Prog', 'Back Grnd', 'Ltch Wait', 'Ltch Spin');
   orac_Sess::print_spinns( @titles );
   
   my @titles = ('----', '---', '----', '---------', '------', '----', 
                 '----', '----', '----', '----');
   orac_Sess::print_spinns( @titles );
   
   my $v_command =
         orac_Utils::file_string('sql_files','orac_Sess','spin_orac','1','sql');

   my $sth = $dbh->prepare($v_command) || die $dbh->errstr;
   
   $rv = $sth->execute;
   while (@v_this_text = $sth->fetchrow) {
      orac_Sess::print_spinns( @v_this_text );
   }
   $rc = $sth->finish;
   &see_plsql($v_command);
}
1;
