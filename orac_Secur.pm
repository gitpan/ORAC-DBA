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
sub print_grant_orac {
   package main;
   my($lev,$own,$tab,$grantee,$priv) = @_;
#234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
$^A = "";
$str = formline <<'END',$lev,$own,$tab,$grantee,$priv;
^<<<< ^>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ^<<<<<<<<<<<<<<<<<<<< ~~
END
print TEXT "$^A";
}
sub grant_orac {
   package main;
   printf TEXT "Direct Object Grants for $v_db:\n\n";

   my @titles = ('Level', 'Owner', 'Table Name', 'Grantee', 'Privilege');
   orac_Secur::print_grant_orac( @titles );

   my @titles = ('-----', '-----', '----------', '-------', '---------');
   orac_Secur::print_grant_orac( @titles );
   
   my $v_command = orac_Utils::file_string('sql_files', 'orac_Secur',
                                           'grant_orac', '1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      orac_Secur::print_grant_orac( @v_this_text );
   }
   $rc = $sth->finish;
   &see_plsql($v_command);
}
sub print_user_orac {
   package main;
   my($Level,$Priv,$Grantable,$Own,$Obj) = @_;
#234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
$^A = "";
$str = formline <<'END',$Level,$Priv,$Grantable,$Own,$Obj;
^<<<<<<< ^>>>>>>>>>>>>>>>>>>>>>>>>> ^>>>> ^>>>>>>>>>>>>>>>>>>>>>>>> ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ~~
END
print TEXT "$^A";
}
sub user_orac {
   package main;
   printf TEXT "All Privileges Report for $v_db:\n\n";
   orac_Secur::print_user_orac('Level', 'Privilege', 'Grant able?', 
                               'Owner', 'Object Name');
   orac_Secur::print_user_orac('-----', '---------', '-----', 
                               '-----', '-----------');
   
   my $v_command = orac_Utils::file_string('sql_files', 'orac_Secur',
                                           'user_orac', '1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      orac_Secur::print_user_orac( @v_this_text );
   }
   $rc = $sth->finish;
   &see_plsql($v_command);
}
sub print_tab_orac {
   package main;
   my($Grantor,$Grantee,$Table,$Priv, $Own, $Grantable) = @_;
#234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
$^A = "";
$str = formline <<'END',$Grantor,$Grantee,$Table,$Priv, $Own, $Grantable;
^<<<<<<<<<<<<<<< ^>>>>>>>>>>>>>>>>>>>>>>> ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ^>>>>>>>>> ^>>>>>>> ^>>>> ~~
END
print TEXT "$^A";
}
sub table_orac {
   package main;
   printf TEXT "Table Grants for $v_db:\n\n";

   orac_Secur::print_tab_orac('Grantor', 'Grantee', 'Object Name', 
                              'Privilege', 'Owner', 'Grantable?');
   orac_Secur::print_tab_orac('-------', '-------', '-----------', 
                              '---------', '-----', '-----');
   
   my $v_command = orac_Utils::file_string('sql_files', 'orac_Secur',
                                           'table_orac', '1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      orac_Secur::print_tab_orac( @v_this_text );
   }
   $rc = $sth->finish;
   &see_plsql($v_command);
}
1;
