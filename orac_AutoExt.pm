package orac_AutoExt;

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
sub auto_ext_orac {
   package main;
   $orac_AutoExt::keep_tablespace = 'XXXXXXXXXXXXXXX';
   my $this_title = "Orac AutoExtend Report $v_machine $v_db";
   my $dialog = $top->DialogBox( -title => $this_title, 
                                 -buttons => [ "Dismiss" ]);
   my $canvas_frame = $dialog->Frame;
   $canvas_frame->pack(-expand => '1', -fill => 'both');
   my $canvas = $canvas_frame->Canvas(-background => $main::this_is_the_colour,
                                      -relief => 'sunken', 
                                      -bd => 2, 
                                      -width => 980, 
                                      -height => 600);
   $f1 = $canvas->Font(family => 'courier', weight => 'bold', size => 160);

   my $vscroll = 
        $canvas_frame->Scrollbar(-command => ['yview', $canvas]);

   my $hscroll = 
        $canvas_frame->Scrollbar(-command => ['xview', $canvas], 
                                 -orient => 'horiz');

   $canvas->configure(-xscrollcommand => ['set', $hscroll], 
                      -yscrollcommand => ['set', $vscroll]);

   $vscroll->pack(-side => 'right', -fill => 'y');
   $hscroll->pack(-side => 'bottom', -fill => 'x');
   $canvas->pack(-expand => 'yes', -fill => 'both');
   $canvas->configure(-scrollregion => ['0', '0', '35c', '200c']);

   my $v_command = orac_Utils::file_string('sql_files', 'orac_AutoExt',
                                           'auto_ext_orac','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;
   orac_AutoExt::add_item( $f1, $canvas, 0, '', '', '', '', '', '', '');
   $v_counter = 1;

   while (@v_this_text = $sth->fetchrow) {

     my ($Tabspace, $Filename, $Filesize, $Maxsize, 
         $Nextsize, $Freesize, $dummy) = @v_this_text;

     orac_AutoExt::add_item( $f1, $canvas, $v_counter,
                             $Tabspace, $Filename, $Filesize, 
                             $Maxsize, $Nextsize, $Freesize);
     $v_counter++;
   }
   $rc = $sth->finish;
   $dialog->Show();
}
sub add_item
{
   package main;
   my ( $font, $canvas, $counter,
        $Tabspace, $Filename, $Filesize, $Maxsize, $Nextsize, $Freesize) = @_;
   my $y_start = (0.6 + (0.6 * $counter));
   my $y_end = $y_start + 0.3;
   if ($counter == 0){
      $top_colour = $main::this_is_the_forecolour;
      $this_text = 
         sprintf("%-15s %15s %8s %8s %8s %10s %-30s",
                 'TABLESPACE', 'FILENAME', 'FILESIZE',
                 'MAXSIZE','NEXTSIZE','FREESIZE', 'EXTENDING FILE?');
   }
   else {
      my $back_colour = 'white';
      $top_colour = 'blue';
      if ($Panic ne undef){
         if ($Panic =~ /PANIC/){
            $back_colour = 'Red';
            $top_colour = 'Red';
         }
         if ($Panic =~ /WARN/){
            $back_colour = 'Yellow';
            $top_colour = 'Red';
         }
      }
      my $thickness = 0.3;
   
      if ($orac_AutoExt::keep_tablespace eq $Tabspace){
         $Next_Tabspace = '';
      }
      else {
         my $this_y_start = $y_start + 0.1;
         $canvas->create(('line', 
                          '0.3c', 
                          "$this_y_start" . 'c', 
                          '27c', 
                          "$this_y_start" . 'c'), -fill => 'white');
         $Next_Tabspace = $Tabspace;
         $y_start = $y_start + 0.6; 
         $y_end = $y_end + 0.6; 
         $v_counter++;
      }
      $orac_AutoExt::keep_tablespace = $Tabspace;
      my $fill = 0.6;
      $canvas->create((   'rectangle', 
                          "$fill" . 'c',    
                          "$y_start". 'c',   
                          '0.3c',      
                          "$y_end" . 'c'), -fill => $back_colour);
   
      $this_text = 
         sprintf("%-15s %15s %8d %8d %8d %10.2f",
                 $Next_Tabspace, $Filename, $Filesize, 
                 $Maxsize, $Nextsize, $Freesize);
   }

   $canvas->create(
          'text', 
          '0.8c', 
          "$y_start" . 'c', 
          -font => $font, 
          -anchor => 'nw',
          -justify => 'left',
          -text => $this_text, -fill => $main::this_is_the_forecolour);

   unless (($Maxsize == 0) && ($Nextsize == 0)){
      my $the_start = 14.7;
      my $the_drop = 0.45;
      my $big_size = 8;
      my $this_roundup = 0.01;
      my $the_end = $the_start + $big_size;
      my $Filesize_text = $the_start + 0.1;
      my $Maxsize_text = $the_end + 0.1;
      my $this_fill = $y_end + 0.1;

      $canvas->create((
           'rectangle', 
           "$the_start" . 'c',    
           "$y_start". 'c',   
           "$the_end" . 'c', 
           "$this_fill" . 'c'),
           -fill => 'Skyblue2');

      $canvas->create(
           'text',
           "$Maxsize_text" . 'c',
           "$y_start" . 'c',
           -font => $font,
           -anchor => 'nw',
           -justify => 'left',
           -fill => $main::this_is_the_forecolour,
           -text => "Max $Filename");

      # Sorry about all these colours, I just
      # haven't got time to rejig it

      my $purple_x = $the_start + (($Filesize/$Maxsize) * $big_size);
      $canvas->create((
           'rectangle', 
           "$the_start" . 'c', 
           "$y_start". 'c', 
           "$purple_x" . 'c', 
           "$this_fill" . 'c'),
           -fill => 'purple');

      $canvas->create(
           'text',
           "$Filesize_text" . 'c',
           "$y_start" . 'c',
           -font => $font,
           -fill => $main::this_is_the_forecolour,
           -anchor => 'nw',
           -justify => 'left',
           -text => 'Curr File');

      $y_start = $y_start + $the_drop;
      $this_fill = $this_fill + $the_drop;
      my $yellow_x = $purple_x + (($Nextsize/$Maxsize) * $big_size);
      my $the_colour = "green";

      if(($Filesize + ($Nextsize * 1)) == $Maxsize){
         $the_colour = "yellow";
      }
      if(($Filesize + ($Nextsize * 1)) > $Maxsize){
         $the_colour = "red";
      }

      $canvas->create((
          'rectangle', 
          "$purple_x" . 'c', 
          "$y_start". 'c', 
          "$yellow_x" . 'c', 
          "$this_fill" . 'c'),
          -fill => $the_colour);

      $Nextsize_text = $purple_x - 0.9;
      $canvas->create(
                'text',
                "$Nextsize_text" . 'c',
                "$y_start" . 'c',
                -font => $font,
                -anchor => 'nw',
                -justify => 'left',
                -fill => $main::this_is_the_forecolour,
                -text => 'Nxt1');

      $y_start = $y_start + $the_drop;
      $this_fill = $this_fill + $the_drop;
      my $orange_x = $yellow_x + (($Nextsize/$Maxsize) * $big_size);

      if(($Filesize + ($Nextsize * 2)) == $Maxsize){
         $the_colour = "yellow";
      }
      if(($Filesize + ($Nextsize * 2)) > $Maxsize){
         $the_colour = "red";
      }

      $canvas->create((
         'rectangle', 
         "$yellow_x" . 'c', 
         "$y_start". 'c', 
         "$orange_x" . 'c', 
         "$this_fill" . 'c'),
         -fill => $the_colour);

      $Nextsize_text = $yellow_x - 0.9;

      $canvas->create(
        'text',
        "$Nextsize_text" . 'c',
        "$y_start" . 'c',
        -font => $font,
        -anchor => 'nw',
        -justify => 'left',
        -fill => $main::this_is_the_forecolour,
        -text => 'Nxt2');

      $y_start = $y_start + $the_drop;
      $this_fill = $this_fill + $the_drop;
      my $red_x = $orange_x + (($Nextsize/$Maxsize) * $big_size);

      if(($Filesize + ($Nextsize * 3)) == $Maxsize){
         $the_colour = "yellow";
      }
      if(($Filesize + ($Nextsize * 3)) > $Maxsize){
         $the_colour = "red";
      }

      $canvas->create((
           'rectangle', 
           "$orange_x" . 'c', 
           "$y_start". 'c', 
           "$red_x" . 'c', 
           "$this_fill" . 'c'),
           -fill => $the_colour);

      $Nextsize_text = $orange_x - 0.9;
      $canvas->create('text',
                      "$Nextsize_text" . 'c',
                      "$y_start" . 'c',
                      -font => $font,
                      -anchor => 'nw',
                      -justify => 'left',
                      -fill => $main::this_is_the_forecolour,
                      -text => 'Nxt3');

      $v_counter++;
      $v_counter++;
   }
}
1;
