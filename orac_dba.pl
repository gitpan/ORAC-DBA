#!/usr/local/bin/perl

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

# If you want a threaded clock in the top right-hand corner,
# uncomment some thready stuff below
#use Thread;

use Tk; 
use Tk::NoteBook;
use Tk::LabEntry;
use Cwd;
use DBI;
use Tk::DialogBox;
use Tk::Balloon;
use Tk::HList;
use orac_Utils;
use orac_UnixHelp;
use orac_BackGround;
use orac_Timer;
use orac_CreateDb;
use orac_DBAViewer;
use orac_Users;
use orac_Tune;
use orac_TuneHealth;
use orac_Pigs;
use orac_Wait;
use orac_Sess;
use orac_Secur;
use orac_SqlGen;
use orac_AllGen;
use orac_TabSpace;
use orac_TabDet;
use orac_MaxExt;
use orac_SynHlist;
use orac_SeqHlist;
use orac_GrantHlist;
use orac_LinkHlist;
use orac_UsersHlist;
use orac_RolesHlist;
use orac_ProfsHlist;
use orac_ViewHlist;
use orac_TabHlist;
use orac_TabSpHlist;
use orac_PackHlist;
use orac_ProcHlist;
use orac_FuncHlist;
use orac_RoleUser;
use orac_Links;
use orac_AddrSid;
use orac_SnapHlist;
use orac_SnapLogHlist;

$oracle_home = $ENV{"ORACLE_HOME"};

$top = MainWindow->new();

$menu_bar = $top->Frame()->pack(side => 'top', anchor => 'w');
my(@layout_menu_bar) = qw/-side top -padx 5 -expand yes -fill both/;
$menu_bar = $top->Frame->pack(@layout_menu_bar);
$this_is_the_curr_time = orac_Utils::short_min_timestring();

# Oh Thready clock, how I love you, but Tim says no

#$clock_config = $menu_bar->Label(  -textvariable => \$this_is_the_curr_time,
#      -borderwidth  => 2,
#      -relief       => 'sunken',
#      )->pack(-side => 'right', -anchor => 'e');

$menu_bar->Label(  
     -text        => 'Control Panel',
     -borderwidth => 2,
     -relief      => 'flat',
     )->pack(-side => 'right', -anchor => 'e');
$logo_label = $menu_bar->Label( 
     -image       => $top->Photo(-file => 'orac_images/orac.bmp'),
     -borderwidth => 2,
     -relief      => 'flat',
     )->pack(-side => 'left', -anchor => 'w');

$file_mb = $menu_bar->Menubutton(-text        => 'File',
                                 -relief      => 'raised',
                                 -underline   => 0,
                                 -borderwidth => 2,
                                  )->pack('-side' => 'left', '-padx' => 2,);
$file_mb->command(-label         => 'Reconnect',
                  -underline     => 0,
                  -command       => sub { &choose_database() } );
$file_mb->command(
       -label     => 'Orac Timer',
       -underline => 0,
       -state     => 'disabled',
       -command   => sub { $top->Busy;orac_Timer::timer; $top->Unbusy} );
$file_mb->separator();
$file_mb->command(
       -label     => 'About Orac & Terms of Use',
       -underline => 0,
       -command   => sub { $top->Busy;&about_orac(); $top->Unbusy} );
$file_mb->command(
           -label     => 'Server Information',
           -underline => 0,
           -command   => sub { $top->Busy;&server_orac(); $top->Unbusy} );

$menu_text = 'Background Colour Menu';
$file_mb->cascade(-label => $menu_text, -underline => 0);
$colour_menu = $file_mb->cget(-menu);
$actual_colours = $colour_menu->Menu;

$file_mb->entryconfigure($menu_text, -menu => $actual_colours);

open(COLOUR_FILE, "txt_files/colour_file.txt");
while(<COLOUR_FILE>){
   chomp;
   eval {
      $actual_colours->radiobutton(
                           -label      => $_,
                           -background => $_,
                           -command => [\&change_back_col],
                           -variable   => \$main::this_is_the_colour,
                           -value      => $_,
                   );
   };
   if ($@){
      orac_Utils::log_message(
         "Some problem with $_ background colour");
   }
}
close(COLOUR_FILE);

$menu_text = 'Foreground Colour Menu';
$file_mb->cascade(-label => $menu_text, -underline => 0);
$fore_colour_menu = $file_mb->cget(-menu);
$fore_actual_colours = $fore_colour_menu->Menu;

$file_mb->entryconfigure($menu_text, -menu => $fore_actual_colours);

open(COLOUR_FILE, "txt_files/colour_file.txt");
while(<COLOUR_FILE>){
   chomp;
   eval {
      $fore_actual_colours->radiobutton(
                           -label      => $_,
                           -background => $_,
                           -command => [\&change_fore_col],
                           -variable   => \$main::this_is_the_forecolour,
                           -value      => $_,
                   );
   };
   if ($@){
      orac_Utils::log_message(
         "Some problem with $_ foreground colour");
   }
}
close(COLOUR_FILE);

$file_mb->separator();
$file_mb->command(-label => 'Exit Orac', 
                  -underline => 1, 
                  -command => sub { &back_orac } );

$file_mb->separator();
$admin_text = 'Administration';
$admin_tag = $file_mb->cascade(-label => $admin_text, -underline => 0);
$admin_menu = $file_mb->cget(-menu);
$admin_list = $admin_menu->Menu;

$file_mb->entryconfigure($admin_text, -menu => $admin_list);

$view_admin_tag = $admin_list->command(
                       -label => 'View Admin Data', 
                       -underline => 1, 
                       -command => sub { orac_Utils::view_admin} );
$pass_tag = $admin_list->command(
                          -label => 'Change Password', 
                          -underline => 1, 
                          -command => sub { orac_Utils::change_password} );

$tablespace_mb = 
       $menu_bar->Menubutton(-text        => 'Structure',
                             -relief      => 'raised',
                             -borderwidth => 2,
                             -underline   => 0,
                            )->pack('-side' => 'left', '-padx' => 2,);
$tablespace_mb->command(
   -label     => 'Summary Chart by Tablespace',
   -underline => 0,
   -command   => sub { $top->Busy;orac_TabSpace::tabspace_diag;$top->Unbusy });
$tablespace_mb->command(
   -label     => 'Detailed Chart by Tablespace/Datafile',
   -underline => 0,
   -command   => sub { $top->Busy;orac_TabDet::tab_det_orac;$top->Unbusy } );
$tablespace_mb->separator();
$tablespace_mb->command(
    -label     => 'Database Files',
    -underline => 9,
    -command   => sub { $top->Busy;
                        &clear_orac;
                        orac_SqlGen::datafile_orac;
                        $top->Unbusy } );
$tablespace_mb->separator();
$tablespace_mb->command(
   -label     => 'Extents Report',
   -underline => 0,
   -command   => sub { $top->Busy;
                       &clear_orac;
                       orac_SqlGen::ext_orac;
                       $top->Unbusy } );
$tablespace_mb->command(
   -label     => 'Max Extents Free Space',
   -underline => 0,
   -command   => sub { $top->Busy;
                       &clear_orac;
                       orac_MaxExt::max_ext_orac;
                       $top->Unbusy } );

$grey_dbas = $tablespace_mb->command(
   -label         => 'DBA Tables Viewer',
   -underline => 1,
   -command   => sub { $top->Busy;
                       &clear_orac;
                       orac_DBAViewer::dbas_orac;
                       $top->Unbusy } );

$sql_gen_mb = $menu_bar->Menubutton(-text => 'Objects',
                                    -relief => 'raised',
                                    -borderwidth => 2, 
                                    -underline => 0,
                                    -menuitems =>
    [
     [Button    => '~Tables', 
       -command => sub {$top->Busy;
                        orac_TabHlist::tables_orac($top, $dbh);
                        $top->Unbusy}],
     [Button    => '~Views', 
       -command => sub {$top->Busy;
                        orac_ViewHlist::view_orac($top, $dbh);
                        $top->Unbusy}],
     [Button    => '~Synonyms', 
       -command => sub {
                        $top->Busy;
                        orac_SynHlist::syn_orac($top, $dbh);
                        $top->Unbusy}],
     [Button    => 'Sequences', 
       -underline => 1, 
                    -command => sub {
                        $top->Busy;
                        orac_SeqHlist::seq_orac($top, $dbh);
                        $top->Unbusy}],
     [Separator => ''],
     [Cascade   => '~Grants, Links, Roles, Users Etc', -menuitems =>
      [
       [Button    => '~Grants', 
                      -command => sub {$top->Busy;
                        orac_GrantHlist::grant_orac($top, $dbh);
                        $top->Unbusy}],
       [Button    => '~Links', 
                      -command => sub {
                        $top->Busy;
                        orac_LinkHlist::link_orac($top, $dbh);
                        $top->Unbusy}],
       [Button    => '~Users', 
                      -command => sub {
                        $top->Busy;
                        orac_UsersHlist::user_orac($top, $dbh);
                        $top->Unbusy}],
       [Button    => '~Roles', 
                      -command => sub {
                        $top->Busy;
                        orac_RolesHlist::role_orac($top, $dbh);
                        $top->Unbusy}],
       [Button    => '~Profiles', 
                      -command => sub {
                        $top->Busy;
                        orac_ProfsHlist::prof_orac($top, $dbh);
                        $top->Unbusy}],
      ],
     ],
     [Separator => ''],
     [Cascade   => '~PL/SQL', -menuitems =>
      [
       [Button  => 'Procedures', 
                -command => sub {
                  $top->Busy;
                  orac_ProcHlist::proc_orac($top, $dbh);
                  $top->Unbusy}, 
                -underline => 1,],
       [Button  => '~Functions', 
                -command => sub {
                  $top->Busy;
                  orac_FuncHlist::func_orac($top, $dbh);
                  $top->Unbusy}],
       [Button  => 'Packages', 
                -command => sub {
                  $top->Busy;
                  orac_PackHlist::pack_orac($top, $dbh);
                  $top->Unbusy}, 
                -underline => 1,],
      ],
     ],
     [Separator => ''],
     [Cascade   => 'Snapshots', -underline => 1, -menuitems =>
      [
       [Button  => 'Snapshots', -underline => 6, 
        -command => sub {
             $top->Busy;
             orac_SnapHlist::snap_orac($top, $dbh);
             $top->Unbusy}, ],
       [Button  => 'Snapshot Logs', -underline => 11, 
        -command => sub {
             $top->Busy;
             orac_SnapLogHlist::snaplog_orac($top, $dbh);
             $top->Unbusy}],
      ],
     ],
     [Separator => ''],
     [Cascade   => '\'All\' SQL Creation Statements', 
                   -underline => 1, 
                   -menuitems =>
      [
       [Button  => 'Grants', -underline => 0, 
        -command => sub { 
           $top->Busy;
           &clear_orac;
           orac_AllGen::all_grants;
           $top->Unbusy }, ],
       [Button  => 'Synonyms', -underline => 0, 
        -command => sub { 
           $top->Busy;
           &clear_orac;
           orac_AllGen::all_syns;
           $top->Unbusy }, ],
      ],
     ],
     [Cascade   => 'Database Recreation Scripts', 
                   -underline => 0, 
                   -menuitems =>
      [
       [Button    => 'Recreation of Basic Database SQL for svrmgrl', 
                     -underline => 14,
                     -command => sub { 
                        $top->Busy;
                        &clear_orac;
                        orac_SqlGen::create_db_script();
                        $top->Unbusy} ],
       [Button    => 'Raw Database Component SQL for svrmgrl', 
                     -underline => 2,
                     -command => sub { 
                         $top->Busy;
                         &clear_orac;
                         orac_SqlGen::panic_script();
                         $top->Unbusy} ],
      ],
     ],
    ])->pack('-side' => 'left',
             '-padx' => 2,
            );
$sql_gen_mb->separator();
$sql_gen_mb->command(-label         => 'Invalid Object Compiler',
                     -underline     => 0,
                     -command       => sub { $top->Busy;
                                             &clear_orac;
                                             orac_SqlGen::alter_comp_orac;
                                             $top->Unbusy } );
$grey_errors = $sql_gen_mb->command(
                     -label     => 'Error Finder',
                     -underline => 3,
                     -command   => sub { $top->Busy;
                          &clear_orac;
                          orac_SqlGen::errors_orac;
                          $top->Unbusy } );
$sql_gen_mb->separator();
$sql_gen_mb->command(
        -label => 'Tablespace Examiner',
        -underline => 1,
        -command   => sub { $top->Busy;
                            &clear_orac;
                            orac_TabSpHlist::tablespace_orac($top, $dbh);
                            $top->Unbusy } );

$users_mb = $menu_bar->Menubutton(-text        => 'Users',
                                  -relief      => 'raised',
                                  -borderwidth => 2,
                                  -underline   => 0,
                                 )->pack('-side' => 'left', '-padx' => 2,);
$users_mb->command(-label         => "Current Logged on Users",
                   -underline     => 0,
                   -command       => sub { 
                                      $top->Busy;
                                      &clear_orac;
                                      orac_Users::curr_users_orac;
                                      $top->Unbusy } );
$users_mb->command(-label         => "Registered Users on Database",
                   -underline     => 0,
                   -command       => sub { 
                                      $top->Busy;
                                      &clear_orac;
                                      orac_Users::user_rep_orac;
                                      $top->Unbusy } );
$users_mb->command(-label         => 'Any Users Updating on Database?',
                   -underline     => 2,
                   -command       => sub { 
                                      $top->Busy;
                                      &clear_orac;
                                      orac_Users::user_upd_orac;
                                      $top->Unbusy } );
$users_mb->command(-label         => 'Any User Processes Performing I/O?',
                   -underline     => 1,
                   -command       => sub { 
                                      $top->Busy;
                                      &clear_orac;
                                      orac_Users::user_io_orac;
                                      $top->Unbusy } );
$users_mb->command(
     -label     => 'What SQL statements are Users Processing?',
     -underline => 0,
     -command   => sub { $top->Busy;
                         &clear_orac;
                         orac_Users::what_sql;
                         $top->Unbusy } );
$users_mb->separator();
$users_mb->command(
     -label     => "Roles on Database",
     -underline => 0,
     -command   => sub { $top->Busy;
                         &clear_orac;
                         orac_Users::role_rep_orac;
                         $top->Unbusy } );
$users_mb->separator();
$users_mb->command(
   -label         => "Profiles on Database",
   -underline     => 0,
   -command       => sub { 
                         $top->Busy;
                         &clear_orac;
                         orac_Users::prof_rep_orac;
                         $top->Unbusy } );
$users_mb->command(
   -label         => "Quotas",
   -underline     => 0,
   -command       => sub { $top->Busy;
                           &clear_orac;
                           orac_Users::quot_rep_orac;
                           $top->Unbusy } );
$roll_mb = $menu_bar->Menubutton(-text        => 'Tuning',
                                 -relief      => 'raised',
                                 -borderwidth => 2,
                                 -underline   => 0,
                                 -menuitems   =>
    [
     [Button => 'Rollback Statistics', 
                -command => sub { 
                           $top->Busy;
                           &clear_orac;
                           orac_Tune::roll_orac;
                           $top->Unbusy },
                -underline => 9,],
     [Separator => ''],
     [Cascade   => '~Parameters', -menuitems =>
      [
       [Button  => 'nls_database_parameters', 
        -command => sub {
                           $top->Busy;
                           &clear_orac();
                           orac_Tune::nls_db_param_orac;
                           $top->Unbusy}, 
        -underline => 5,],
       [Button  => 'nls_instance_parameters', 
        -command => sub {
                           $top->Busy;
                           &clear_orac();
                           orac_Tune::nls_inst_param_orac;
                           $top->Unbusy}, 
        -underline => 4,],
       [Button  => 'nls_session_parameters', 
        -command => sub {
                           $top->Busy;
                           &clear_orac();
                           orac_Tune::nls_sess_param_orac;
                           $top->Unbusy}, 
        -underline => 5,],
       [Separator => ''],
       [Button  => 'Database Info', 
        -command => sub {
                           $top->Busy;
                           &clear_orac();
                           orac_Tune::vdoll_db_orac;
                           $top->Unbusy}, 
        -underline => 4,],
       [Button  => 'Version Info', 
        -command => sub {
                           $top->Busy;
                           &clear_orac();
                           orac_Tune::vdoll_version;
                           $top->Unbusy}, 
        -underline => 4,],
       [Button  => 'SGA Stats', 
        -command => sub {
                           $top->Busy;
                           &clear_orac();
                           orac_Tune::sgastat;
                           $top->Unbusy}, 
        -underline => 1,],
       [Button   => 'Show Parameters', 
        -command => sub {
                         $top->Busy;
                         &clear_orac();
                         orac_Tune::vdoll_param_simp;
                         $top->Unbusy}, 
        -underline => 4,],
      ],
     ],
     [Cascade   => '~Background Processes', -menuitems =>
      [
       [Cascade   => 'DBWR', -menuitems =>
        [
         [Button  => 'File I/O', 
          -command => sub {
                           $top->Busy;
                           &clear_orac();
                           orac_BackGround::dbwr_fileio;
                           $top->Unbusy}, 
          -underline => 2,],
         [Button  => 'DBWR Monitor', 
          -command => sub {
                           $top->Busy;
                           &clear_orac();
                           orac_BackGround::dbwr_monitor;
                           $top->Unbusy}, 
          -underline => 5,],
         [Button  => 'DBWR LRU Latches', 
          -command => sub {
                           $top->Busy;
                           &clear_orac();
                           orac_BackGround::dbwr_lru_latch;
                           $top->Unbusy}, 
          -underline => 5,],
        ],
       ],
       [Cascade   => 'LGWR', -menuitems =>
        [
         [Button  => 'LGWR Monitor', 
          -command => sub {
                           $top->Busy;
                           &clear_orac();
                           orac_BackGround::lgwr_monitor;
                           $top->Unbusy}, 
          -underline => 0,],
         [Button  => 'LGWR Redo Buffer Latches', 
          -command => sub {
                           $top->Busy;
                           &clear_orac();
                           orac_BackGround::lgwr_buff_latch;
                           $top->Unbusy}, 
          -underline => 5,],
        ],
       ],
       [Cascade   => 'DBWR & LGWR', -menuitems =>
        [
         [Button  => 'Waits Monitor', 
          -command => sub {
                           $top->Busy;
                           &clear_orac();
                           orac_BackGround::lgwr_and_dbwr_wait;
                           $top->Unbusy}, 
          -underline => 0,],
        ],
       ],
       [Cascade   => 'Sorts', -menuitems =>
        [
         [Button  => 'Sort Monitor', 
          -command => sub {
                           $top->Busy;
                           &clear_orac();
                           orac_BackGround::where_sorts;
                           $top->Unbusy}, 
          -underline => 0,],
         [Button  => 'Identify Sort Users', 
          -command => sub {
                           $top->Busy;
                           &clear_orac();
                           orac_BackGround::who_sorts;
                           $top->Unbusy}, 
          -underline => 0,],
        ],
       ],
      ],
     ],
     [Cascade   => '~Hit Ratios', -menuitems =>
      [
       [Button  => '~Sick Bay Stats', 
        -command => sub {
                           $top->Busy;
                           &clear_orac();
                           orac_TuneHealth::tune_health;
                           $top->Unbusy}, ],
       [Button  => '~Data Dictionary Hit Ratio',
        -command => sub { 
                           $top->Busy;
                           &clear_orac;
                           orac_Tune::dc_hit_ratio;
                           $top->Unbusy }, ],
       [Button  => 'Library Cache Hit Ratio',
        -command => sub { 
                           $top->Busy;
                           &clear_orac;
                           orac_Tune::lc_hit_ratio;
                           $top->Unbusy }, ],
      ],
     ],
     [Separator => ''],
     [Cascade   => '~Latches', -menuitems =>
      [
       [Button  => "Latch Wait Ratio", -underline => 1, 
        -command => sub { 
                           $top->Busy;
                           &clear_orac;
                           orac_Tune::latch_hit_ratio;
                           $top->Unbusy }, ],
       [Button  => "Latch Waiters", -underline => 6, 
        -command => sub { 
                           $top->Busy;
                           &clear_orac;
                           orac_Tune::act_latch_hit_ratio;
                           $top->Unbusy }, ],
      ],
     ],
     [Cascade   => '~Tablespace Tuning', -menuitems =>
      [
       [Button  => "Tablespace Fragmentation", -underline => 11, 
        -command => sub { 
                           $top->Busy;
                           &clear_orac;
                           orac_Tune::defragger;
                           $top->Unbusy }, ],
       [Button  => "Tablespace Space Shortages", -underline => 18, 
        -command => sub { 
                           $top->Busy;
                           &clear_orac;
                           orac_Tune::tab_shortage;
                           $top->Unbusy }, ],
      ],
     ],
     [Cascade   => '~Locks & Heavy Memory Hoggers', -menuitems =>
      [
       [Button  => "Locks currently held", -underline => 1,
        -command => sub { 
                           $top->Busy;
                           &clear_orac;
                           orac_Tune::lock_orac;
                           $top->Unbusy }, ],
       [Button  => "Who's holding back whom?", -underline => 0, 
        -command => sub { 
                           $top->Busy;
                           &clear_orac;
                           orac_Wait::wait_hold;
                           $top->Unbusy }, ],
       [Button  => "Who's logged on?", -underline => 0, 
        -command => sub { 
                           $top->Busy;
                           &clear_orac;
                           orac_Wait::who_logged_on;
                           $top->Unbusy }, ],
       [Button  => "Who's accessing which objects?", -underline => 0, 
        -command => sub { 
                           $top->Busy;
                           &clear_orac;
                           orac_Wait::lock_objects;
                           $top->Unbusy }, ],
       [Button  => "Rollback locks?", -underline => 0, 
        -command => sub { 
                           $top->Busy;
                           &clear_orac;
                           orac_Wait::rollback_locks;
                           $top->Unbusy }, ],
       [Button  => "Session Wait Statistics", -underline => 0, 
        -command => sub { 
                           $top->Busy;
                           &clear_orac;
                           orac_Wait::tune_wait;
                           $top->Unbusy }, ],
       [Button  => "Memory Hoggers", -underline => 0, 
        -command => sub { 
                           $top->Busy;
                           &clear_orac;
                           orac_Pigs::tune_pigs;
                           $top->Unbusy }, ],
      ],
     ],
    ])->pack('-side' => 'left', '-padx' => 2,);
$top_header_text = "Not Connected";
$label = 
 $top->Label(textvariable   => \$top_header_text,
             anchor => 'n',
             width => '100',
             relief => 'groove',
             height => 1);
$label->pack();
$procs_mb = $menu_bar->Menubutton(-text        => 'Who',
                                  -relief      => 'raised',
                                  -borderwidth => 2,
                                  -underline   => 0,
                                 )->pack('-side' => 'left', '-padx' => 2,);
$procs_mb->command(-label         => "Processes currently on Database",
                   -underline     => 0,
                   -command       => sub { 
                                      $top->Busy;
                                      &clear_orac;
                                      orac_Sess::spin_orac;
                                      $top->Unbusy } );
$procs_mb->command(-label         => "Connection Times",
                   -underline     => 0,
                   -command       => sub { 
                                      $top->Busy;
                                      &clear_orac;
                                      orac_Sess::conn_orac;
                                      $top->Unbusy } );
$procs_mb->separator();
$procs_mb->command(-label         => 'Specific Addresses & Sids',
                   -underline     => 9,
                   -command       => sub { 
                                      $top->Busy;
                                      orac_AddrSid::addr_orac($top, $dbh);
                                      $top->Unbusy } );
$procs_mb->separator();
$procs_mb->command(-label         => 'Direct Object Grants',
                   -underline     => 7,
                   -command       => sub { 
                                      $top->Busy;
                                      &clear_orac;
                                      orac_Secur::grant_orac;
                                      $top->Unbusy } );
$procs_mb->command(-label         => 'Table Grants',
                   -underline     => 0,
                   -command       => sub { 
                                      $top->Busy;
                                      &clear_orac;
                                      orac_Secur::table_orac;
                                      $top->Unbusy } );
$procs_mb->separator();
$procs_mb->command(-label         => 'All Privileges',
                   -underline     => 4,
                   "-command" => sub { 
                                      $top->Busy; 
                                      &clear_orac;
                                      orac_Secur::user_orac; 
                                      $top->Unbusy });
$procs_mb->separator();
$procs_mb->command(
  -label     => 'Single User Menu',
  -underline => 7,
  -command   => sub {$top->Busy;
                     orac_RoleUser::single_role_user($top,$dbh,'User');
                     $top->Unbusy });
$procs_mb->command(
  -label     => 'Single Role Menu',
  -underline => 7,
  -command   => sub {$top->Busy;
                     orac_RoleUser::single_role_user($top,$dbh,'Role');
                     $top->Unbusy });

$procs_mb->separator();
$procs_mb->command(
   -label         => 'Links',
   -underline     => 0,
   -command       => sub { $top->Busy;
                           &clear_orac;
                           orac_Links::links_orac();
                           $top->Unbusy } );

$unix_help_mb = $menu_bar->Menubutton(-bitmap      => 'questhead',
                                      -relief      => 'raised',
                                      -borderwidth => 2,
                                      -underline   => 0,
                                      -menuitems   =>
    [
     [Cascade   => '~Cron, etc', -menuitems =>
      [
       [Button  => 'Cron', 
        -command => sub {$top->Busy;
                         &clear_orac();
                         orac_UnixHelp::cron_help('cron');
                         $top->Unbusy}, 
        -underline => 0,
       ],
      ],
     ],
     [Cascade   => '~Alter System, etc', -menuitems =>
      [
       [Button  => 'Kill Session', 
        -command => sub {
                         $top->Busy;
                         &clear_orac();
                         orac_UnixHelp::cron_help('kill_sess');
                         $top->Unbusy}, 
        -underline => 0,
       ],
      ],
     ],
    ])->pack('-side' => 'left',
             '-padx' => 2,
            );

$v_text = $top->Scrolled('Text');
$v_text->pack(-expand => 1, -fil    => 'both');
tie (*TEXT, 'Tk::Text', $v_text);
my(@layout_status_bar) = qw/-side bottom -padx 5 -expand yes -fill both/;
$status_bar = $top->Frame->pack(@layout_status_bar);

$balloon_status = $status_bar->Label(-height => 4, -width => 100,
                                     -relief => 'sunken');

$balloon_status->pack(-side => "bottom", 
                      -fill => "y", 
                      -expand => 'yes',
                      -padx => 2, 
                      -pady => 1);

my $balloon = $top->Balloon(-statusbar => $balloon_status, 
                            -state => 'status');

$clear_button = $top->Button( text => 'Clear', 
                              command => sub { $top->Busy;
                                               &must_clear_orac;
                                               $top->Unbusy });
$clear_button->pack(side => 'left');
$v_clear_auto = 'Y';
$no_clear = $top->Radiobutton ( variable => \$v_clear_auto,
                                text     => 'Manual Clear',
                                value    => 'N');
$no_clear->pack (side => 'left');
$yes_clear = $top->Radiobutton ( variable => \$v_clear_auto,
                                 text     => 'Automatic Clear',
                                 value    => 'Y');
$yes_clear->pack (side => 'left');

$choose_button = 
    $top->Button( text    => 'Reconnect',
                  command => sub { $top->Busy;&choose_database;$top->Unbusy });
$choose_button->pack(side => 'right');

# OK, it's not pretty, but it does a job

$this_x_display = $ENV{"DISPLAY"};
@this_x_host = split(/:/, $this_x_display);
$this_x_host = $this_x_host[0];

# Ho hum

open(MY_HOSTNAME, "hostname|");
@this_hostname = <MY_HOSTNAME>;
$this_hostname = $this_hostname[0];
$this_hostname =~ s/\s//g;
$this_orac_version = 'ORAC-DBA-0.02';
close(MY_HOSTNAME);

$this_title = "Orac-Control Panel ($this_hostname)";
$top->title($this_title);

my $icon_img = $top->Pixmap('-file' => 'orac_images/orac_smid.bmp');
$top->Icon('-image' => $icon_img);
$top->iconname('Orac');

$we_have_valid_connect = 0;

&do_the_balloons();

undef $main::this_is_the_colour;
undef $main::this_is_the_forecolour;
if(orac_Utils::login() != 1){
   &back_orac();
} else {
   eval {
      $v_text->configure(
                 -background => $main::this_is_the_colour, 
                 -foreground => $main::this_is_the_forecolour);
   };
   if ($@){
      orac_Utils::log_message(
        "Some problem with configuring startup colours");

      $main::this_is_the_colour = "white"; 
      $main::this_is_the_forecolour = "black";
      $v_text->configure(
                 -background => $main::this_is_the_colour, 
                 -foreground => $main::this_is_the_forecolour);
   }

   orac_Utils::log_message("valid login $v_login to ${this_x_display}");

   $top->title($this_title);

   $orac_administrator = orac_Utils::get_administrator();
   if ($v_login eq 'guest'){
      $admin_tag->configure(-state => 'disabled');
   } else {
      unless ($v_login eq $orac_administrator){
         $view_admin_tag->configure(-state => 'disabled');
      }
   }
}
# Pretty thready thing, I will not desert you

#$main::clock_thread_kill = 0;
#$clock_thread = new Thread \&clock_goes;

&choose_database();

# Go!
MainLoop();

&back_orac();
sub clear_orac {
   if($v_clear_auto eq 'Y'){
      &must_clear_orac();
   }
}
sub must_clear_orac {
   $v_text->delete('1.0', 'end');
}
sub back_orac {
   #$main::clock_thread_kill = 1;
   if ($we_have_valid_connect){
      $rc  = $dbh->disconnect;
   }

   # You know, I really hate those hard-coders

   if (($v_login ne 'guest') && 
       defined($main::this_is_the_colour) && 
       defined($main::this_is_the_forecolour) && 
       length($main::this_is_the_colour) &&
       length($main::this_is_the_forecolour) &&
       length($main::this_is_the_password) &&
       length($main::this_is_the_password)){

      my $users_file = ">dbs/${v_login}_user.dbf";
      my $users_string = 
         "$this_is_the_password^$this_is_the_colour^$this_is_the_forecolour^\n";
      open(ORAC_USER_FILE, $users_file);
      print ORAC_USER_FILE $users_string;
      close(ORAC_USER_FILE);
   }
   orac_Utils::log_message("user exited $v_login to ${this_x_display}");
   exit 0;
}
sub get_connected {
   my $done = 0;
   if ($we_have_valid_connect == 1){
      &must_clear_orac();
      $top_header_text = "Disconnecting...";
      $rc  = $dbh->disconnect;
      $top_header_text = "Disconnected...";
      $we_have_valid_connect = 0;
   }
   do {
      $connect_dialog = 
         $top->DialogBox(-title => "Orac Database DBA System User Connection", 
                         -buttons => [ "Connect", "Help", "Dismiss" ]);
      my $label_1 = 
         $connect_dialog->Label(
                           -text => "Database:", 
                           -anchor => 'e', 
                           -justify => 'right');

      $db_list = $connect_dialog->BrowseEntry(
                    -background => 'white', 
                    -foreground => 'black',
                    -variable => \$v_db,
                 );

      my $counter = 0;
      open(DBFILE, "txt_files/orac_db_list.txt");
      while(<DBFILE>){
         chop;
         $total_nonce[$counter] = $_;
         $counter++;
      }
      close(DBFILE);
      @full_nonce = sort @total_nonce;
      $counter = 0;
      foreach(@full_nonce){
         $db_list->insert('end', $_);
      }
      my $label_2 = $connect_dialog->Label(-text => 'System Password:', 
                                           -anchor => 'e', 
                                           -justify => 'right');

      # Block out naughtiness with a 'show *'
      # shouldn't this be called a 'secret' option?

      $password_entry = 
         $connect_dialog->add("Entry", 
                              -show => '*',
                              -width => 40, 
                              -background => 'white',
                              -foreground => 'black')->pack(side => 'right');

      Tk::grid($label_1,        -row => 0, -column => 0, -stick => 'e');
      Tk::grid($db_list,        -row => 0, -column => 1, -stick => 'ew');
      Tk::grid($label_2,        -row => 1, -column => 0, -stick => 'e');
      Tk::grid($password_entry, -row => 1, -column => 1, -stick => 'ew');

      $connect_dialog->gridRowconfigure(1, -weight => 1);
      $db_list->focusForce;
      $main_button = $connect_dialog->Show;
      if ($main_button eq "Connect") {
         my $v_password = $password_entry->get;
         if (defined($v_password) && length($v_password)){
            $ENV{TWO_TASK} = $v_db;
            $ENV{ORACLE_SID} = $v_db;
            $top_header_text = "Connecting...";
            $top->Busy;
            $dbh = DBI->connect('dbi:Oracle:', 'system', $v_password);
            if ($DBI::errstr eq undef){
               $done = 1;
               $we_have_valid_connect = 1;
               $top_header_text = "Connected to $v_db";
            }
            else {
               $top_header_text = "";
            }
            $top->Unbusy;
         }
         else {
            orac_Utils::please_reenter(
                 "Please enter a SYSTEM user password for $v_db");
         }
      }
      elsif ($main_button eq "Help") {
         orac_UnixHelp::help_orac(
                 $connect_dialog, 'main', 'get_connected', '1');
      }
      else {
            $done = 1;
      }
   } until $done;
}
sub choose_database {
   &get_connected();
   unless ($we_have_valid_connect){
     my $dialog = $top->DialogBox( -title => "Orac Warning", 
                                   -buttons => [ "Acknowledge" ]);
     $dialog->add("Label", -text => '    Exiting Orac    ')->pack;
     $dialog->Show;
     &back_orac();
   }
   orac_SqlGen::get_block_size();

   # Yes OK, could be worse though?

   my $v_command = orac_Utils::file_string('sql_files', 'main',
                                           'choose_database', '1','sql');

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   my $rv = $sth->execute;
   my @v_this_text = $sth->fetchrow;
   my $rc = $sth->finish;
   $Block_Size = $v_this_text[0];
}

# A bit of cookbook magic

BEGIN {
   $SIG{__WARN__} = sub {
      if (defined $top) {
         my $dialog = $top->DialogBox( -title => "Orac Warning",
                                       -buttons => [ "Acknowledge" ]);
         $dialog->add("Label", -text => $_[0])->pack;
         $dialog->Show;
      }
      else {
         print STDOUT join("\n", @_), "n";
      }
   };
}

sub see_plsql {
   my ($v_this_text, $dummy) = @_;
   my $v_bouton = $v_text->Button(-text => 'See SQL',
                                  -command => sub { 
                                          $top->Busy;
                                          &banana_see_sql($v_this_text);
                                          $top->Unbusy },
	                          -cursor  => 'top_left_arrow');
   print TEXT "\n\n  ";
   $v_text->window('create', 'end', -window => $v_bouton);
   print TEXT "\n\n";
}

sub see_sql {
   my $dialog = $top->DialogBox( -title => "Orac See SQL",
                                 -buttons => [ "Dismiss" ]);
   my ($v_text,$dummy) = @_;
   my $loc_text = $dialog->Scrolled('Text', 
                     background => $main::this_is_the_colour,
                     foreground => $main::this_is_the_forecolour);
   $loc_text->pack(-expand => 1,
                   -fil    => 'both');
   tie (*THIS_TEXT, 'Tk::Text', $loc_text);
   print THIS_TEXT "rem\nrem  ORAC Generated SQL Report Code:\nrem\n$v_text\n";
   $dialog->Show;
}
sub banana_see_sql {
   my $dialog = $top->DialogBox( -title => 'Orac See PL/SQL', 
                                 -buttons => [ "Dismiss" ]);
   my ($v_text,$dummy) = @_;
   my $loc_text = $dialog->Scrolled('Text', 
                      background => $main::this_is_the_colour,
                      foreground => $main::this_is_the_forecolour);
   $loc_text->pack(-expand => 1, -fil    => 'both');
   tie (*THIS_TEXT, 'Tk::Text', $loc_text);
   print 
     THIS_TEXT "rem\nrem  ORAC Generated SQL Report Code:\nrem\n$v_text\n";
   $dialog->Show;
}
sub server_orac {
   $server_dialog = 
         $top->DialogBox(
               -title => 'Orac Release, Server & Client Information',
               -buttons => [ "Dismiss" ]);

   my $notebook = $server_dialog->add('NoteBook', 
                                      -ipadx => 6, 
                                      -ipady => 6, 
                                      -dynamicgeometry => 'true');
   my $server = $notebook->add(
                                      "server", 
                                      -label => 'Server & Display', 
                                      -underline => 0);
   my $version = $notebook->add(
                                      "version", 
                                      -label => "Version", 
                                      -underline => 0);
   my $release = $notebook->add(
                                      "release", 
                                      -label => "Release Date", 
                                      -underline => 0);
   my $author = $notebook->add(
                                      "author", 
                                      -label => "Authored By", 
                                      -underline => 0);
   my $login = $notebook->add(
                                      "login", 
                                      -label => 'Current Login', 
                                      -underline => 1);
   my $time = $notebook->add(
                                      "time", 
                                      -label => 'Login Time', 
                                      -underline => 1);

   my $local_date = '15th February 1999';
   my $local_author = 'Andy Duncan';
   my $local_email = 'andy_j_duncan@yahoo.com';

   $server->LabEntry(-width => length($this_hostname), 
                     -textvariable => \$this_hostname)->pack(-side => "top", 
                     -anchor => "nw");

   $server->LabEntry(-width => length($this_x_display), 
                     -textvariable => \$this_x_display)->pack(-side => "top", 
                     -anchor => "nw");

   $version->LabEntry(
      -width => length($this_orac_version), 
      -textvariable => \$this_orac_version)->pack(-side => "top", 
      -anchor => "nw");

   $release->LabEntry(-width => length($local_date), 
                      -textvariable => \$local_date)->pack(-side => "top", 
                      -anchor => "nw");

   $author->LabEntry(-width => length($local_author), 
                     -textvariable => \$local_author)->pack(-side => "top", 
                     -anchor => "nw");

   $author->LabEntry(-width => length($local_email), 
                    -textvariable => \$local_email)->pack(-side => "top", 
                     -anchor => "nw");

   $login->LabEntry(-width => length($v_login), 
                    -textvariable => \$v_login)->pack(-side => "top", 
                     -anchor => "nw");

   $time->LabEntry(-width => length($login_time), 
                    -textvariable => \$login_time)->pack(-side => "top", 
                     -anchor => "nw");

   $notebook->pack(
         -expand => "yes",
	 -fill   => "both",
	 -padx   => 5, -pady => 5,
	 -side   => "top");
   $server_dialog->Show;
}
sub about_orac {
   my $dialog = $top->DialogBox( -title => "Welcome to Orac", 
                                 -buttons => [ "Dismiss" ], 
                                 -width => 80);
   my $loc_text = $dialog->Scrolled('Text', 
                    background => $main::this_is_the_colour,
                    foreground => $main::this_is_the_forecolour);
   $loc_text->pack(-expand => 1, -fil => 'both');
   tie (*ABOUT_ORAC_TEXT, 'Tk::Text',$loc_text);
   my $text_stuff = "";
   open(TXT_FILE, "README");
   while(<TXT_FILE>){
      print ABOUT_ORAC_TEXT $_;
   }
   close(TXT_FILE);
   print ABOUT_ORAC_TEXT "\n";
   $orac_image = $dialog->Photo(-file => "orac_images/orac_full.bmp");
   my $v_bouton = 
    $loc_text->Button(-image   => $orac_image,
                      -command => sub { $top->Busy;&larry_pic();$top->Unbusy },
                     );
   $loc_text->window('create', 'end', -window => $v_bouton);
   print ABOUT_ORAC_TEXT "\n   (Press Me)";
   $dialog->Show;
}

sub larry_pic {
   my $dialog = $top->DialogBox( -title => "God Bless",
                                 -buttons => [ "Dismiss" ]
                               );
   my(@pl) = 
    qw/-side left -anchor center -expand yes -padx 20 -pady 20 -fill both/;
   my $right = $dialog->Frame->pack(@pl);
   @pl = qw/-side top -anchor center/;
   my $right_bitmap = $right->Label(
      -image       => $dialog->Photo(-file => 'orac_images/wall.gif'),
      -borderwidth => 2,
      -relief      => 'flat',
      )->pack(@pl);
   $dialog->Show;
}

sub do_the_balloons {
   my @clear_button_txt =  
         &get_balloon_txt('main', 'do_the_balloons','clear_button', 0);
   my @no_clear_txt =      
         &get_balloon_txt('main', 'do_the_balloons','no_clear', 0);
   my @yes_clear_txt =     
         &get_balloon_txt('main', 'do_the_balloons','yes_clear', 0);
   my @choose_button_txt = 
         &get_balloon_txt('main', 'do_the_balloons','choose_button', 0);

   $balloon->attach($clear_button,  -msg => $clear_button_txt[0]);
   $balloon->attach($no_clear,      -msg => $no_clear_txt[0]);
   $balloon->attach($yes_clear,     -msg => $yes_clear_txt[0]);
   $balloon->attach($choose_button, -msg => $choose_button_txt[0]);

   my @file_mb_txt = get_balloon_txt('main', 'do_the_balloons','file_mb', 0);
   $balloon->attach($file_mb, -msg => $file_mb_txt[0]);

   my @file_mb_balls_txt = 
         &get_balloon_txt('main', 'do_the_balloons','file_mb_balls', 11);
   my $file_mb_balls = $file_mb->cget(-menu);

   $balloon->attach($file_mb_balls,
   	         -balloonposition => 'mouse',
    	         -msg => [$file_mb_balls_txt[0], $file_mb_balls_txt[1],
                           $file_mb_balls_txt[2], $file_mb_balls_txt[3],
                           $file_mb_balls_txt[4], $file_mb_balls_txt[5],
                           $file_mb_balls_txt[6], $file_mb_balls_txt[7],
                           $file_mb_balls_txt[8], $file_mb_balls_txt[9],
                           $file_mb_balls_txt[10], $file_mb_balls_txt[11],
    	        ]);

   my @tablespace_mb_txt = 
          &get_balloon_txt('main', 'do_the_balloons','tablespace_mb', 0);

   $balloon->attach($tablespace_mb, 
              -msg => 'Diagrammatic (+ other) reports on tablespaces');
   my @tablespace_mb_balls_txt = 
          &get_balloon_txt('main', 'do_the_balloons','tablespace_mb_balls', 9);

   my $tablespace_mb_balls = $tablespace_mb->cget(-menu);

   $balloon->attach($tablespace_mb_balls,
      -balloonposition => 'mouse',
      -msg => [ $tablespace_mb_balls_txt[0], $tablespace_mb_balls_txt[1],
                $tablespace_mb_balls_txt[2], $tablespace_mb_balls_txt[3],
                $tablespace_mb_balls_txt[4], $tablespace_mb_balls_txt[5],
                $tablespace_mb_balls_txt[6], $tablespace_mb_balls_txt[7],
                $tablespace_mb_balls_txt[8],
   	        ]);

   my @users_mb_txt = 
          &get_balloon_txt('main', 'do_the_balloons','users_mb', 0);
   $balloon->attach($users_mb, -msg => $users_mb_txt[0]);
   my @users_mb_balls_txt = 
          &get_balloon_txt('main', 'do_the_balloons','users_mb_balls', 0);
   my $users_mb_balls = $users_mb->cget(-menu);
   $balloon->attach($users_mb_balls,
   	         -balloonposition => 'mouse',
   	         -msg => [$users_mb_balls_txt[0], $users_mb_balls_txt[1],
   	                  $users_mb_balls_txt[2], $users_mb_balls_txt[3],
   	                  $users_mb_balls_txt[4], $users_mb_balls_txt[5],
   	                  $users_mb_balls_txt[6], $users_mb_balls_txt[7],
   	                  $users_mb_balls_txt[8], $users_mb_balls_txt[9],
   	                  $users_mb_balls_txt[10],
   	        ]);
     my @sql_gen_mb_txt = 
            &get_balloon_txt('main', 'do_the_balloons','sql_gen_mb', 0);
     $balloon->attach($sql_gen_mb, -msg => $sql_gen_mb_txt[0]);
     my @sql_gen_mb_balls_txt = 
            &get_balloon_txt('main', 'do_the_balloons','sql_gen_mb_balls', 19);
     my $sql_gen_mb_balls = $sql_gen_mb->cget(-menu);
     $balloon->attach($sql_gen_mb_balls,
     	         -balloonposition => 'mouse',
     	         -msg => [$sql_gen_mb_balls_txt[0], $sql_gen_mb_balls_txt[1],
     	                  $sql_gen_mb_balls_txt[2], $sql_gen_mb_balls_txt[3],
     	                  $sql_gen_mb_balls_txt[4], $sql_gen_mb_balls_txt[5],
     	                  $sql_gen_mb_balls_txt[6], $sql_gen_mb_balls_txt[7],
     	                  $sql_gen_mb_balls_txt[8], $sql_gen_mb_balls_txt[9],
     	                  $sql_gen_mb_balls_txt[10], $sql_gen_mb_balls_txt[11],
     	                  $sql_gen_mb_balls_txt[12], $sql_gen_mb_balls_txt[13],
     	                  $sql_gen_mb_balls_txt[14], $sql_gen_mb_balls_txt[15],
     	                  $sql_gen_mb_balls_txt[16], $sql_gen_mb_balls_txt[17],
     	                  $sql_gen_mb_balls_txt[18],
     	        ]);
     my @roll_mb_txt = 
            &get_balloon_txt('main', 'do_the_balloons','roll_mb', 0);
     $balloon->attach($roll_mb, -msg => $roll_mb_txt[0]);
     my @roll_mb_balls_txt = 
            &get_balloon_txt('main', 'do_the_balloons','roll_mb_balls', 9);
     my $roll_mb_balls = $roll_mb->cget(-menu);
     $balloon->attach($roll_mb_balls,
     	         -balloonposition => 'mouse',
     	         -msg =>[$roll_mb_balls_txt[0], $roll_mb_balls_txt[1],
     	                 $roll_mb_balls_txt[2], $roll_mb_balls_txt[3],
     	                 $roll_mb_balls_txt[4], $roll_mb_balls_txt[5],
     	                 $roll_mb_balls_txt[6], $roll_mb_balls_txt[7],
     	                 $roll_mb_balls_txt[8], $roll_mb_balls_txt[9],
     	        ]);
              
     my @procs_mb_txt = 
            &get_balloon_txt('main', 'do_the_balloons','procs_mb', 0);
     $balloon->attach($procs_mb, -msg => $procs_mb_txt[0]);
  
     my @procs_mb_balls_txt = 
            &get_balloon_txt('main', 'do_the_balloons','procs_mb_balls', 14);
  
     my $procs_mb_balls = $procs_mb->cget(-menu);
  
     $balloon->attach($procs_mb_balls,
              -balloonposition => 'mouse',
              -msg => [$procs_mb_balls_txt[0], $procs_mb_balls_txt[1],
                       $procs_mb_balls_txt[2], $procs_mb_balls_txt[3],
                       $procs_mb_balls_txt[4], $procs_mb_balls_txt[5],
                       $procs_mb_balls_txt[6], $procs_mb_balls_txt[7],
                       $procs_mb_balls_txt[8], $procs_mb_balls_txt[9],
                       $procs_mb_balls_txt[10],$procs_mb_balls_txt[11],
                       $procs_mb_balls_txt[12],$procs_mb_balls_txt[13],
                       $procs_mb_balls_txt[14],
     	        ]);
  
     my @unix_help_mb_txt = 
            &get_balloon_txt('main', 'do_the_balloons','unix_help_mb', 0);
  
     $balloon->attach($unix_help_mb, -msg => $unix_help_mb_txt[0]);
  
     my @unix_help_mb_balls_txt = 
            &get_balloon_txt('main', 'do_the_balloons','unix_help_mb_balls', 2);
     my $unix_help_mb_balls = $unix_help_mb->cget(-menu);
     $balloon->attach($unix_help_mb_balls,
   	     -balloonposition => 'mouse',
     	     -msg => [$unix_help_mb_balls_txt[0], $unix_help_mb_balls_txt[1],
     	              $unix_help_mb_balls_txt[2],
     	        ]);
}

sub change_back_col {

   eval {
      $v_text->configure(-background => $main::this_is_the_colour);
   };
   if ($@){
      orac_Utils::log_message(
        "Some problem changing background to $main::this_is_the_colour");
      undef $main::this_is_the_colour;
      return;
   }

   my $comp_str = "";
   if (defined($dbaed_top)){
      $comp_str = $main::dbaed_top->state;
      if("$comp_str" ne 'withdrawn'){
         $orac_DBAViewer::dbaed_list->configure(
                  -background => $main::this_is_the_colour);
      }
   }
   if (defined($errored_top)){
      $comp_str = $main::errored_top->state;
      if("$comp_str" ne 'withdrawn'){
         $orac_SqlGen::errored_list->configure(
                  -background => $main::this_is_the_colour);
      }
   }
   if (defined($ex_top)){
      $comp_str = $main::ex_top->state;
      if("$comp_str" ne 'withdrawn'){
         $pig_bot_text->configure(-background => $main::this_is_the_colour);
      }
   }
}
sub change_fore_col {
   eval {
      $v_text->configure(-foreground => $main::this_is_the_forecolour);
   };
   if ($@){
      orac_Utils::log_message(
        "Some problem changing foreground to $main::this_is_the_forecolour");
      undef $main::this_is_the_forecolour;
      return;
   }

   my $comp_str = "";
   if (defined($dbaed_top)){
      $comp_str = $main::dbaed_top->state;
      if("$comp_str" ne 'withdrawn'){
         $orac_DBAViewer::dbaed_list->configure(
                  -foreground => $main::this_is_the_forecolour);
      }
   }
   if (defined($errored_top)){
      $comp_str = $main::errored_top->state;
      if("$comp_str" ne 'withdrawn'){
         $orac_SqlGen::errored_list->configure(
                  -foreground => $main::this_is_the_forecolour);
      }
   }
   if (defined($ex_top)){
      $comp_str = $main::ex_top->state;
      if("$comp_str" ne 'withdrawn'){
         $pig_bot_text->configure(
                  -foreground => $main::this_is_the_forecolour);
      }
   }
}
sub get_balloon_txt {
   my($module,$sub,$button,$files,$dummy) = @_;
   my @return_ary;
   my $text_file;
   for my $i (0..$files){
      $return_ary[$i] = "";
      $text_file = "menu_ball/${module}.${sub}.${button}.${i}.txt";
      open(TXT_FILE, $text_file);
      while(<TXT_FILE>){
         $return_ary[$i] = $return_ary[$i] . $_;
      }
      close(TXT_FILE);
      chomp($return_ary[$i]);
   }
   return @return_ary;
}

# Thready thing, I will return to you

#sub clock_goes {
#    my $first_time = 1;
#    my $sleep_time = 60;
#    while($main::clock_thread_kill == 0){
#        if ($first_time == 1){
#           $first_time = 0;
#           my $secs = orac_Utils::min_secs();
#           $sleep_time =  ((60 - $secs) + 2);
#        }
#        else {
#           $sleep_time = 60;
#        }
#        $this_is_the_curr_time = orac_Utils::short_min_timestring();
#	sleep $sleep_time;
#    }
#}
