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
   my $dialog = 
        $top->DialogBox( 
               -title => "Orac Max Extents $v_machine $v_db " .
                         "(Block Size $Block_Size)",
               -buttons => [ "Dismiss" ]);
   my $canvas_frame = $dialog->Frame;
   $canvas_frame->pack(-expand => '1', -fill => 'both');
   my $canvas = 
      $canvas_frame->Canvas( -background => $main::this_is_the_colour, 
                             -relief => 'sunken', 
                             -bd => 2, width => 740, height => 600);
   $f1 = $canvas->Font(family => 'courier', weight => 'bold', size => 160);
   
   my $vscroll = $canvas_frame->Scrollbar(-command => ['yview', $canvas]);
   my $hscroll = $canvas_frame->Scrollbar(-command => ['xview', $canvas],
                                         -orient => 'horiz');
   $canvas->configure(-xscrollcommand => ['set', $hscroll],
                     -yscrollcommand => ['set', $vscroll]);
   $vscroll->pack(-side => 'right', -fill => 'y');
   $hscroll->pack(-side => 'bottom', -fill => 'x');
   $canvas->pack(-expand => 'yes', -fill => 'both');
   $canvas->configure(-scrollregion => ['0', '0', '20c', '200c']);
   my $v_command = 

   my $v_command = orac_Utils::file_string('sql_files', 'orac_MaxExt',
                                           'max_ext_orac','1','sql');
   $v_command =~ s/orac_insert_Block_Size/$Block_Size/g;

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   orac_MaxExt::add_item( $f1, $canvas, 0, '', '', '', '', '', '', '', '');

   $v_counter = 1;
   while (@v_this_text = $sth->fetchrow) {
     my ($Tablespace, $Exts, $Total, 
         $Small, $Average, $Biggest, $Max_Nxt, $Panic, $dummy) = @v_this_text;
     orac_MaxExt::add_item( $f1, $canvas, $v_counter,
               $Tablespace, $Exts, $Total, 
               $Small, $Average, $Biggest, $Max_Nxt, $Panic);
     $v_counter++;
   }
   $rc = $sth->finish;

   $dialog->Show();
}
sub add_item
{
   package main;
   my (   $font, $canvas, $counter, 
          $Tablespace, $Exts, $Total, 
          $Small, $Average, $Biggest, $Max_Nxt, $Panic) = @_;
   my $y_start = (0.8 + (0.8 * $counter));
   my $y_end = $y_start + 0.4;
   my $we_need_line = 0;
   $text_colour = $main::this_is_the_forecolour;
   if ($counter == 0){
      $this_text = 
         sprintf("%20s %6s %10s %10s %10s %10s %10s %13s",
             'TABLESPACE', 'EXTS', 'TOTAL', 
             'SMALL', 'AVERAGE', 'BIGGEST', 'MAX_NXT', 'PANIC?');
      $we_need_line = 1;
   }
   else {
      my $back_colour = 'Green';
      if ($Panic ne undef){
         if ($Panic =~ /PANIC/){
            $back_colour = 'Red';
            $text_colour = 'Red';
         }
         if ($Panic =~ /WARN/){
            $back_colour = 'Yellow';
            $text_colour = 'Yellow';
         }
      }
   
      my $thickness = 0.4;
   
      my $fill = 0.8;
      $canvas->create(('rectangle', "$fill" . 'c',    
                       "$y_start". 'c', '0.4c', "$y_end" . 'c'),
                 -fill => $back_colour);
   
      $this_text = 
         sprintf("%20s %6d %10d %10d %10d %10d %10d %13s",
             $Tablespace, $Exts, $Total, 
             $Small, $Average, $Biggest, $Max_Nxt, $Panic);
   }
   $canvas->create('text', '0.4c', "$y_start" . 'c', 
          -font => $font, -anchor => 'nw',
          -justify => 'left',
          -text => $this_text,
          -fill => $text_colour);
   
   if($we_need_line == 1){
      my $line_y_start = $y_start + 0.5;
      $canvas->create(('line', '0.4c', "$line_y_start" . 'c', 
                       '19.5c', "$line_y_start" . 'c'));
   }
   $y_start = $y_start + 0.4;
}
1;
