package orac_CreateDb;

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

# My entry for worst Perl module in the world ever competition.  Apologies.

use Tk;
use Cwd;
use DBI;
use Tk::DialogBox;
sub panic {
   package main;
   my $dialog_text = "This Report could take SOME TIME to run.  " .
                     "Are you sure you wish to run it?";
   my $dialog = $top->DialogBox( -title => "Orac Dialog", 
                                 -buttons => [ "Yes", "No" ]);
   $dialog->add("Label", -text => $dialog_text)->pack();
   my $button = $dialog->Show;
   if($button eq 'Yes'){
      my $sysdate;
      my $dummy;
      my $sth;
      my $rv;
      my $rc;
      my $counter;

      my $v_command = orac_Utils::file_string('sql_files', 'orac_CreateDb',
                                              'panic','1','sql');

      $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
      $rv = $sth->execute;

      @v_this_text = $sth->fetchrow;
      ($sysdate,$dummy) = @v_this_text;
      $rc = $sth->finish;

      $v_command = orac_Utils::file_string('sql_files', 'orac_CreateDb',
                                              'panic','2','sql');

      orac_CreateDb::panic_printer('Create All Tablespaces', $v_command);

      $v_command = orac_Utils::file_string('sql_files', 'orac_CreateDb',
                                           'panic','3','sql');
      orac_CreateDb::panic_printer(
           'Create All Tablespace Datafile Extents', $v_command);

      $v_command = orac_Utils::file_string('sql_files', 'orac_CreateDb',
                                           'panic','4','sql');
      orac_CreateDb::panic_printer('Create System Roles',$v_command);

      $v_command = orac_Utils::file_string('sql_files', 'orac_CreateDb',
                                           'panic','5','sql');
      orac_CreateDb::panic_printer('Create System Profiles',$v_command);

      $v_command = orac_Utils::file_string('sql_files', 'orac_CreateDb',
                                           'panic','6','sql');
      orac_CreateDb::panic_printer(
            'Create System Profiles (continued)',$v_command);

      $v_command = orac_Utils::file_string('sql_files', 'orac_CreateDb',
                                           'panic','7','sql');
      orac_CreateDb::panic_printer('Create ALL User Connections',$v_command);

      $v_command = orac_Utils::file_string('sql_files', 'orac_CreateDb',
                                           'panic','8','sql');
      orac_CreateDb::panic_printer('Reset User Passwords',$v_command);

      $v_command = orac_Utils::file_string('sql_files', 'orac_CreateDb',
                                           'panic','9','sql');
      orac_CreateDb::panic_printer('Create Tablespace Quotas',$v_command);

      # And if you think any of this was easy, you can buy me a Guinness

      $v_command = orac_Utils::file_string('sql_files', 'orac_CreateDb',
                                           'panic','10','sql');
      orac_CreateDb::panic_printer('Grant System Privileges',$v_command);

      $v_command = orac_Utils::file_string('sql_files', 'orac_CreateDb',
                                           'panic','11','sql');
      orac_CreateDb::panic_printer('Grant System Roles',$v_command);

      $v_command = orac_Utils::file_string('sql_files', 'orac_CreateDb',
                                           'panic','12','sql');
      orac_CreateDb::panic_printer('Create All PUBLIC Synonyms',$v_command);

      $v_command = orac_Utils::file_string('sql_files', 'orac_CreateDb',
                                           'panic','13','sql');
      orac_CreateDb::panic_printer(
               'Create ALL Public Database Links',$v_command);

      $v_command = orac_Utils::file_string('sql_files', 'orac_CreateDb',
                                           'panic','14','sql');
      orac_CreateDb::panic_printer('Create Rollback Segments',$v_command);
   }
}
sub orac_create_db {
   package main;
   my ($oracle_sid, $dummy) = split(/\./, $v_db);
   ($maxmemlen, $dummy) = 
        orac_CreateDb::orac_selector(orac_Utils::file_string('sql_files',
                              'orac_CreateDb','orac_create_db', '1','sql'));

   print TEXT 'rem  ************************************************' . "\n";
   print TEXT 'rem  *  Script : crdb' . 
              "$oracle_sid" . '.sql to Create Database' . "\n";

   my($current_date, $dummy) =
     orac_CreateDb::orac_selector(orac_Utils::file_string('sql_files',
                                 'orac_CreateDb','orac_create_db', '2','sql'));

   print TEXT 'rem  *  Date   : ' . "$current_date" . "\n";
   print TEXT 'rem  *  Notes  :' . "\n";
   print TEXT 'rem  *  -  This ORAC script includes CREATE DATABASE,' . "\n";
   print TEXT 'rem  *     CREATE other TABLESPACES, CREATE ROLLBACK' . "\n";
   print TEXT 'rem  *     SEGMENT, statements.' . "\n";
   print TEXT 'rem  *     It also runs catalog.sql, catproc.sql,' . "\n";
   print TEXT 'rem  *     dbmspool.sql, and utlmontr.sql under SYS' . "\n";
   print TEXT 'rem  *     and catdbsyn.sql and pupbld.sql under SYSTEM ' . "\n";
   print TEXT 'rem  *' . "\n";
   print TEXT 'rem  *  -  You should (if needed) :' . "\n";
   print TEXT 'rem  *     point to the correct init.ora file,' . "\n";
   print TEXT 'rem  *     and ensure that the rollback segments are' . "\n";
   print TEXT 'rem  *     enabled in the init.ora file after the' . "\n";
   print TEXT 'rem  *     database is created.' . "\n";
   print TEXT 'rem  *' . "\n";
   print TEXT 'rem  ************************************************' . "\n";
   print TEXT 'rem' . "\n";

   # Don't try and work this out unless you've had some strong Coffee

   my @curr_string =
     orac_CreateDb::orac_selector(orac_Utils::file_string('sql_files',
                                 'orac_CreateDb','orac_create_db', '3','sql'));
   printf TEXT "%s %s\n", $curr_string[0], $curr_string[1];

   @curr_string =
     orac_CreateDb::orac_selector(orac_Utils::file_string('sql_files',
                                 'orac_CreateDb','orac_create_db', '4','sql'));
   printf TEXT "%s %s\n", $curr_string[0], $curr_string[1];

   @curr_string =
     orac_CreateDb::orac_selector(orac_Utils::file_string('sql_files',
                                 'orac_CreateDb','orac_create_db', '5','sql'));
   printf TEXT "%s %s\n", $curr_string[0], $curr_string[1];

   @curr_string =
     orac_CreateDb::orac_selector(orac_Utils::file_string('sql_files',
                                 'orac_CreateDb','orac_create_db', '6','sql'));
   printf TEXT "%s %s\n", $curr_string[0], $curr_string[1];

   @curr_string =
     orac_CreateDb::orac_selector(orac_Utils::file_string('sql_files',
                                 'orac_CreateDb','orac_create_db', '7','sql'));
   printf TEXT "%s %s\n", $curr_string[0], $curr_string[1];

   @curr_string =
     orac_CreateDb::orac_selector(orac_Utils::file_string('sql_files',
                                 'orac_CreateDb','orac_create_db', '8','sql'));
   printf TEXT "%s %s\n", $curr_string[0], $curr_string[1];

   @curr_string =
     orac_CreateDb::orac_selector(orac_Utils::file_string('sql_files',
                                 'orac_CreateDb','orac_create_db', '9','sql'));
   printf TEXT "%s %s\n", $curr_string[0], $curr_string[1];

   print TEXT 'rem' . "\n";
   print TEXT 'rem  Note:  Use ALTER SYSTEM BACKUP ' .
              'CONTROLFILE TO TRACE;' . "\n";
   print TEXT 'rem         to generate a script to create controlfile' . "\n";
   print TEXT 'rem         and compare it with ' .
              'the output of this script.' . "\n";
   print TEXT 'rem         Add MAXLOGFILES, ' .
              'MAXDATAFILES, etc. if reqd.' . "\n";
   print TEXT 'rem' . "\n";
   print TEXT 'spool crdb' . "$oracle_sid" . '.lst' . "\n";
   print TEXT 'connect internal' . "\n";
   print TEXT 'startup nomount' . "\n\n";
   print TEXT 'rem -- please verify/change the following ' .
              'parameters as needed' . "\n\n";
   @curr_string =
     orac_CreateDb::orac_selector(orac_Utils::file_string('sql_files',
                                 'orac_CreateDb','orac_create_db', '10','sql'));
   printf TEXT "%s\n", $curr_string[0];
   @code_A = undef;
   @code_0 = undef;
   @code_1 = undef;
   @code_2 = undef;
   orac_CreateDb::fill_the_codes();
   my $this_counter = 0;
   while($code_A[$this_counter]){
      print TEXT "$code_A[$this_counter]\n";
      $this_counter++;
   }
   print TEXT '  ' . "\n";
   print TEXT "REMOVE THIS LINE => NB: Make sure you've got " .
              "NOARCHIVELOG or ARCHIVELOG sorted out\n";
   print TEXT "\n";
   print TEXT '   /* You may wish to change ' .
              'the following  values,          */' . "\n";
   print TEXT '   /* and use values found from a ' .
              'control file backed up     */' . "\n";
   print TEXT '   /* to trace.  Alternatively, ' .
              'uncomment these defaults.    */' . "\n";
   print TEXT '   /* (MAXLOGFILES & MAXLOGMEMBERS ' .
              'have been selected from   */' . "\n";
   print TEXT '   /* sys.v_$log, character set from ' .
              'NLS_DATABASE_PARAMETERS.*/' . "\n";
   print TEXT '  ' . "\n";
   print TEXT '   /* option start:use control file*/' . "\n";

   @curr_string =
     orac_CreateDb::orac_selector(orac_Utils::file_string('sql_files',
                                 'orac_CreateDb','orac_create_db', '11','sql'));
   printf TEXT "%s\n", $curr_string[0];

   @curr_string =
     orac_CreateDb::orac_selector(orac_Utils::file_string('sql_files',
                                 'orac_CreateDb','orac_create_db', '12','sql'));
   printf TEXT "%s\n", $curr_string[0];

   @curr_string =
     orac_CreateDb::orac_selector(orac_Utils::file_string('sql_files',
                                 'orac_CreateDb','orac_create_db', '13','sql'));
   printf TEXT "%s\n", $curr_string[0];

   print TEXT '   /* MAXDATAFILES  255 */' . "\n";
   print TEXT '   /* MAXINSTANCES    1 */' . "\n";
   print TEXT '   /* MAXLOGHISTORY 100 */' . "\n";
   print TEXT '   /* option end  :use control file*/' . "\n";
   print TEXT '  ' . "\n";
   $this_counter = 0;
   while($code_0[$this_counter]){
      print TEXT "$code_0[$this_counter]\n";
      $this_counter++;
   }
   print TEXT '    LOGFILE' . "\n";
   $this_counter = 0;
   while($code_1[$this_counter]){
      print TEXT "$code_1[$this_counter]\n";
      $this_counter++;
   }
   print TEXT 'rem ----------------------------------------' . "\n";
   print TEXT 'rem' . "\n";
   print TEXT 'rem  Need a basic rollback segment before proceeding' . "\n";
   print TEXT 'rem' . "\n";
   print TEXT 'CREATE ROLLBACK SEGMENT dummy TABLESPACE SYSTEM '  . "\n";
   print TEXT '    storage (initial 500K next 500K minextents 2);' . "\n";
   print TEXT 'ALTER ROLLBACK SEGMENT dummy ONLINE;' . "\n";
   print TEXT 'commit;' . "\n";
   print TEXT 'rem ----------------------------------------' . "\n";
   print TEXT 'rem' . "\n";
   print TEXT 'rem Create DBA views' . "\n";
   print TEXT 'rem' . "\n";
   print TEXT '@?/rdbms/admin/catalog.sql' . "\n";
   print TEXT 'commit;' . "\n";
   print TEXT 'rem ----------------------------------------' . "\n";
   print TEXT 'rem' . "\n";
   print TEXT 'rem  Additional Tablespaces' . "\n";
   $this_counter = 0;
   while($code_2[$this_counter]){
      print TEXT "$code_2[$this_counter]\n";
      $this_counter++;
   }

   my $v_command = orac_Utils::file_string('sql_files',
                                  'orac_CreateDb','orac_create_db', '14','sql');

   my $first_sth = $dbh->prepare( $v_command ) || die $dbh->errstr;
   my $rv = $first_sth->execute;

   while(@curr_text = $first_sth->fetchrow){
      print TEXT "$curr_text[0]\n";
   }
   $rc = $first_sth->finish;
   print TEXT 'rem' . "\n";
   print TEXT 'rem  Take the initial rollback segment (dummy) offline' . "\n";
   print TEXT 'rem' . "\n";
   print TEXT 'ALTER ROLLBACK SEGMENT dummy OFFLINE;' . "\n";
   print TEXT 'rem' . "\n";
   print TEXT 'rem ----------------------------------------' . "\n";
   print TEXT 'rem' . "\n";

   $v_command = 
      orac_Utils::file_string('sql_files',
                              'orac_CreateDb','orac_create_db', '15','sql');

   my $second_sth = $dbh->prepare( $v_command ) || die $dbh->errstr;
   $rv = $second_sth->execute;

   while(@curr_text = $second_sth->fetchrow){
      print TEXT "$curr_text[0]\n";
   }
   $rc = $second_sth->finish;

   $v_command =
      orac_Utils::file_string('sql_files',
                              'orac_CreateDb','orac_create_db', '16','sql');

   my $third_sth = $dbh->prepare( $v_command ) || die $dbh->errstr;
   my $rv = $third_sth->execute;

   while(@curr_text = $third_sth->fetchrow){
      print TEXT "$curr_text[0]\n";
   }
   $rc = $third_sth->finish;

   print TEXT 'rem' . "\n";
   print TEXT 'rem ----------------------------------------' . "\n";
   print TEXT 'rem' . "\n";
   print TEXT 'rem  Run other @?/rdbms/admin required scripts' . "\n";
   print TEXT 'rem' . "\n";
   print TEXT 'commit;' . "\n";
   print TEXT 'rem' . "\n";
   print TEXT '@?/rdbms/admin/catproc.sql' . "\n";
   print TEXT "rem\n";
   print TEXT "rem You may wish to uncomment the following scripts?\n";
   print TEXT "rem\n";
   print TEXT 'rem @?/rdbms/admin/catparr.sql' . "\n";
   print TEXT 'rem @?/rdbms/admin/catexp.sql' . "\n";
   print TEXT 'rem @?/rdbms/admin/catrep.sql' . "\n";
   print TEXT 'rem @?/rdbms/admin/dbmspool.sql' . "\n";
   print TEXT 'rem @?/rdbms/admin/utlmontr.sql' . "\n";
   print TEXT 'rem' . "\n";
   print TEXT 'commit;' . "\n";
   print TEXT 'rem' . "\n";
   print TEXT 'connect system/manager' . "\n";
   print TEXT '@?/sqlplus/admin/pupbld.sql' . "\n";
   print TEXT '@?/rdbms/admin/catdbsyn.sql' . "\n";
   print TEXT 'commit;' . "\n";
   print TEXT 'spool off' . "\n";
   print TEXT 'exit' . "\n";
   print TEXT "\n";
   print TEXT "rem\n";
   print TEXT "rem  Thank you for choosing Orac\n";
   print TEXT "rem\n";

   # All done.  OK, so loads of it should've been in a file,
   # but I got carried away
}
sub orac_selector {
   package main;
   my ($v_command, $dummy) = @_;
   my $local_sth = $dbh->prepare( $v_command ) || die $dbh->errstr;
   my $rv = $local_sth->execute;
   my @v_text = $local_sth->fetchrow;
   my $rc = $local_sth->finish;
   return @v_text;
}
sub fill_the_codes {
   package main;
   $dbh->func(100000, 'dbms_output_enable');

   my $v_command = orac_Utils::file_string('sql_files', 'orac_CreateDb',
                                           'fill_the_codes','1','sql');
   $v_command =~ s/orac_insert_maxmemlen/$maxmemlen/g;

   my $filler_sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   my $filler_rv = $filler_sth->execute;

   my $j_counter = 0;
   my $full_list;
   my $first_bit;
   my $second_bit;
   my $code_A_count = 0;
   my $code_0_count = 0;
   my $code_1_count = 0;
   my $code_2_count = 0;
   while($j_counter < 10000){
      $full_list = scalar $dbh->func('dbms_output_get');
      $my_god = length($full_list);
      if ($my_god == 0){
         last;
      }
      ($first_bit, $second_bit, $dummy) = split(/\^/, $full_list);
      if ($first_bit eq 'A'){
         $code_A[$code_A_count] = $second_bit;
         $code_A_count++;
      }
      elsif ($first_bit eq '0'){
         $code_0[$code_0_count] = $second_bit;
         $code_0_count++;
      }
      elsif ($first_bit eq '1'){
         $code_1[$code_1_count] = $second_bit;
         $code_1_count++;
      }
      elsif ($first_bit eq '2'){
         $code_2[$code_2_count] = $second_bit;
         $code_2_count++;
      }
      $j_counter++;
   }
}
sub panic_printer {
   package main;
   my($title,$v_command) = @_;
   print TEXT "rem\n";
   print TEXT "rem  $title for $v_db\n";
   print TEXT "rem  (Generated by Orac $sysdate)\n";
   print TEXT "rem\n\n";
   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   my $rv = $sth->execute;
   my @v_this_text;
   my $counter = 0;
   while(@v_this_text = $sth->fetchrow){
      $counter = 1;
      print TEXT "@v_this_text\n";
   }
   my $rc = $sth->finish;
   if ($counter == 0){
      print TEXT "rem  no rows found\n";
   }
   &see_plsql($v_command);
}
1;
