package orac_TuneHealth;

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
sub tune_health {
   package main;
   my $this_title = "Orac Tuning HealthCheck Report $v_machine $v_db";
   my $dialog = $top->DialogBox( -title => $this_title,
                                 -buttons => [ "Dismiss" ]);
   my $canvas_frame = $dialog->Frame;
   $canvas_frame->pack(-expand => '1', -fill => 'both');

   my $canvas = $canvas_frame->Scrolled('Canvas',
                                      -relief => 'sunken', 
                                      -background => $main::this_is_the_colour,
                                      -bd => 2, width => 700, height => 500);

   my $v_command = 
          orac_Utils::file_string('sql_files', 'orac_TuneHealth',
                                  'tune_health','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   while (@v_this_text = $sth->fetchrow) {
     ($dc_hit_ratio, $dummy) = @v_this_text;
   }
   $rc = $sth->finish;

   $v_command = 
          orac_Utils::file_string('sql_files', 'orac_TuneHealth',
                                  'tune_health','2','sql');

   my $second_sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $second_sth->execute;

   while (@v_this_text = $second_sth->fetchrow) {
     ($lc_hit_ratio, $dummy) = @v_this_text;
   }
   $rc = $second_sth->finish;

   $v_command = 
          orac_Utils::file_string('sql_files', 'orac_TuneHealth',
                                  'tune_health','3','sql');

   my $third_sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $third_sth->execute;

   $counter = 0;
   while (@v_this_text = $third_sth->fetchrow) {
      ($dummy2, $hit_ratio[$counter], $dummy) = @v_this_text;
      $counter++;
   }
   $hit_ratio = $hit_ratio[2]/($hit_ratio[0] + $hit_ratio[1]);
   $rc = $third_sth->finish;

   $v_command = 
          orac_Utils::file_string('sql_files', 'orac_TuneHealth',
                                  'tune_health','4','sql');

   my $fourth_sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $fourth_sth->execute;

   while (@v_this_text = $fourth_sth->fetchrow) {
      ($ratio, $dummy) = @v_this_text;
   }
   $rc = $fourth_sth->finish;

   $v_command = 
          orac_Utils::file_string('sql_files', 'orac_TuneHealth',
                                  'tune_health','5','sql');

   my $fifth_sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $fifth_sth->execute;

   while (@v_this_text = $fifth_sth->fetchrow) {
      ($w2wait_ratio, $dummy) = @v_this_text;
   }
   $rc = $fifth_sth->finish;
   orac_TuneHealth::add_item( $canvas, $dc_hit_ratio, $lc_hit_ratio, 
                              $hit_ratio, $ratio, $w2wait_ratio);
   #my $c_button = 
   #       $canvas->Button(
   #                  -text => 'See SQL',
   #                  -command => sub { main::banana_see_sql($v_command) } );
#
#   my $y_start = orac_TabDet::work_out_why($v_counter);
#   $canvas->create('window', '1c', "$y_start" . 'c', -window => $c_button,
#	           qw/-anchor nw -tags item/);
   $canvas->configure(-scrollregion => [ $canvas->bbox("all") ]);
   $canvas->pack(-expand => 'yes', -fill => 'both');
   $dialog->Show();
}
sub add_item
{
   package main;
   my ( $canvas, $dc_hit_ratio, $lc_hit_ratio, $hit_ratio, 
        $ratio, $w2wait_ratio) = @_;

   my $y_start = 1.0;
   my $y_end = $y_start + 0.3;
   $small_division = 20.00;
   $large_division = 100.00;
   if($dc_hit_ratio >= ($small_division - 1.00)){
      $division = $large_division;
   } else {
      $division = $small_division;
   }
   $screen_ratio = 6;
   $rec_width = 0.12;
   $low_accept = 10.00;
   $high_accept = 15.00;
   $multiplier = (100.00/$division);
   $low_counter = $low_accept * $multiplier;
   $high_counter = $high_accept * $multiplier;
   for ($i_counter = 0;$i_counter < 100;$i_counter++){
      $x_start = ($i_counter/$screen_ratio) + 1.00;
      $x_stop = $x_start - $rec_width;
      if(($i_counter == $low_counter) || ($i_counter == $high_counter)){
         $canvas->create((
           'rectangle', "$x_start" . 'c', 
           sprintf("%fc", ($y_start - 0.2)), "$x_stop" . 'c', 
                   sprintf("%fc", ($y_end + 0.2))));
      }
      $canvas->create(('rectangle', "$x_start" . 'c', "$y_start" . 'c', 
                       "$x_stop" . 'c', "$y_end" . 'c'));
      if((($dc_hit_ratio * 100) /$division) > $i_counter){
         $canvas->create(('rectangle', "$x_start" . 'c', 
                          "$y_start" . 'c', "$x_stop" . 'c', "$y_end" . 'c'),
                          -fill => $main::this_is_the_forecolour);
      }
   }
   $canvas->create('text', "$x_start" . 'c', 
                   "$y_start" . 'c', -anchor => 'nw',
                    -justify => 'left',
                    -text => sprintf("%8.2f", $division) . '%', 
                    -fill => $main::this_is_the_forecolour);
   $y_start = $y_start + 0.5;
  
   $the_ratio = sprintf("%f", $dc_hit_ratio);
   $the_ratio =~ s/[0]*$//g;
   $the_ratio =~ s/\.$/\.0/g;
   $canvas->create('text', '0.8c', "$y_start" . 'c', 
                   -anchor => 'nw',
                   -justify => 'left',
                   -text => 'dc_hit_ratio = ' . "$the_ratio" . ' %',
                   );

   if ($dc_hit_ratio < $low_accept) {
      $this_text =
         'Your Dictionary Cache Hit Ratio on v$rowcache ' .
         'is lower than the normal range ' . 
         'of 10-15%, which should give you ' . "\n" . 
         'excellent performance, however if you need the memory elsewhere, ' .
         'you can afford to decrease the SHARED_POOL_SIZE.';
   }
   elsif ($dc_hit_ratio > $high_accept) {
      $this_text =
         'Your Dictionary Cache Hit Ratio on v$rowcache is ' .
         'higher than the normal range of 10-15%.  ' .
         'You need to increase your ' . "\n" . 'SHARED_POOL_SIZE, but ' .
         'make sure that the SGA does not ' .
         'require virtual paged memory, which will severely retard ' .
         'your performance.';
   }
   else {
      $this_text =
         'Your Dictionary Cache Hit Ratio on v$rowcache is ' .
         'within the normal range of 10-15%.  ' . "\n" .
         'Your SHARED_POOL_SIZE value should not be made smaller.';
   }
   $y_start = $y_start + 0.5;
   $canvas->create('text', '0.8c', "$y_start" . 'c', 
                   -anchor => 'nw',
                   -justify => 'left',
                   -text => $this_text, -fill => $main::this_is_the_forecolour);
   $y_start = $y_start + 2;
   $y_end = $y_start + 0.3;
   $small_division = 5.00;
   $large_division = 100.00;
   if($lc_hit_ratio >= ($small_division - 1.00)){
      $division = $large_division;
   } else {
      $division = $small_division;
   }
   $accept = 1.00;
   $multiplier = (100.00/$division);
   $accept_counter = $accept * $multiplier;
   for ($i_counter = 0;$i_counter < 100;$i_counter++){
      $x_start = ($i_counter/$screen_ratio) + 1.00;
      $x_stop = $x_start - $rec_width;
      if($i_counter == $accept_counter){
         $canvas->create((
           'rectangle', "$x_start" . 'c', 
           sprintf("%fc", ($y_start - 0.2)), "$x_stop" . 'c', 
                   sprintf("%fc", ($y_end + 0.2))));
      }
      $canvas->create(('rectangle', "$x_start" . 'c', 
                       "$y_start" . 'c', "$x_stop" . 'c', "$y_end" . 'c'));

      if((($lc_hit_ratio * 100) /$division) > $i_counter){
         $canvas->create(('rectangle', "$x_start" . 'c', 
                          "$y_start" . 'c', "$x_stop" . 'c', "$y_end" . 'c'),
                          -fill => $main::this_is_the_forecolour);
      }
   }
   $canvas->create( 'text', "$x_start" . 'c', 
                    "$y_start" . 'c', -anchor => 'nw',
                    -justify => 'left',
                    -text => sprintf("%8.2f%%", $division), 
                    -fill => $main::this_is_the_forecolour);

   $y_start = $y_start + 0.5;
   $the_ratio = sprintf("%f", $lc_hit_ratio);
   $the_ratio =~ s/[0]*$//g;
   $the_ratio =~ s/\.$/\.0/g;
   $canvas->create('text', '0.8c', "$y_start" . 'c', 
                   -anchor => 'nw',
                   -justify => 'left',
                   -text => 'lc_hit_ratio = ' . "$the_ratio" . ' %', 
                   );

   if ($lc_hit_ratio <= $accept) {
      $this_text =
         'Your Library Cache Hit Ratio on v$librarycache ' .
         'is within the accepted limit ' . 
         'of 1%.';
   }
   else {
      $this_text =
         'Your Library Cache Hit Ratio on v$librarycache ' .
         'is above 1% and bad for performance.' . "\n" .
         'Your SHARED_POOL_SIZE value should be ' .
         'increased, and application SQL code should be better tuned.';
   }
   $y_start = $y_start + 0.5;
   $canvas->create('text', '0.8c', "$y_start" . 'c', 
                   -anchor => 'nw',
                   -justify => 'left',
                   -text => $this_text, 
                   -fill => $main::this_is_the_forecolour);
   $y_start = $y_start + 2;
   $y_end = $y_start + 0.3;
   $small_division = 50.00;
   $large_division = 100.00;
   if($hit_ratio >= ($small_division - 1.00)){
      $division = $large_division;
   } else {
      $division = $small_division;
   }
   $low_accept = 5.00;
   $high_accept = 30.00;
   $multiplier = (100.00/$division);
   $low_counter = $low_accept * $multiplier;
   $high_counter = $high_accept * $multiplier;
   for ($i_counter = 0;$i_counter < 100;$i_counter++){
      $x_start = ($i_counter/$screen_ratio) + 1.00;
      $x_stop = $x_start - $rec_width;
      if(($i_counter == $low_counter)||($i_counter == $high_counter)){
         $canvas->create((
           'rectangle', "$x_start" . 'c', 
           sprintf("%fc", ($y_start - 0.2)), "$x_stop" . 'c', 
                   sprintf("%fc", ($y_end + 0.2))));
      }
      $canvas->create(('rectangle', "$x_start" . 'c', 
                       "$y_start" . 'c', "$x_stop" . 'c', "$y_end" . 'c'));
      if((($hit_ratio * 100) /$division) > $i_counter){
         $canvas->create(('rectangle', "$x_start" . 'c', 
                          "$y_start" . 'c', "$x_stop" . 'c', "$y_end" . 'c'),
                          -fill => $main::this_is_the_forecolour);
      }
   }
   $canvas->create('text', "$x_start" . 'c', 
                   "$y_start" . 'c', -anchor => 'nw',
                   -justify => 'left',
                   -text => sprintf("%8.2f%%", $division), 
                   -fill => $main::this_is_the_forecolour);
   $y_start = $y_start + 0.5;
   $the_ratio = sprintf("%f", $hit_ratio);
   $the_ratio =~ s/[0]*$//g;
   $the_ratio =~ s/\.$/\.0/g;
   $canvas->create('text', '0.8c', "$y_start" . 'c', 
                   -anchor => 'nw',
                   -justify => 'left',
                   -text => 'hit_ratio = ' . "$the_ratio" . ' %', 
                   );
   if ($hit_ratio < $low_accept){
      $this_text =
         'Your Buffer Cache Hit Ratio is beneath the accepted ' . 
         'range of 5-30%.  Current size is optimal, but you may ' .
         'wish to ' . "\n" . 
         'consider removing buffers if memory is required elsewhere.';
   }
   elsif ($hit_ratio <= $high_accept){
      $this_text =
         'Your Buffer Cache Hit Ratio is within the accepted ' . 
         'range of 5-30%.  Do not remove any buffers from the buffer cache.';
   }
   else {
      $this_text =
         'Your Buffer Cache Hit Ratio is outside the accepted ' . 
         'range of 5-30%.  You should consider adding ' .
         'buffers to the buffer cache.';
   }
   $y_start = $y_start + 0.5;
   $canvas->create('text', '0.8c', "$y_start" . 'c', 
                   -anchor => 'nw',
                   -justify => 'left',
                   -text => $this_text, -fill => $main::this_is_the_forecolour);
   $y_start = $y_start + 2;
   $y_end = $y_start + 0.3;
   $small_division = 5.00;
   $large_division = 100.00;
   if($w2wait_ratio >= ($small_division - 1.00)){
      $division = $large_division;
   } else {
      $division = $small_division;
   }
   $accept = 1.00;
   $multiplier = (100.00/$division);
   $accept_counter = $accept * $multiplier;
   for ($i_counter = 0;$i_counter < 100;$i_counter++){
      $x_start = ($i_counter/$screen_ratio) + 1.00;
      $x_stop = $x_start - $rec_width;
      if($i_counter == $accept_counter){
         $canvas->create((
           'rectangle', "$x_start" . 'c', 
           sprintf("%fc", ($y_start - 0.2)), "$x_stop" . 'c', 
                   sprintf("%fc", ($y_end + 0.2))));
      }
      $canvas->create(('rectangle', "$x_start" . 'c', 
                       "$y_start" . 'c', "$x_stop" . 'c', "$y_end" . 'c'));
      if((($w2wait_ratio * 100) /$division) > $i_counter){
         $canvas->create(('rectangle', "$x_start" . 'c', 
                          "$y_start" . 'c', "$x_stop" . 'c', "$y_end" . 'c'),
                          -fill => $main::this_is_the_forecolour);
      }
   }
   $canvas->create('text', "$x_start" . 'c', 
                   "$y_start" . 'c', -anchor => 'nw',
                    -justify => 'left',
                    -text => sprintf("%8.2f%%", $division), 
                    -fill => $main::this_is_the_forecolour);
   $y_start = $y_start + 0.5;
   $the_ratio = sprintf("%f", $w2wait_ratio);
   $the_ratio =~ s/[0]*$//g;
   $the_ratio =~ s/\.$/\.0/g;
   $canvas->create('text', '0.8c', "$y_start" . 'c', 
                   -anchor => 'nw',
                   -justify => 'left',
                   -text => 'w2wait_ratio = ' . "$the_ratio" . ' %', 
                   );
   if ($w2wait_ratio <= $accept) {
      $this_text =
         'Your main \'Willing to Wait Ratio\' on v$latch, ' .
         'reflecting your log buffer, is within the accepted limit ' . 
         'of 1%.';
   }
   else {
      $this_text =
         'Your main \'Willing to Wait Ratio\' on v$latch is above 1% ' .
         'and bad for performance.' . "\n" .
         'Increase the size of your log buffer.';
   }
   $y_start = $y_start + 0.5;
   $canvas->create('text', '0.8c', "$y_start" . 'c', 
                   -anchor => 'nw',
                   -justify => 'left',
                   -text => $this_text, -fill => $main::this_is_the_forecolour);
   $y_start = $y_start + 2;
   $y_end = $y_start + 0.3;
   $small_division = 5.00;
   $large_division = 100.00;
   if($ratio >= ($small_division - 1.00)){
      $division = $large_division;
   } else {
      $division = $small_division;
   }
   $accept = 1.00;
   $multiplier = (100.00/$division);
   $accept_counter = $accept * $multiplier;
   for ($i_counter = 0;$i_counter < 100;$i_counter++){
      $x_start = ($i_counter/$screen_ratio) + 1.00;
      $x_stop = $x_start - $rec_width;
      if($i_counter == $accept_counter){
         $canvas->create((
           'rectangle', "$x_start" . 'c', 
           sprintf("%fc", ($y_start - 0.2)), "$x_stop" . 'c', 
           sprintf("%fc", ($y_end + 0.2))));
      }
      $canvas->create(('rectangle', "$x_start" . 'c', "$y_start" . 'c', 
                       "$x_stop" . 'c', "$y_end" . 'c'));
      if((($ratio * 100) /$division) > $i_counter){
         $canvas->create(('rectangle', "$x_start" . 'c', 
                          "$y_start" . 'c', "$x_stop" . 'c', "$y_end" . 'c'),
                          -fill => $main::this_is_the_forecolour);
      }
   }
   $canvas->create('text', "$x_start" . 'c', 
                   "$y_start" . 'c', -anchor => 'nw',
                    -justify => 'left',
                    -text => sprintf("%8.2f%%", $division), 
                    -fill => $main::this_is_the_forecolour);
   $y_start = $y_start + 0.5;
   $the_ratio = sprintf("%f", $ratio);
   $the_ratio =~ s/[0]*$//g;
   $the_ratio =~ s/\.$/\.0/g;
   $canvas->create('text', '0.8c', "$y_start" . 'c', 
                   -anchor => 'nw',
                   -justify => 'left',
                   -text => 'ratio = ' . "$the_ratio" . ' %');
   if ($ratio <= $accept) {
      $this_text =
         'Your main Rollback Ratio on v$rollstat ' .
         'is within the accepted limit ' . 
         'of 1%.';
   }
   else {
      $this_text =
         'Your main Rollback Ratio on v$rollstat ' .
         'is above 1% and bad for performance.' . "\n" .
         'Add more rollback segments.';
   }
   $y_start = $y_start + 0.5;
   $canvas->create('text', '0.8c', "$y_start" . 'c', 
                   -anchor => 'nw',
                   -justify => 'left',
                   -text => $this_text, -fill => $main::this_is_the_forecolour);
}
1;
