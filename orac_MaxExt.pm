package orac_MaxExt;

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
sub max_ext_orac {
   package main;

   print TEXT "Max Extents Report:\n\n";
   orac_MaxExt::print_item("TABLESPACE","EXTS","TOTAL", 
                           "SMALL","AVERAGE","BIGGEST","MAX_NXT","PANIC?");
   orac_MaxExt::print_item("----------","----","-----", 
                           "-----","-------","-------","-------","------");

   my $v_command = orac_Utils::file_string('sql_files', 'orac_MaxExt',
                                           'max_ext_orac','1','sql');
   $v_command =~ s/orac_insert_Block_Size/$Block_Size/g;

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      my (   $Tablespace, $Exts, $Total, 
             $Small, $Average, $Biggest, $Max_Nxt, $Panic) = @v_this_text;
      orac_MaxExt::print_item( 
             $Tablespace, $Exts, $Total, 
             $Small, $Average, $Biggest, $Max_Nxt, $Panic);
   }
   $rc = $sth->finish;
}
sub print_item
{
   package main;
   my (   $Tablespace, $Exts, $Total, 
          $Small, $Average, $Biggest, $Max_Nxt, $Panic) = @_;
$^A = "";
$this_str = formline <<'END',$Tablespace,$Exts,$Total,$Small,$Average,$Biggest,$Max_Nxt,$Panic;
^<<<<<<<<<<<<<<<< ^>>>>> ^>>>>>>>>>> ^>>>>>>>>>> ^>>>>>>>>>> ^>>>>>>>>>> ^>>>>>>>>>> ^<<<<<<<<<<<<< ~~
END
print TEXT "$^A";
}
1;
