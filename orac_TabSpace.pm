package orac_TabSpace;

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
sub tabspace_diag {
   package main;
   my $dialog = 
      $top->DialogBox( 
         -title => "Orac Tablespaces $v_machine $v_db",
         -buttons => [ "Dismiss" ]);

   my $canvas_frame = $dialog->Frame;
   $canvas_frame->pack(-expand => '1', -fill => 'both');
   my $canvas = 
     $canvas_frame->Scrolled('Canvas',
                            -relief => 'sunken', 
                            -background => $main::this_is_the_colour,
                            -bd => 2, width => 700, height => 500);
   
   $f1 = $canvas->Font(family => 'courier', weight => 'bold', size => 160);

   my $v_command = orac_Utils::file_string('sql_files', 'orac_TabSpace',
                                           'tabspace_diag','1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   my $v_feeder_com = orac_Utils::file_string('sql_files', 'orac_TabSpace',
                                              'tabspace_diag','2','sql');
   $v_counter = 0;
   my $v_sec_com;

   while (@v_this_text = $sth->fetchrow) {
      $v_bytes = $v_this_text[2];
      $v_used = $v_this_text[3];
      $v_free = $v_this_text[4];
      
      $v_sec_com = $v_feeder_com;
      $v_sec_com =~ s/orac_insert_v_bytes/$v_bytes/g;
      $v_sec_com =~ s/orac_insert_v_used/$v_used/g;
      $v_sec_com =~ s/orac_insert_v_free/$v_free/g;

      my $sec_sth = $dbh->prepare( $v_sec_com ) || die $dbh->errstr; 
      $rv = $sec_sth->execute;

      my @v_sizes = $sec_sth->fetchrow;
      $sec_rc = $sec_sth->finish;
      orac_TabSpace::add_item($f1, $canvas, $v_counter, 
                              $v_this_text[0], $v_this_text[5], 
                              $v_sizes[0], $v_sizes[1], $v_sizes[2]);
      $v_counter++;
   }
   $rc = $sth->finish;

   my $c_button = 
          $canvas->Button(
                     -text => 'See SQL',
                     -command => sub { main::banana_see_sql($v_command) } );

   my $y_start = orac_TabSpace::work_out_why($v_counter);
   $canvas->create('window', '1c', "$y_start" . 'c', -window => $c_button,
	           qw/-anchor nw -tags item/);
   $canvas->pack(-expand => 'yes', -fill => 'both');
   $dialog->Show();
}
sub work_out_why {
    my $y_entry = $_[0];
    return (0.8 + (1.2 * $y_entry));
}
sub add_item
{
    my ($this_font, $c, $y, $t, $pct, $bytes, $used, $free) = @_;
    my $thickness = 0.4;
    my $y_start = orac_TabSpace::work_out_why($y);
    my $y_end = $y_start + 0.4;
    my $fill = (100/10.0) + 0.4;
    $c->create(('rectangle', "$fill" . 'c',    
                "$y_start". 'c', '0.4c', "$y_end" . 'c'),
               -fill => 'SkyBlue2');

    my $fill = ($pct/10.0) + 0.4;
    $c->create(('rectangle', "$fill" . 'c', 
                "$y_start". 'c',   '0.4c',      "$y_end" . 'c'),
               -fill => 'Red');
  
    $y_start = $y_start - 0.4;
    $c->create(
            'text', '0.4c', 
            "$y_start" . 'c', -font => $this_font, -anchor => 'nw',
            -fill => $main::this_is_the_forecolour,
            -justify => 'left',
            -text => 'Tablespace ' . "$t" . ' is '. 
                     sprintf("%5.2f", $pct) . '% full');

    $y_start = $y_start + 0.4;
    $c->create('text', '10.4c', "$y_start" . 'c', 
               -font => $this_font, -anchor => 'nw',
               -fill => $main::this_is_the_forecolour,
               -justify => 'left',
               -text => sprintf("%8s Total %8s Used %8s Free", 
                                $bytes, $used, $free));
}
1;
