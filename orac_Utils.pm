package orac_Utils;

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
use Tk::NoteBook;
use Tk::LabEntry;
use Cwd;
use DBI;
use Tk::DialogBox;
use Tk::Balloon;
use Tk::HList;
use Time::Local;
sub login {
   package main;
   $orac_logging_file = ">>dbs/orac_logging_file.dbf";
   orac_Utils::log_message("attempted login by ${this_x_display}");
   my $orac_login_file = "dbs/orac_login.dbf";
   my $ret_val = 0;
   my $login_dialog;
   my $login_entry;
   my $password_entry;
   $v_login = 'guest';
   $this_is_the_password = 'guest';
   my $login_counter;
   my $done = 0;
   my %verify_logins;
   undef %verify_logins;
   do {
      $login_dialog = 
          $top->DialogBox( -title => "Orac - Login", 
                           -buttons => [ "Login", "Dismiss" ]);

      my $label_1 = 
           $login_dialog->Label(-text => "Login:", 
                                -anchor => 'e', 
                                -justify => 'right');

      $login_entry = $login_dialog->BrowseEntry(
                    -width => 40, 
                    -background => 'white', 
                    -foreground => 'black',
                    -variable => \$v_login,
                 );
      $login_counter = 0;
      my @tmp_ary;
      open(ORAC_LOGIN_FILE, "$orac_login_file");
      while(<ORAC_LOGIN_FILE>){
         @tmp_ary = split(/\^/);
         $total_nonce[$login_counter] = $tmp_ary[0];
         $verify_logins{"$tmp_ary[0]"} = 'true';
         $login_counter++;
      }
      $login_counter--;
      close(ORAC_LOGIN_FILE);
      @full_nonce = sort @total_nonce;
      foreach(@full_nonce){
         $login_entry->insert('end', $_);
      }
      my $label_2 = $login_dialog->Label( -text => 'Password:', 
                                          -anchor => 'e', 
                                          -justify => 'right');

      $password_entry = 
         $login_dialog->add("Entry", -show => '*',
                            -width => 40, 
                            -textvariable => \$this_is_the_password,
                            -background => 'white',
                            -foreground => 'black')->pack(side => 'right');

      Tk::grid($label_1,        -row => 0, -column => 0, -stick => 'e');
      Tk::grid($login_entry,    -row => 0, -column => 1, -stick => 'ew');
      Tk::grid($label_2,        -row => 1, -column => 0, -stick => 'e');
      Tk::grid($password_entry, -row => 1, -column => 1, -stick => 'ew');

      $login_dialog->gridRowconfigure(1, -weight => 1);
      $login_entry->focusForce;

      $main_button = $login_dialog->Show;

      if ($main_button eq "Login") {
         $this_is_the_password = $password_entry->get;
         if (defined($this_is_the_password) && length($this_is_the_password)){
            if (defined($v_login) && 
                length($v_login) && ($verify_logins{"$v_login"} eq 'true')){
               my $pass_true = 0;
               my @login_ary;
               $v_this_user_login_file = "dbs/${v_login}_user.dbf";
               open(ORAC_PASSWORD_FILE, $v_this_user_login_file);
               while(<ORAC_PASSWORD_FILE>){
                  @login_ary = split(/\^/);
                  if($login_ary[0] =~ /$this_is_the_password/){
                     $pass_true = 1;
                     $main::this_is_the_colour = $login_ary[1];
                     $main::this_is_the_forecolour = $login_ary[2];
                     $main::login_time = orac_Utils::timestring();
                     $ret_val = 1;
                     return $ret_val;
                  } else {
                     orac_Utils::please_reenter(
                          'Your password name is invalid.  Please re-enter.');
                     orac_Utils::log_message(
                          "invalid login:password " .
                          "=> ${v_login}:${this_is_the_password}");
                  }
               }
               close(ORAC_PASSWORD_FILE);
            } else {
               orac_Utils::please_reenter(
                    'Your login name is invalid.  Please re-enter.');
               orac_Utils::log_message(
                    "invalid login ${v_login}");
            }
         } else {
               orac_Utils::please_reenter(
                    'Please enter a valid password.');
               orac_Utils::log_message(
                    "invalid login:blank password " .
                    "=> ${v_login}:${this_is_the_password}");
         }
      }
      else {
         $done = 1;
      }
   } until $done;
   return ret_val;
}
sub please_reenter {
   package main;
   my($warn_text,$dummy) = @_;
   my $dialog = 
       $top->DialogBox( -title => "Orac Message", -buttons => [ "Dismiss" ]);

   $dialog->add("Label", -text => $warn_text)->pack;
   $dialog->Show;
}
sub timestring {
   my($seconds, $minutes, $hours, $day, $month, $year) = 
            (localtime)[0,1,2,3,4,5];

   my $time = sprintf("%02d:%02d:%02d %02d/%02d/%04d", 
                      $hours, $minutes, $seconds, 
                      $day, ($month + 1), ($year + 1900));
   return $time;
}
sub short_min_timestring {
   my($minutes, $hours) = (localtime)[1,2];
   my $time = sprintf("%02d:%02d", 
                      $hours, $minutes);
   return $time;
}
sub min_secs {
   my($secs) = (localtime)[ 0 ];
   return $secs;
}
sub log_message {
   my $this_message = $_[0];
   open(ORAC_LOGGING_FILE, $main::orac_logging_file);
   my $this_time = orac_Utils::timestring();
   print ORAC_LOGGING_FILE "${this_message}^${this_time}^\n";
   close(ORAC_LOGGING_FILE)
}
sub get_administrator {
   my @tmp_admin_ary;
   open(ORAC_ADMIN_FILE, "dbs/orac_admin.dbf");
   while(<ORAC_ADMIN_FILE>){
      @tmp_admin_ary = split(/\^/);
   }
   close(ORAC_ADMIN_FILE);
   return $tmp_admin_ary[0];
}
sub change_password {
   package main;
   my $old_password;
   my $new_password;
   my $reenter_new_password;
   my $password_dialog;
   my $done = 0;
   do {
      $password_dialog = 
           $top->DialogBox( -title => "Orac - Change Password", 
                            -buttons => [ "Change", "Dismiss" ]);
      my $label_1 = $password_dialog->Label(
                            -text => "Old Password:", 
                            -anchor => 'e', 
                            -justify => 'right');
      my $label_2 = $password_dialog->Label(
                            -text => 'New Password:', 
                            -anchor => 'e', 
                            -justify => 'right');
      my $label_3 = $password_dialog->Label(
                            -text => 'Re-enter New Password:', 
                            -anchor => 'e', 
                            -justify => 'right');
      $old_pw_entry = $password_dialog->add(
                            "Entry", 
                            -show => '*',
                            -width => 40, 
                            -textvariable => \$old_password,
                            -background => 'white',
                            -foreground => 'black')->pack(side => 'right');
      $new_pw_entry = 
          $password_dialog->add("Entry", -show => '*',
                                -width => 40, 
                                -textvariable => \$new_password,
                                -background => 'white',
                                -foreground => 'black')->pack(side => 'right');
      $ree_pw_entry = $password_dialog->add("Entry", -show => '*',
                                -width => 40, 
                                -textvariable => \$reenter_new_password,
                                -background => 'white',
                                -foreground => 'black')->pack(side => 'right');

      Tk::grid($label_1,      -row => 0, -column => 0, -stick => 'e');
      Tk::grid($old_pw_entry, -row => 0, -column => 1, -stick => 'ew');
      Tk::grid($label_2,      -row => 1, -column => 0, -stick => 'e');
      Tk::grid($new_pw_entry, -row => 1, -column => 1, -stick => 'ew');
      Tk::grid($label_3,      -row => 2, -column => 0, -stick => 'e');
      Tk::grid($ree_pw_entry, -row => 2, -column => 1, -stick => 'ew');

      $password_dialog->gridRowconfigure(1, -weight => 1);
      $old_pw_entry->focusForce;
      $main_button = $password_dialog->Show;
      if ($main_button eq "Change") {
         if (defined($old_password) && 
             length($old_password) && 
             ($main::this_is_the_password eq $old_password)){
            if (defined($new_password) && 
                length($new_password) && 
                ($main::this_is_the_password ne $new_password)){
               if (defined($reenter_new_password) && 
                   length($reenter_new_password) && 
                   ($reenter_new_password eq $new_password)){
                   $main::this_is_the_password = $new_password;
                   orac_Utils::please_reenter(
                        'Your password will be changed when you exit Orac.');
                   $done = 1;
               }
               else {
                  orac_Utils::please_reenter(
                        'Please enter new password the same in both boxes.');
               }
            }
            else {
               orac_Utils::please_reenter(
                        'Please enter a new different password.');
            }
         }
         else {
            orac_Utils::please_reenter(
                        'Your old password is invalid.  Please re-enter.');
         }
      }
      else {
         $done = 1;
      }
   } until $done;
   return ret_val;
}
sub view_admin {
   my $done = 0;
   do {
      my $view_dialog = $main::top->DialogBox( -title => 'Orac Admin File', 
                                         -buttons => [ "Action", "Dismiss" ]);
      my $label = 
          $view_dialog->Label( 
               text   => "Mark individual lines " .
                         "for delete or mark all appropriately",
               anchor => 'n',
               height => 1);
      $label->pack();

      my $tiler = $view_dialog->Scrolled('Tiler');
      $tiler->configure(-rows => 10, -columns => 3);
   
      my(@packer) = qw/-side left -pady 2 -anchor w/;
   
      $tiler->Manage( $tiler->Label(
                         -text     => 'Delete?',
                         -relief   => 'groove')->pack(@packer));
      $tiler->Manage( $tiler->Label(
                         -text     => 'Logged Entry',
                         -relief   => 'groove')->pack(@packer));
      $tiler->Manage( $tiler->Label(
                         -text     => 'Timestamp',
                         -relief   => 'groove')->pack(@packer));
      @del_cols;
      $del_count = 0;
   
      system ("touch dbs/orac_logging_file.dbf");
      system ("cp dbs/orac_logging_file.dbf dbs/orac_logging_file.dbf.bak");

      undef @hump_txt1;
      undef @hump_txt2;

      open(ADMIN_FILE, 'dbs/orac_logging_file.dbf');
      while (<ADMIN_FILE>){
         ($hump_txt1[$del_count],$hump_txt2[$del_count]) = split(/\^/, $_);
         $del_cols[$del_count] = 0;

         $tiler->Manage( $tiler->Checkbutton(
                         -variable => \$del_cols[$del_count],
                         -relief   => 'flat')->pack(@packer));
   
         $tiler->Manage ( $tiler->Entry(
            -textvariable => \$orac_Utils::hump_txt1[$del_count],
            -width        => length($orac_Utils::hump_txt1[$del_count]),
            -background   => 'white',
            -foreground   => 'black'));
   
         $tiler->Manage ( $tiler->Entry(
            -textvariable => \$orac_Utils::hump_txt2[$del_count],
            -width        => length($orac_Utils::hump_txt2[$del_count]),
            -background   => 'white',
            -foreground   => 'black'));
   
         $del_count++;
      }
      close(ADMIN_FILE);
      $del_count--;
      if ($del_count < 0){
         $tiler->Manage( $tiler->Label(
                            -text     => 'no rows found',
                            -relief   => 'flat')->pack(@packer));
      }
      else {
   
         my(@layout_bot_bar) = qw/-side bottom -padx 5/;
         my $bot_bar = $view_dialog->Frame->pack(@layout_bot_bar);
   
         $undelete_button = 
             $bot_bar->Button( text    => 'Mark Undelete All',
                               command => sub { $view_dialog->Busy;
                                                &mark_all(0);
                                                $view_dialog->Unbusy });
         $undelete_button->pack(side => 'right', anchor => 'e');

         $delete_button = 
             $bot_bar->Button( text    => 'Mark All for Delete',
                               command => sub { $view_dialog->Busy;
                                                &mark_all(1);
                                                $view_dialog->Unbusy });
         $delete_button->pack(side => 'right', anchor => 'e');
      }
      $tiler->pack();
      $main_button = $view_dialog->Show;

      if ($main_button eq "Action") {
         unless ($del_count < 0){
            # Have any been marked for delete?
            my $marked_for_delete = 0;
            my $i = 0;
            while (($i <= $del_count) && ($marked_for_delete == 0)){
               if ($del_cols[$i] == 1){
                  $marked_for_delete = 1;
               }
               $i++;
            }
            if ($marked_for_delete == 1){
               open(READ_FILE, "dbs/orac_logging_file.dbf.bak");
               open(WRITE_FILE, ">dbs/orac_logging_file.dbf");
               open(TWO_WRITE_FILE, ">dbs/orac_logging_file.dbf.del");
               my $i = 0;
               while (<READ_FILE>){
                  if ($del_cols[$i] == 0){
                     print WRITE_FILE $_;
                  }
                  else {
                     print TWO_WRITE_FILE $_;
                  }
                  $i++;
               }
               close(READ_FILE);
               close(WRITE_FILE);
               close(TWO_WRITE_FILE);
            }
         }
      }
      else {
            $done = 1;
      }
   } until $done;

   undef $del_count;
   undef @del_cols;
   undef @hump_txt1;
   undef @hump_txt2;
}
sub mark_all {
   my $marker = $_[0];
   for my $i (0..$del_count){
      $del_cols[$i] = $marker;
   }
}
sub file_string {
   my($dir,$package,$sub,$number,$suffix,$dummy) = @_;
   my $filename = sprintf("%s/%s.%s.%s.%s",
                  $dir,$package,$sub,$number,$suffix);
   my $ret_string = "";

   if($suffix eq 'sql'){
      my $inc_txt = sprintf("%s.%s.%s.%s",
                     $package,$sub,$number,$suffix);
      $ret_string = "/* $inc_txt */\n";
   }
   open(FILL_COM, $filename);
   while(<FILL_COM>){
      $ret_string = $ret_string . $_;
   }
   close(FILL_COM);
   return $ret_string;
}
1;
