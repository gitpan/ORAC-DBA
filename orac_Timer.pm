package orac_Timer;

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
use Tk::Balloon;
sub timer {
   $timer_top = MainWindow->new();
   $this_title = "Orac Timesheet Calculator";
   $timer_top->title($this_title);
   my $icon_img = $timer_top->Pixmap('-file' => 'orac_images/orac_full.bmp');
   $timer_top->Icon('-image' => $icon_img);
   $timer_top->iconname($this_title);
   my(@layout_menu_bar) = qw/-side top -padx 5 -expand yes -fill both/;
   my $menu_bar = $timer_top->Frame()->pack(@layout_menu_bar);
   $menu_bar->Label(  -text        => 'Task Hours',
                      -borderwidth => 2,
                      -relief      => 'flat',
                   )->pack(-side => 'right', -anchor => 'e');
   $file_mb = $menu_bar->Menubutton(text        => 'File',
                                    relief      => 'raised',
                                    borderwidth => 2,
                                  )->pack('-side' => 'left',
                                          '-padx' => 2,
                                          );
   $file_mb->command(-label         => 'Exit',
                     -underline     => 1,
                     -command       => sub { return } );
   my $screen_title = "Please adjust the times to work out your weekly hours";
   my $title_length = length($screen_title);
   $label = $timer_top->Label( text   => $screen_title,
                               anchor => 'n',
                               relief => 'groove',
                               width  => $title_length,
                               height => 1);
   $label->pack();
   orac_Timer::draw_sliders;
   $zero_button = $timer_top->Button( text => 'Zeroize', 
                                      command => sub { $timer_top->Busy;orac_Timer::zero_orac('0');$timer_top->Unbusy });
   $zero_button->pack(side => 'left', anchor => 'sw');
   $zero_button = $timer_top->Button( text => 'Standardize', 
                                      command => sub { $timer_top->Busy;orac_Timer::zero_orac('1');$top->Unbusy });
   $zero_button->pack(side => 'left', anchor => 'sw');
   $back_button = $timer_top->Button( text    => 'Dismiss', command => sub { return });
   $back_button->pack(side => 'right', anchor => 'se');
   $timer_top->pack();
}
sub draw_sliders {
   
   $orac_Timer::tiler = $orac_Timer::timer_top->Scrolled('Tiler');
   $orac_Timer::tiler->configure(-rows => 9, -columns => 8);
   $orac_Timer::tiler->Manage( $orac_Timer::tiler->Label( text => '', relief => 'flat'));
   $orac_Timer::tiler->Manage( $orac_Timer::tiler->Label( text => "In\nHours", relief => 'flat'));
   $orac_Timer::tiler->Manage( $orac_Timer::tiler->Label( text => "\nMins", relief => 'flat'));
   $orac_Timer::tiler->Manage( $orac_Timer::tiler->Label( text => "Out\nHours", relief => 'flat'));
   $orac_Timer::tiler->Manage( $orac_Timer::tiler->Label( text => "\nMins", relief => 'flat'));
   $orac_Timer::tiler->Manage( $orac_Timer::tiler->Label( text => "Break\nHours", relief => 'flat'));
   $orac_Timer::tiler->Manage( $orac_Timer::tiler->Label( text => "\nMins", relief => 'flat'));
   $orac_Timer::tiler->Manage( $orac_Timer::tiler->Label( text => '', relief => 'flat'));
   $the_days[0] = 'Mon';
   $the_days[1] = 'Tue';
   $the_days[2] = 'Wed';
   $the_days[3] = 'Thu';
   $the_days[4] = 'Fri';
   $the_days[5] = 'Sat';
   $the_days[6] = 'Sun';
   $the_total = '';
   my $day_count = 0;
   while ($day_count < 7){
      $orac_Timer::tiler->Manage( $orac_Timer::tiler->Label( text => "$the_days[$day_count]", relief => 'flat'));
      orac_Timer::put_up_scales($day_count);
      $orac_Timer::tiler->Manage( $orac_Timer::tiler->Label( -textvariable => \$the_days[$day_count], relief => 'sunken', border => 5));
      $day_count++;
   }
   foreach (1 .. 6){
      $orac_Timer::tiler->Manage( $orac_Timer::tiler->Label( text => '', relief => 'flat'));
   }
   $orac_Timer::tiler->Manage( $orac_Timer::tiler->Label( -text => 'Total:', relief => 'flat'));
   $orac_Timer::tiler->Manage( $orac_Timer::tiler->Label( -textvariable => \$the_total, relief => 'raised', border => 5));
   $orac_Timer::tiler->pack();
}
sub put_up_scales {
   my($i_day_count, $dummy) = @_;
   my $scale_length = 60;
   orac_Timer::set_standard_hours();
   my $a_counter;
   if ($i_day_count >= 5){
      for ($a_counter = 0;$a_counter <= 5;$a_counter++){
         $standard_hours[$a_counter] = 0;
      }
   }
   $in_hour_scale[$i_day_count] = orac_Timer::draw_the_frame($i_day_count, 0, 23, $standard_hours[0], $scale_length, 0);
   $in_min_scale[$i_day_count] = orac_Timer::draw_the_frame($i_day_count, 0, 59, $standard_hours[1], $scale_length, 1);
   $out_hour_scale[$i_day_count] = orac_Timer::draw_the_frame($i_day_count, 0, 23, $standard_hours[2], $scale_length, 2);
   $out_min_scale[$i_day_count] = orac_Timer::draw_the_frame($i_day_count, 0, 59, $standard_hours[3], $scale_length, 3);
   $brk_hour_scale[$i_day_count] = orac_Timer::draw_the_frame($i_day_count, 0, 10, $standard_hours[4], $scale_length, 4);
   $brk_min_scale[$i_day_count] = orac_Timer::draw_the_frame($i_day_count, 0, 59, $standard_hours[5], $scale_length, 5);
}
sub draw_the_frame {
   ($this_day, $this_start, $this_end, $this_set, $this_length, $this_column) = @_;
   $orac_Timer::tiler->Manage( $generic_scale = $orac_Timer::tiler->Scale( -orient => horizontal, 
                                                   -length => $this_length, 
                                                   -from => $this_start,
                                                   -to => $this_end, 
                                                   -command => [\&calc_orac, $this_day, $this_column],
                                                 ));
   $generic_scale->set($this_set);
   return $generic_scale;
}
sub back_orac {
   exit 0;
}
sub calc_orac {
   my($y_param, $x_param, $scale_value) = @_;
   $all_values[$x_param][$y_param] = $scale_value;
   $day_total[$y_param] = ((($all_values[2][$y_param])*60) + $all_values[3][$y_param]) -          
                          ((($all_values[0][$y_param])*60) + $all_values[1][$y_param]) -           
                          ((($all_values[4][$y_param])*60) + $all_values[5][$y_param]);            
   
   $the_days[$y_param] = &day_splitter($day_total[$y_param]);
   $grand_total = 0.0;
   for ($y_param = 0;$y_param <= 6;$y_param++){
      $grand_total = $grand_total + $day_total[$y_param];
   }
   $the_total = &day_splitter($grand_total);
}
sub day_splitter {
   my($in_minutes, $dummy) = @_;
   my $the_minutes = $in_minutes % 60;
   $in_minutes = $in_minutes - $the_minutes;
   $the_hours = ($in_minutes/60);
   my $return_string = sprintf("%02d:%02d", $the_hours, $the_minutes);
   return $return_string;
}
sub zero_orac {
 
   my($input, $dummy) = @_;
   my $day_count = 0;
   if($input eq '1'){
      &set_standard_hours;
      while ($day_count < 5){
         $in_hour_scale[$day_count]->set($standard_hours[0]);
         $in_min_scale[$day_count]->set($standard_hours[1]);
         $out_hour_scale[$day_count]->set($standard_hours[2]);
         $out_min_scale[$day_count]->set($standard_hours[3]);
         $brk_hour_scale[$day_count]->set($standard_hours[4]);
         $brk_min_scale[$day_count]->set($standard_hours[5]);
   
         $day_count++;
      }
   }
   while ($day_count < 7){
      $in_hour_scale[$day_count]->set(0);
      $in_min_scale[$day_count]->set(0);
      $out_hour_scale[$day_count]->set(0);
      $out_min_scale[$day_count]->set(0);
      $brk_hour_scale[$day_count]->set(0);
      $brk_min_scale[$day_count]->set(0);
      $day_count++;
   }
}
sub set_standard_hours {
   $standard_hours[0] = 9;
   $standard_hours[1] = 0;
   $standard_hours[2] = 17;
   $standard_hours[3] = 30;
   $standard_hours[4] = 1;
   $standard_hours[5] = 0;
}
1;