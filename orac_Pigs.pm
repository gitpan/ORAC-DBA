package orac_Pigs;

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
sub tune_pigs {
   package main;

   my $v_command = orac_Utils::file_string('sql_files', 'orac_Pigs',
                                           'tune_pigs','1','sql');

   $dbh->func(1000000, 'dbms_output_enable');
   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   my $rv = $sth->execute;
   my $j_counter = 0;
   my $my_god;
   my @this_banana;
   my $iopigs_fill_counter = 0;
   my $mempigs_fill_counter = 0;
   my $we_have_iopigs = 0;
   my $we_have_mempigs = 0;
   while($j_counter < 2000){
      $_ = scalar $dbh->func('dbms_output_get');
      if(/\^/){
         @this_banana = split(/\^/, $_);
         if ($this_banana[0] == 99){
            $the_top_title = "$this_banana[1]: $this_banana[2]\n\n";
         }
         elsif ($this_banana[0] == 3){
            $the_memory_title1 = "$this_banana[1]\n";
         }
         elsif ($this_banana[0] == 4){
            $the_memory_title2 = "$this_banana[1]\n\n";
         }
         elsif ($this_banana[0] == 5){
            $the_io_title1 = "\n\n$this_banana[1]\n";
         }
         elsif ($this_banana[0] == 6){
            $the_io_title2 = "$this_banana[1]\n\n";
         }
         elsif ($this_banana[0] > 200000){
             $mempigs_fill[$mempigs_fill_counter] = $_;
             $mempigs_fill_counter++;
             $we_have_mempigs = 1;
         }
         elsif ($this_banana[0] > 100000){
             $iopigs_fill[$iopigs_fill_counter] = $_;
             $iopigs_fill_counter++;
             $we_have_iopigs = 1;
         }
      }
      $my_god = length($_);
      if ($my_god == 0){
         last;
      }
      $j_counter++;
   }
   print TEXT $the_top_title;
   if (($we_have_mempigs == 0) && ($we_have_iopigs == 0)){
       print TEXT "no pigs found";
   }
   else {
      if ($we_have_mempigs == 1){
         print TEXT $the_memory_title1;
         print TEXT $the_memory_title2;
         orac_Pigs::print_mem_line('Buffer', 'Username', 'SID', 'SQL Text');
         orac_Pigs::print_mem_line('Gets',   '',         '',    '');
         orac_Pigs::print_mem_line('------', '--------', '---', '--------');
         for ($i_counter = 0;$i_counter < $mempigs_fill_counter;$i_counter++){
            my @flunky = split(/\^/, $mempigs_fill[$i_counter]);

            orac_Pigs::print_mem_line($flunky[3], 
                                      $flunky[1], 
                                      $flunky[2], 
                                      $flunky[6]);
         }
      }
      if ($we_have_iopigs == 1){
         print TEXT $the_io_title1;
         print TEXT $the_io_title2;

         orac_Pigs::print_io_line('Disk',  '',      'Reads/', 
                                  'Username', 'SID', 'SQL Text');
         orac_Pigs::print_io_line('Reads', 'Execs', 'Exec',   
                                  '',         '',    '');
         orac_Pigs::print_io_line('-----', '-----', '------', 
                                  '--------', '---', '--------');

         for ($i_counter = 0;$i_counter < $iopigs_fill_counter;$i_counter++){
            my @flunky = split(/\^/, $iopigs_fill[$i_counter]);

            orac_Pigs::print_io_line( $flunky[3], 
                                      $flunky[4], 
                                      $flunky[5], 
                                      $flunky[1], 
                                      $flunky[2], 
                                      $flunky[6]);
         }
      }
   }
   &see_plsql($v_command);
}
sub print_mem_line {
   package main;
   my($buffer_gets, $username, $sid, $sql_text, $dummy) = @_;
$^A = "";
$str = formline <<'END',$buffer_gets, $username, $sid, $sql_text;
^>>>>>>>>>>>> ^<<<<<<<<<<<<<<<<<<<< ^<<<<<< ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ~~
END
print TEXT "$^A";
      
}
sub print_io_line {
   package main;
   my($disk_reads, $execs, $read_exec, 
      $username, $sid, $sql_text, $dummy) = @_;
$^A = "";
$str = formline <<'END',$disk_reads,$execs,$read_exec,$username,$sid,$sql_text;
^>>>>>>>>> ^<<<<<<< ^<<<<<<<< ^<<<<<<<<<<< ^<<<<< ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ~~
END
print TEXT "$^A";
}
1;
