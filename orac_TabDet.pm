package orac_TabDet;  

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
sub tab_det_orac {
   package main;
   my $dialog = $top->DialogBox( 
                    -title => "Orac Datafiles " .
                              "$v_machine $v_db (Block Size $Block_Size)",
                    -buttons => [ "Dismiss" ]);

   my $canvas_frame = $dialog->Frame;
   $canvas_frame->pack(-expand => '1', -fill => 'both');
   my $canvas = $canvas_frame->Scrolled('Canvas',
                                      -relief => 'sunken', 
                                      -background => $main::this_is_the_colour,
                                      -bd => 2, width => 700, height => 500);
   
   $orac_TabDet::keep_tablespace = 'XXXXXXXXXXXXXXXXX';

   my $v_command = 
         orac_Utils::file_string('sql_files','orac_TabDet',
                                 'tab_det_orac','1','sql');
   $v_command =~ s/orac_insert_Block_Size/$Block_Size/g;

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   $v_counter = 1;
   $Grand_Total = 0.00;
   $Grand_Used_Mg = 0.00;
   $Grand_Free_Mg = 0.00;

   while (@v_this_text = $sth->fetchrow) {

     my ($T_Space, $Fname, $Total, $Used_Mg, 
         $Free_Mg, $Use_Pct, $dummy) = @v_this_text;

     if (($Used_Mg == undef) || ($Use_Pct == undef)){
        $Used_Mg = 0.00;
        $Use_Pct = 0.00;
     }
     $Grand_Total = $Grand_Total + $Total;
     $Grand_Used_Mg = $Grand_Used_Mg + $Used_Mg;
     $Grand_Free_Mg = $Grand_Free_Mg + $Free_Mg;
     orac_TabDet::add_item( $canvas, $v_counter,
               $T_Space, $Fname, $Total, $Used_Mg, $Free_Mg, $Use_Pct);
     $v_counter++;
   }
   $rc = $sth->finish;

   $Grand_Use_Pct = (($Grand_Used_Mg/$Grand_Total)*100.00);

   orac_TabDet::add_item( 
       $canvas, 
       0,
       '', 
       '', 
       $Grand_Total, 
       $Grand_Used_Mg, 
       $Grand_Free_Mg, 
       $Grand_Use_Pct);

   my $c_button = 
          $canvas->Button(
                     -text => 'See SQL',
                     -command => sub { main::banana_see_sql($v_command) } );

   my $y_start = orac_TabDet::work_out_why($v_counter);
   $canvas->create('window', '1c', "$y_start" . 'c', -window => $c_button,
	           qw/-anchor nw -tags item/);
   $canvas->configure(-scrollregion => [ $canvas->bbox("all") ]);
   $canvas->pack(-expand => 'yes', -fill => 'both');
   $dialog->Show();
}
sub work_out_why {
    my $y_entry = $_[0];
    return (0.8 + (1.2 * $y_entry));
}
sub add_item
{
   my (   $canvas, $counter, 
          $T_Space, $Fname, $Total, $Used_Mg, $Free_Mg, $Use_Pct) = @_;

   my $back_colour = $main::this_is_the_colour;
   my $front_colour = $main::this_is_the_forecolour;
   my $we_draw_a_line = 0;

   unless($counter == 0){
      $tablespace_string;
      if ($orac_TabDet::keep_tablespace eq $T_Space){
         $tablespace_string = sprintf("%${old_length}s ", '');
      }
      else {
         $old_length = length($T_Space);
         $tablespace_string = sprintf("%${old_length}s ", $T_Space);
         $we_draw_a_line = 1;
      }
      $orac_TabDet::keep_tablespace = $T_Space;
   }

   my $thickness = 0.4;
   my $y_start = orac_TabDet::work_out_why($counter);
   my $y_end = $y_start + 0.4;
   my $fill = (100/10.0) + 0.4;
   $canvas->create(('rectangle', "$fill" . 'c',    
                    "$y_start". 'c',   '0.4c',      "$y_end" . 'c'),
              -fill => $back_colour);
   my $fill = ($Use_Pct/10.0) + 0.4;
   $canvas->create(('rectangle', "$fill" . 'c',    
                    "$y_start". 'c',   '0.4c',      "$y_end" . 'c'),
              -fill => $front_colour);
  
   $y_start = $y_start - 0.4;
   if($counter == 0){
      $top_colour = $main::this_is_the_forecolour;
      $bottom_colour = $main::this_is_the_forecolour;
      $this_text = "Total Figures for the $v_db database are as follows:";
      $this_text = "Database $v_db" . ' is '. 
                   sprintf("%5.2f", $Use_Pct) . '% full';
   }
   else {
      $top_colour = 'red';
      $bottom_colour = 'blue';
      $this_text = "$tablespace_string $Fname " . 
                   sprintf("%5.2f", $Use_Pct) . '%';
   }
   $canvas->create('text', '0.4c', "$y_start" . 'c', 
          -anchor => 'nw',
          -fill => $main::this_is_the_forecolour,
          -justify => 'left',
          -text => $this_text);
   $y_start = $y_start + 0.4;
   $canvas->create('text', '10.4c', "$y_start" . 'c', 
          -anchor => 'nw',
          -fill => $main::this_is_the_forecolour,
          -justify => 'left',
          -text => sprintf("%10.2fM Total %10.2fM Used %10.2fM Free", 
                           $Total, $Used_Mg, $Free_Mg));

   if ($we_draw_a_line == 1){
      my $line_y_start = $y_start - 0.5;
      $canvas->create(('line', '0.4c', "$line_y_start" . 'c', '20.5c', 
                       "$line_y_start" . 'c'), 
                       -fill => $main::this_is_the_forecolour);
   }
}
1;
