package orac_SqlGen; 

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
sub datafile_orac {
   package main;
   printf TEXT "Files for Database $v_db\n\n";

   my @titles = ('TYPE','TABLESPACE','FILE_NAME','ACT_MB','STATUS');
   orac_SqlGen::print_datafile( @titles );

   my @titles = ('----','----------','---------','------','------');
   orac_SqlGen::print_datafile( @titles );
   
   my $v_command = orac_Utils::file_string('sql_files', 'orac_SqlGen',
                                           'datafile_orac', '1','sql');
   $v_command =~ s/orac_insert_oracle_home/$oracle_home/g;

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
      if ($v_this_text[3] eq '0'){
         $v_this_text[3] = '';
      }
      else {
         $v_this_text[3] = sprintf("%.2f", ($v_this_text[3] + 0.00));
      }
      orac_SqlGen::print_datafile( @v_this_text );
   }
   $rc = $sth->finish;
   &see_plsql($v_command);
}
sub print_datafile {
   package main;

   my($type,$tablespace,$file_name,$act_mb,$status) = @_;

#234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
$^A = "";
$str = formline <<'END',$type,$tablespace,$file_name,$act_mb,$status;
^<<< ^<<<<<<<<<<<<<<<<<<< ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ^>>>>>>> ^>>>>> ~~
END
print TEXT "$^A";

}

sub ext_orac {
   package main;

   my $v_command = orac_Utils::file_string('sql_files', 'orac_SqlGen',
                                           'ext_orac', '1','sql');

   printf TEXT "EXTENTS Report for $v_db\n\n";

   my @titles = ('OWNER','TABSPACE','TYPE','OBJECT_NAME','MAX',
                 'EXTS','%','FIX?');
   orac_SqlGen::print_extents( @titles );
   
   my @titles = ('-----','--------','----','-----------','---',
                 '----','-','----');
   orac_SqlGen::print_extents( @titles );
   
   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;
   my $detected = 0;
   while (@v_this_text = $sth->fetchrow) {
      if ($v_this_text[7] eq '** FIX **'){
         $detected = 1;
      }
      if($v_this_text[4] >= 2147483645){
         $v_this_text[4] = 'ULTD';
         $pct = undef;
      }
      else {
         $pct = sprintf("%6.2f%%", ($v_this_text[6] + 0.00));
      }
      orac_SqlGen::print_extents(
                        $v_this_text[0],
                        $v_this_text[1],
                        $v_this_text[2],
                        $v_this_text[3],
                        $v_this_text[4],
                        $v_this_text[5],
                        $pct,
                        $v_this_text[7]
                                );
      }
   $rc = $sth->finish;
   &see_plsql($v_command);
}
sub print_extents {
   package main;

   my($owner,$tabspace,$type,$name,$max,$exts,$pct,$fix) = @_;

#234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
$^A = "";
$str = formline <<'END',$owner,$tabspace,$type,$name,$max,$exts,$pct,$fix;
^<<<<<<<<< ^<<<<<<<<<<<<<<<<<<<<< ^<<<<<<<< ^<<<<<<<<<<<<<<<<<<<<< ^>>> ^>>> ^>>>>>> ^>>>>>>>> ~~
END
print TEXT "$^A";

}
sub alter_comp_orac {
   package main;
   print TEXT "rem Copy the script below and " .
              "apply to \nrem $v_db to recompile invalid stuff:\n\n";

   my $v_command = orac_Utils::file_string('sql_files', 'orac_SqlGen',
                                           'alter_comp_orac', '1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   my $detected = 0;
   while (@v_this_text = $sth->fetchrow) {
      printf TEXT "@v_this_text\n";
      $detected++;
   }
   if($detected == 0){
      printf TEXT "no rows found\n";
   }
   $rc = $sth->finish;
   &see_plsql($v_command);
}
sub errors_orac {
   package main;

   my $v_command =
         orac_Utils::file_string('sql_files','orac_SqlGen',
                                 'errors_orac','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   my $detected = 0;
   while (@v_this_text = $sth->fetchrow) {
      $detected++;
      if($detected == 1){
         $errored_top = MainWindow->new();
         my $this_title = "Orac $v_db Errored Objects";
         $errored_top->title($this_title);
         $label = 
            $errored_top->Label( text   => 'Double-Click Required Error',
                                 anchor => 'n',
                                 relief => 'groove',
                                 height => 1,
                       )->pack();
         $orac_SqlGen::errored_list = 
              $errored_top->ScrlListbox(
                     "width" => 40, 
                     "background" => $main::this_is_the_colour,
                     "foreground" => $main::this_is_the_forecolour,
                       );
         $dismiss_button = 
            $errored_top->Button( 
               text    => 'Dismiss',
               command => sub { $errored_top->withdraw();
                                $grey_errors->configure(-state => 'active') } 
                  )->pack(-side => 'bottom', -anchor => 'se');

         my $icon_img = 
               $errored_top->Pixmap('-file' => 'orac_images/orac_smid.bmp');
         $errored_top->Icon('-image' => $icon_img);
         $errored_top->iconname('Errors');
      }
      $orac_SqlGen::errored_list->insert('end', @v_this_text);
   }
   $rc = $sth->finish;
   if($detected == 0){
      my $local_dialog = $top->DialogBox( -title => "Orac Dialog",
                                       -buttons => [ "Dismiss" ]);
      my $text = 'There are no records currently in dba_errors';
      $local_dialog->add("Label", -text => $text )->pack;
      $local_dialog->Show;
   }
   else {
      $grey_errors->configure(-state => 'disabled');
      $orac_SqlGen::errored_list->pack();
      $orac_SqlGen::errored_list->bind('<Double-1>', 
                                       sub { $top->Busy;
                                             orac_SqlGen::selected_error();
                                             $top->Unbusy});
   }
}
sub selected_error {
   package main;
   my $errored_bit = $orac_SqlGen::errored_list->get('active');
   main::clear_orac();
   print TEXT "\nCollecting errors for $errored_bit:\n\n";
   printf TEXT "%-12s %4s %4s %4s %-70s\n" .
               "%-12s %4s %4s %4s %-70s\n", 
               'TYPE', 'SEQ', 'LINE', 'POS', 'TEXT',
               '----', '---', '----', '---', '----';
   my ($owner,$object,$dummy) = split(/\./, $errored_bit);

   my $v_command =
         orac_Utils::file_string('sql_files','orac_SqlGen',
                                 'selected_error','1','sql');
   $v_command =~ s/orac_insert_owner/$owner/g;
   $v_command =~ s/orac_insert_object/$object/g;

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   my $detected = 0;
   while (@v_this_text = $sth->fetchrow) {
      $detected++;
      $error_type     = $v_this_text[0];
      $error_sequence = $v_this_text[1];
      $error_line     = $v_this_text[2];
      $error_position = $v_this_text[3];
      $error_text     = $v_this_text[4];
$^A = "";
$str = formline <<'END',$error_type,$error_sequence,$error_line,$error_position,$error_text;
@<<<<<<<<<<< @>>> @>>> @>>> ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
END
$str = formline <<'END2',$error_text;
~~                          ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
END2
print TEXT "$^A \n";
      
   }
   $rc = $sth->finish;
   if($detected == 0){
      print TEXT "no rows found\n";
   }
   print TEXT "-----------------------" . 
              "-----------------------" . 
              "-----------------------" . 
              "------------------------------\n";
}
sub create_db_script {
   package main;
   orac_CreateDb::orac_create_db();
}
sub panic_script {
   package main;
   orac_CreateDb::panic();
}
sub get_block_size {
   package main;

   my $get_block_size = 
         orac_Utils::file_string('sql_files','orac_SqlGen',
                                 'get_block_size','1','sql');

   my $block_query = $dbh->prepare( $get_block_size ) || die $dbh->errstr; 
   my $rv = $block_query->execute;

   my @v_block_array = $block_query->fetchrow;
   my $rc = $block_query->finish;
   $Block_Size = $v_block_array[0];
}
1;
