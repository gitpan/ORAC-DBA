#!/usr/local/bin/perl
################################################################################
# Copyright (c) 1998,1999 Andy Duncan
#
# You may distribute under the terms of either the GNU General Public License
# or the Artistic License,as specified in the Perl README file,with the
# exception that it cannot be placed on a CD-ROM or similar media for commercial
# distribution without the prior approval of the author.
#
# This code is provided with no warranty of any kind,and is used entirely at
# your own risk. This code was written by the author as a private individual,
# and is in no way endorsed or warrantied.
#
# Support questions and suggestions can be directed to andy_j_duncan@yahoo.com
# Download from CPAN/authors/id/A/AN/ANDYDUNC
################################################################################
use Tk;
use Carp;
use FileHandle;
use Cwd;
use Time::Local;
use DBI;
use Tk::DialogBox;
use Tk::HList;
require Tk::BrowseEntry;

$bc = 'steelblue2';
$hc = 'red';
$ssq = 'See SQL';
$sc = 'green';
$ec = 'white';
$fc = 'black';
$mw = MainWindow->new();

my $li = $mw->Pixmap('-file' => 'sql/orac.bmp');
my(@layout_mb) = qw/-side top -padx 5 -expand no -fill both/;
$mb = $mw->Frame->pack(@layout_mb);
$mb->Label(-image => $li,-borderwidth => 2,-relief => 'flat')->pack(-side => 'left',-anchor => 'w');

$file_mb = $mb->Menubutton(-text => 'File',-relief => 'raised')->pack(-side => 'left',-padx => 2);
$file_mb->command(-label => 'Reconnect',-command => sub {&get_db()});
$file_mb->command(-label => 'About Orac & Terms of Use',-command => sub {&bz;&f_clr;&about_orac();&ubz});
$file_mb->separator();
$file_mb->command(-label => 'Exit',-command => sub {&back_orac } );

$ts_mb = $mb->Menubutton(-text => 'Structure',-relief => 'raised')->pack(-side => 'left',-padx => 2);
$ts_mb->command(-label => 'Summary Chart by Tablespace',
   -command => sub {&bz;&tab_det_orac('Tablespaces','tabspace_diag');;&ubz});
$ts_mb->command(-label => 'Detailed Chart by Tablespace/Datafile',
   -command => sub {&bz;&tab_det_orac('Datafiles','tab_det_orac');;&ubz});
$ts_mb->separator();
$ts_mb->command(-label => 'Database Files',-command => sub {&bz;&f_clr;
    &prep_lp('Database Files','datafile_orac','1',$rp_5_opt2,0);&ubz});
$ts_mb->command(-label => 'Extents Report',
    -command => sub {&bz;&f_clr;&prep_lp('Extents Report','ext_orac','1',$rp_8_opt3,0);&ubz});
$ts_mb->command(-label => 'Max Extents Free Space',-command => sub {&bz;&f_clr;my @params;my $i;
       for ($i = 0;$i < 9;$i++){$params[$i] = $Block_Size;};
       &prep_lp('Max Extents','max_ext_orac','1',$rp_8a_bits,0,@params);&ubz});
$sw_flag[0] = $ts_mb->command(-label => 'DBA Tables Viewer', 
       -command => sub {&f_clr;&sub_win(0,$mw,'dbas_orac','1','DBA Tables',50)});

$sql_gen_mb = $mb->Menubutton(-text => 'Object',-relief => 'raised',-borderwidth => 2,-menuitems =>
    [[Button => 'Tables',-command => sub {&bz;&gen_hlist(1,'Tables','.');&ubz}],
     [Button => 'Views',-command => sub {&bz;&gen_hlist(1,'Views','.');&ubz}],
     [Button    => 'Synonyms',-command => sub {&bz;&gen_hlist(1,'Synonyms','.');&ubz}],
     [Button    => 'Sequences',-command => sub {&bz;&gen_hlist(1,'Sequences','.');&ubz}],
     [Separator => ''],
     [Cascade   => 'Grants,Links,Roles,Users Etc',-menuitems =>
      [[Button => 'User Grants',-command => sub {&bz;&gen_hlist(2,'UserGrants','.');&ubz}],
       [Button => 'Role Grants',-command => sub {&bz;&gen_hlist(2,'RoleGrants','.');&ubz}],
       [Button => 'Links',-command => sub {&bz;&gen_hlist(1,'Links',':');&ubz}],
       [Button => 'Users',-command => sub {&bz;&gen_hlist(2,'Users','.');&ubz}],
       [Button => 'Roles',-command => sub {&bz;&gen_hlist(2,'Roles','.');&ubz}],
       [Button => 'Profiles',-command => sub {&bz;&gen_hlist(2,'Profiles','.');&ubz}],],
     ],
     [Separator => ''],
     [Cascade => 'PL/SQL',-menuitems =>
      [[Button => 'Procedures',-command => sub {&bz;&gen_hlist(1,'Procedures','.');&ubz}],
       [Button => 'Functions',-command => sub {&bz;&gen_hlist(1,'Functions','.');&ubz}],
       [Button => 'Triggers',-command => sub {&bz;&gen_hlist(1,'Triggers','.');&ubz}],
       [Button => 'Packages Heads',-command => sub {&bz;&gen_hlist(1,'PackageHeads','.');&ubz},],
       [Button => 'Packages Bods',-command => sub {&bz;&gen_hlist(1,'PackageBods','.');&ubz},],],
     ],
     [Cascade => 'Snapshots',-menuitems =>
      [[Button => 'Snapshots',-command => sub {&bz;&gen_hlist(1,'Snapshots','.');&ubz},],
       [Button  => 'Snapshot Logs',-command => sub {&bz;&gen_hlist(1,'SnapshotLogs','.');&ubz}],],
     ],
     [Separator => ''],
     [Cascade => '\'All\' SQL Creation Statements',-menuitems =>
      [[Button => 'Constraints',-command => sub {&bz;&f_clr;&all_stf('Constraints','3',2);&ubz},],
       [Button => 'Grants',-command => sub {&bz;&f_clr;&all_stf('UserGrants','3',4);&ubz},],
       [Button => 'Synonyms',-command => sub {&bz;&f_clr;&all_stf('Synonyms','3',2);;&ubz},],],
     ],
     [Cascade => 'Database Recreation SQL',-menuitems =>
      [[Button => 'Recreation of Basic Database SQL for svrmgrl',-command => sub {&bz;&f_clr;&orac_create_db();&ubz}],
       [Button => 'Raw Database Component SQL',
          -command => sub {&bz;&f_clr;&prep_lp('Raw Database Components','steps','1',$rp_big_one_tince,0);&ubz}],],
     ],
    ])->pack(-side => 'left',-padx => 2);
$sql_gen_mb->separator();
$sql_gen_mb->command(-label => 'Invalid Object SQL',-command => sub {&bz;&f_clr;
    &prep_lp('Invalid Object Recompilation Script','alter_comp_orac','1',$rp_big_one_left,0);&ubz});
$sw_flag[1] = $sql_gen_mb->command( -label => 'Error Finder',
    -command => sub {&f_clr;&sub_win(1,$mw,'errors_orac','1', 'Errored Objects',50)});

$user_mb = $mb->Menubutton(-text => 'User',-relief => 'raised',-borderwidth => 2,-menuitems =>
    [[Button => "Current Logged on Users",-command => sub {&bz;&f_clr;
      &prep_lp('Current Logged on Users','curr_users_orac','1',$rp_9_opt7,0);&ubz},],
     [Button => "Registered Users on Database",-command => sub {&bz;&f_clr;
      &prep_lp('Registered Users','user_rep_orac','1',$rp_6_opt4,0);&ubz},],
     [Separator => ''],
     [Button => "Any Users Updating on Database?",-command => sub {&bz;&f_clr;
      &prep_lp('Users Currently Updating','user_upd_orac','1',$rp_10_opt3,0);&ubz},],
     [Button => "Any User Processes Performing I/O?",-command => sub {&bz;&f_clr;
      &prep_lp('User Processes Currently Performing I/O','user_io_orac','1',$rp_7_opt4,0);&ubz},],
     [Button => "What SQL statements are Users Processing?",-command => sub {&bz;&f_clr;&what_sql;&ubz},],
     [Button => "Processes currently on Database",-command => sub {&bz;&f_clr;
      &prep_lp('Current Processes','spin_orac','1',$rp_10_bits,0);&ubz},],
     [Button  => "Connection Times",-command => sub {&bz;&f_clr;
      &prep_lp('Connection Times','conn_orac','1',$rp_7_opt2,0);&ubz},],
     [Separator => ''],
     [Button  => "Roles on Database",-command => sub {&bz;&f_clr;&prep_lp('Roles','role_rep_orac','1',$rp_5_opt5,0);&ubz},],
     [Button  => "Profiles on Database",-command => sub {&bz;&f_clr;
      &prep_lp('Profiles','prof_rep_orac','1',$rp_3_front_big,0);&ubz},],
     [Button  => "Quotas",-command => sub {&bz;&f_clr;
      &prep_lp('Quotas','quot_rep_orac','1',$rp_4_big_front,0);&ubz},],
     [Separator => ''],
    ])->pack(-side => 'left',-padx => 2);
$sw_flag[2] = $user_mb->command(-label => 'Specific Addresses',
                  -command => sub {&sub_win(2,$mw,'addr_orac','1','Specific Addresses',20)});
$sw_flag[3] = $user_mb->command(-label => 'Specific Sids',
                  -command => sub {&sub_win(3,$mw,'sids_orac','1','Specific Sids',20)});

$mb->Menubutton(-text => 'Tuning',-relief => 'raised',-borderwidth => 2,-menuitems =>
    [[Button => 'Rollback Statistics',-command => sub {&bz;&f_clr;
   &prep_lp('Rollback Stats','roll_orac','1',$rp_big_one_left,0);
   &prep_lp('','roll_orac','2',$rp_biz_roll_2,0);
   &prep_lp('','roll_orac','3',$rp_3_biggish,0);
   &prep_lp('','roll_orac','4',$rp_big_one_tiny,0);&print_roll_txt;&ubz},],
     [Button  => 'Hit Ratios',-command => sub {&bz;&tab_det_orac('Hit_Ratios','tune_health');&ubz},],
     [Separator => ''],
     [Cascade => 'Parameters',-menuitems =>
      [[Button  => 'NLS Parameters',-command => sub {&bz;&f_clr();
        &prep_lp('NLS Parameters','nls','1',$rp_3_split,0);&ubz},],
       [Button  => 'Database Info',-command => sub {&bz;&f_clr();&prep_lp('Database Info','database_info','','',0);&ubz},],
       [Button  => 'Version Info',-command => sub {&bz;&f_clr();
        &prep_lp("Version Information",'vdoll_version','1',$rp_big_one_left,0);&ubz},],
       [Button  => 'SGA Stats',-command => sub {&bz;&f_clr();
        &prep_lp('SGA Stat Information','sgastat','1',$rp_3_mid_big,0);&ubz},],
       [Button   => 'Show Parameters',-command => sub {&bz;&f_clr();
        &prep_lp('Show Parameters','vdoll_param_simp','1',$rp_two_splits,0);&ubz},],],
     ],
     [Cascade => 'Background Processes',-menuitems =>
      [[Cascade => 'DBWR',-menuitems =>
        [[Button => 'File I/O',-command => sub {&bz;&f_clr();&dbwr_fileio;&ubz},],
         [Button  => 'DBWR Monitor',-command => sub {&bz;&f_clr();
          &prep_lp('DBWR Monitor','dbwr_monitor','1',$rp_two_splits,0);&ubz}],
         [Button  => 'DBWR LRU Latches',-command => sub {&bz;&f_clr();
          &prep_lp('DBWR LRU Latches','dbwr_lru_latch','1',$rp_6_opt8,0);&ubz}],],
       ],
       [Cascade   => 'LGWR',-menuitems =>
        [[Button  => 'LGWR Monitor',-command => sub {&bz;&f_clr();
          &prep_lp('LGWR Monitor','lgwr_monitor','1',$rp_two_splits,0);&ubz}],
         [Button  => 'LGWR Redo Buffer Latches',-command => sub {&bz;&f_clr();
         &prep_lp('Redo Log Buffer Latches','lgwr_buff_latch','1',$rp_5_spread,0);&ubz},],],
       ],
       [Cascade   => 'DBWR & LGWR',-menuitems =>
        [[Button  => 'Waits Monitor',-command => sub {&bz;&f_clr();
          &prep_lp('DBWR & LGWR Waits','lgwr_and_dbwr_wait','1',$rp_3_front_big,0);&ubz},],],
       ],
       [Cascade   => 'Sorts',-menuitems =>
        [[Button  => 'Sort Monitor',-command => sub {&bz;&f_clr();
          &prep_lp('Sort Monitor','where_sorts','1',$rp_two_splits,0);&ubz},],
         [Button  => 'Identify Sort Users',
          -command => sub {&bz;&f_clr();
          &prep_lp('Identifying Sort Users','who_sorts','1',$rp_4_big_front,0);&ubz},],],
       ],],],
     [Cascade   => 'Latches',-menuitems =>
      [[Button  => "Latch Wait Ratio",-command => sub {&bz;&f_clr;
        &prep_lp('Current Latch Wait Ratios','latch_hit_ratio','1',$rp_3_front_big,0);&print_latch_wait;&ubz },],
       [Button  => "Latch Waiters",-command => sub {&bz;&f_clr;
        &prep_lp('Processes Experiencing Waits','act_latch_hit_ratio','1',$rp_3_front_big,0);&ubz},],
      ],],
     [Cascade   => 'Tablespace Tuning',-menuitems =>
      [[Button  => "Tablespace Fragmentation",-command => sub {&bz;&f_clr;
         &prep_lp('Tablespace Fragmentation','defragger','1',$rp_8_bits,0);&ubz},],
       [Button  => "Tablespace Space Shortages",-command => sub {&bz;&f_clr;my @params;my $i;
        for ($i = 0;$i < 2;$i++){$params[$i] = $Block_Size;};
        &prep_lp('Tablespace Space Shortages','tab_shortage','1',$rp_6_opt9,0,@params);&ubz},],],
     ],
    ])->pack(-side => 'left',-padx => 2);

$mb->Menubutton(-text => 'Lock',-relief => 'raised',-borderwidth => 2,-menuitems =>
    [[Button  => "Locks Currently Held",-command => sub {&bz;&f_clr;
      &prep_lp('Locks Currently Held','lock_orac','1',$rp_9_opt2,0);&ubz},],
     [Button  => "Who's holding back whom?",-command => sub {&bz;&f_clr;
      &prep_lp('Who\'s holding back whom?','wait_hold','1',$rp_hold_11,1);&ubz},],
     [Button  => "Who's accessing which objects?",-command => sub {&bz;&f_clr;
      &prep_lp('Who\'s accessing which objects?','lock_objects','1',$rp_6_opt7,0);&ubz},],
     [Button  => "Rollback locks?",-command => sub {&bz;&f_clr;
      &prep_lp('Rollback Locks?','rollback_locks','1',$rp_11_spread,0);&ubz },],
     [Button  => "Session Wait Statistics",-command => sub {&bz;&f_clr;&tune_wait;&ubz },],
     [Button  => "Memory Hoggers",-command => sub {&bz;&f_clr;&tune_pigs;&ubz },],
    ])->pack(-side => 'left',-padx => 2);

$l_top_t = "Not Connected";
$mb->Label(-textvariable => \$l_top_t,-relief => 'flat')->pack(-side => 'right',-anchor => 'e');
$v_text = $mw->Scrolled('Text',-wrap => 'none',-cursor => undef,-foreground => $fc,-background => $bc);
$v_text->pack(-expand => 1,-fil => 'both');
tie (*TEXT,'Tk::Text',$v_text);

$mw->Button(-text => 'Clear', -command => sub {&bz;&must_f_clr;&ubz})->pack(side => 'left');
$v_clr = 'Y';
$mw->Radiobutton(variable => \$v_clr,text => 'Manual Clear',value => 'N')->pack (side => 'left');
$mw->Radiobutton ( variable => \$v_clr,text => 'Automatic Clear',value => 'Y')->pack (side => 'left');
$mw->Button(-text => 'Reconnect',-command => sub {&bz;&get_db;&ubz})->pack(side => 'right');

$this_title = "Orac-Control Panel";
$mw->title($this_title);
$val_con = 0;
&get_db();
&set_printouts();

MainLoop();

&back_orac();
sub f_clr {
   if($v_clr eq 'Y'){
      &must_f_clr();
   }
}
sub must_f_clr {
   $v_text->delete('1.0','end');
}
sub back_orac {
   if ($val_con){
      $rc  = $dbh->disconnect;
   }
   exit 0;
}
sub get_connected {
   my $dn = 0;
   if ($val_con == 1){
      &must_f_clr();
      $rc = $dbh->disconnect;
      $l_top_t = "Disconnected...";
      $val_con = 0;
   }
   do {
      $c_d = $mw->DialogBox(-title => "DBA System User Connection",-buttons => [ "Connect","Exit" ]);
      my $l1 = $c_d->Label(-text => "Database:",-anchor => 'e',-justify => 'right');
      $db_list = $c_d->BrowseEntry(-cursor => undef,-variable => \$v_db,-foreground => $fc,-background => $ec);
      my %ls_db;

      my @h = DBI->data_sources('dbi:Oracle:');
      my $h = @h;
      my @ic;
      my $ic;
      for ($i = 1;$i < $h;$i++){
         @ic = split(/:/,$h[$i]);
         $ic = @ic;
         $ls_db{$ic[($ic - 1)]} = 101;
      }
      open(DBFILE,"sql/orac_db_list.txt");
      while(<DBFILE>){
         chomp;
         $ls_db{$_} = 102;
      }
      close(DBFILE);

      my $key;
      my @hd;
      undef @hd;
      $i = 0;
      foreach $key (keys %ls_db) {
         $hd[$i] = "$key";
         $i++;
      }
      my @hd2;
      @hd2 = sort @hd;

      foreach(@hd2){
         $db_list->insert('end',$_);
      }
      my $l2 = $c_d->Label(-text => 'System Password:',-anchor => 'e',-justify => 'right');
      $ps_e = $c_d->add("Entry",-cursor => undef,-show => '*',-foreground => $fc,
                        -background => $ec)->pack(side => 'right');
      Tk::grid($l1,     -row => 0,-column => 0,-sticky => 'e');
      Tk::grid($db_list,-row => 0,-column => 1,-sticky => 'ew');
      Tk::grid($l2,     -row => 1,-column => 0,-sticky => 'e');
      Tk::grid($ps_e,   -row => 1,-column => 1,-sticky => 'ew');

      $c_d->gridRowconfigure(1,-weight => 1);
      $db_list->focusForce;
      $mn_b = $c_d->Show;
      if ($mn_b eq "Connect") {
         my $v_ps = $ps_e->get;
         if (defined($v_ps) && length($v_ps)){
            $ENV{TWO_TASK} = $v_db;
            $ENV{ORACLE_SID} = $v_db;
            $l_top_t = "Connecting...";
            &bz;
            $dbh = DBI->connect('dbi:Oracle:','system',$v_ps);
            if (!defined($DBI::errstr)){
               $dn = 1;
               $val_con = 1;
               $dbh->func(1000000,'dbms_output_enable');
               if ((!defined($ls_db{$v_db})) || ($ls_db{$v_db} != 102)){
                  open(DBFILE,">>sql/orac_db_list.txt");
                  print DBFILE "$v_db\n";
                  close(DBFILE);
               }
               $l_top_t = "$v_db";
            } else {
               $l_top_t = "";
            }
            &ubz;
         } else {
            &mes($mw,"Please enter a SYSTEM user password");
         }
      } else {
         $dn = 1;
      }
   } until $dn;
}
sub get_db {
   &get_connected();
   unless ($val_con){
     &back_orac();
   }
   my $cm = &f_str('get_db','1');
   my $sth = $dbh->prepare($cm) || die $dbh->errstr; 
   $sth->execute;
   ($Block_Size) = $sth->fetchrow;
   $sth->finish;
}
sub see_plsql {
   my ($res,$dum) = @_;
   my $b = $v_text->Button(-text => $ssq,-command => sub {&see_sql($mw,$res)});
   print TEXT "\n\n  ";
   $v_text->window('create','end',-window => $b);
   print TEXT "\n\n";
}
sub see_sql {
   $_[0]->Busy;
   my $d = $_[0]->DialogBox(-title => $ssq);
   my $t = $d->Scrolled('Text',-height => 16,-width => 60,-wrap => 'none',-cursor => undef,
                 -foreground => $fc,-background => $bc);
   $t->pack(-expand => 1,-fil => 'both');
   tie (*THIS_TEXT,'Tk::Text',$t);
   print THIS_TEXT "$_[1]\n";
   orac_Show($d);
   $_[0]->Unbusy;
}
sub about_orac {
   open(TXT_FILE,"README");
   while(<TXT_FILE>){
      print TEXT $_;
   }
   close(TXT_FILE);
}
sub bz {
   $mw->Busy;
}
sub ubz {
   $mw->Unbusy;
}
sub print_roll_txt {
   my $roll_txt = "\n" .
      'If # Shrink is low:' . "\n" .
      '    If AvShr is low:' . "\n" .
      '        If Avgsz Activ is much smaller than Opt Mb:' . "\n" .
      '            Reduce OPTIMAL (since not many shrinks occur).' . "\n" .
      '    If AvShr is high:' . "\n" .
      '        Good value for OPTIMAL.' . "\n" .
      'If # Shrink is high:' . "\n" .
      '    If AvShr is low:' . "\n" .
      '        Too many shrinks being performed,since OPTIMAL is' . "\n" .
      '        somewhat (but not hugely) too small.' . "\n" .
      '    If AvShr is high:' . "\n" .
      '        Increase OPTIMAL until # of Shrnk decreases.  Periodic' . "\n" .
      '        long transactions are probably causing this.' . "\n\n" .
      'A high value in the #Ext column indicates dynamic extension,in which case' . "\n" .
      'you should consider increasing your rollback segment size.  (Also,increase' . "\n" .
      'it if you get a "Shapshot too old" error).  A high value in the # Extend' . "\n" .
      'and # Shrink columns indicate allocation and deallocation of extents, due' . "\n" .
      'to rollback segments with a smaller optimal size.  It also may be due to' . "\n" .
      'a batch processing transaction assigned to a smaller rollback segment.' . "\n" .
      'Consider increasing OPTIMAL.';
   print TEXT "\n${roll_txt}\n\n";
}
sub print_latch_wait {
   print TEXT "\n\nIf the same process shows up time and time again as holding\n" .
              "the latch named, and the wait ratio is high for that latch,\n" .
              "then there could be a problem with an event causing a wait\n" .
              "on the system.\n\n";
}
sub what_sql {
   my $d_txt = "This Report could take SOME TIME to run on a busy database.\nAre you sure you wish to run it?";
   my $chk_d = $mw->DialogBox(-buttons => [ "Yes","No" ]);
   $chk_d->add("Label",-text => $d_txt)->pack();
   my $b = $chk_d->Show;
   if($b eq 'Yes'){
      &prep_lp('What SQL','what_sql','1',$rp_8_opt4,0);
   }
}
sub set_printouts {
   $rp_big_one_left = 'l:80';
   $rp_big_one_tince = 'r:7,l:72';
   $rp_big_one_tiny = 'r:5,l:74';
   $rp_two_splits = 'r:38,l:38';
   $rp_3_split = 'l:25,r:25,l:25';
   $rp_3_mid_big = 'r:12,r:45,r:12';
   $rp_4_mid_big = 'l:5,r:12,r:60,r:12';
   $rp_3_biggish = 'r:25,r:25,r:25';
   $rp_3_front_big = 'r:32,r:22,r:22';
   $rp_4_mid_big = 'l:5,r:12,r:40,r:12';
   $rp_4_big_front = 'l:18,l:18,l:18,r:18';
   $rp_4_end_big = 'l:11,l:15,l:5,l:42';
   $rp_5_opt2 = 'l:4,l:20,r:31,r:6,r:6';
   $rp_5_opt5 = 'l:27,r:9,r:27,r:6,r:7';
   $rp_5_spread = 'r:20,r:11,r:11,r:12,r:11';
   $rp_5_errors = 'l:12,r:4,r:4,r:4,l:50';
   $rp_6_spread = 'r:12,r:10,r:10,r:12,r:5,r:23';
   $rp_6_opt4 = 'l:15,r:7,r:20,r:12,l:9,r:9';
   $rp_6_opt7 = 'l:10,l:12,r:5,r:5,l:28,l:12';
   $rp_6_opt8 = 'r:20,r:11,r:10,r:10,r:11,r:11';
   $rp_6_opt9 = 'l:18,r:7,r:8,r:11,r:11,r:8';
   $rp_7_opt2 = 'l:5,r:5,r:5,r:12,r:10,r:18,r:18';
   $rp_7_opt4 = 'r:4,l:15,l:17,r:9,r:9,r:8,r:10';
   $rp_8_bits = 'l:15,r:11,r:11,r:6,r:8,r:8,r:8,l:6';
   $rp_8a_bits = 'l:15,l:12,r:6,r:10,r:10,r:10,r:10,r:10';
   $rp_8_opt3 = 'l:10,l:20,l:5,l:20,r:4,r:4,r:6,r:3';
   $rp_8_opt4 = 'r:3,l:8,l:11,l:9,l:12,r:7,r:7,l:34';
   $rp_8_what = 'l:5,l:10,l:8,l:10,l:10,l:5,l:5,l:20';
   $rp_9_opt2 = 'l:10,r:5,l:12,r:5,r:5,l:7,l:15,r:9,r:9';
   $rp_9_opt7 = 'l:15,l:10,r:5,l:5,l:4,r:5,l:11,l:8,r:8';
   $rp_10_bits = 'l:8,r:5,r:5,r:8,r:5,r:10,r:18,r:4,r:3,r:3';
   $rp_10_opt3 = 'r:3,l:10,l:8,l:12,r:5,r:6,r:6,r:5,r:6,r:4';
   $rp_11_spread = 'l:4,l:12,l:10,l:12,r:5,r:5,r:5,r:5,r:4,r:4,r:4';
   $rp_hold_11 = 'l:10,l:8,r:5,r:5,r:5,r:2,l:10,l:8,r:5,r:5,r:5';
   $rp_biz_roll_2 = 'r:9,r:4,r:5,r:5,r:5,r:5,r:6,r:9,r:5,r:4,r:10,r:4,r:3,r:3,r:6';
}
sub f_str {
   my($sub,$number) = @_;
   my $file = sprintf("%s.%s.sql",$sub,$number);
   my $rt = "/* $file */\n";
   open(SQL,"sql/$file");
   while(<SQL>){
      $rt = $rt . $_;
   }
   close(SQL);
   return $rt;
}
sub crt_rp_do {
   $g_frm = shift;
   $^A = "";
   @vals = @_;
   eval { formline($g_frm,@vals); };
   if ($@){
      print "$@ \n";
   }
   return $^A;
}
sub crt_frm {
   my $frm_format = shift;
   my $flag = shift;
   my $ln = shift;
   my @arr = split(/,/,$frm_format);
   my $len_arr = @arr;
   my $format = "";
   my $i;
   my $j;
   my $part_1;
   my $part_2;
   my $sub_form = '^';
   my $sub_bit;
   for($i = 1;$i < $len_arr;$i++){
      ($part_1,$part_2) = split(/:/, $arr[$i]);
      if ($part_1 eq 'l'){
         $sub_bit = '<';
      } else {
         $sub_bit = '>';
      }
      for($j = 1;$j < $part_2;$j++){
         $sub_form = $sub_form . $sub_bit;
      }
      $format = $format . $sub_form;
      $sub_form = ' ^';
   }
   $format = $format . 'xyzzyxxyzzyx ~~';
   $j = @_;
   for($i = 0;$i < $j;$i++){
      if(!defined($_[$i])){
         $_[$i] = ' ';
      }
   }
   &cr_prt($format,$flag,$ln,@_);
   if($arr[0] eq 't'){
      @lines = crt_lines(@_);
      &cr_prt($format,$flag,$ln,@lines);
   }
}
sub crt_lines {
   my @ret = @_;
   my $len = @ret;
   my $i;
   for ($i = 0;$i < $len;$i++){
      $ret[$i] =~ s/./-/g;
   }
   return @ret;
}
sub cr_prt {
   my $format = shift;
   my $flag = shift;
   my $ln = shift;
   my $string = crt_rp_do($format, @_);
   $string =~ s/xyzzyxxyzzyx/\n/g;
   if((defined($flag)) && ($flag > 0) && ($flag != 2)){
      chomp($string);
   }
   print TEXT $string;
      
   if ((defined($flag)) && ($flag == 1)){
      if ($ln > 0){
         my $os_user = $_[7];
         my $oracl_user = $_[6];
         my $sid = $_[9];
         my $b = $v_text->Button(-text => 'sql?',-padx => 0, -pady => 0,
                -command => sub { $mw->Busy;&who_what($os_user,$oracl_user,$sid);$mw->Unbusy });
         $v_text->window('create', 'end', -window => $b);
      }
      print TEXT "\n";
   }
}
sub prep_lp {
   $tit = shift;
   $sub = shift;
   $num = shift;
   $frm = shift;
   $flag = shift;
   my @bindee = @_;
   my $num_bind = @bindee;
   my $cm;
   if($sub eq 'sel_addr'){
      $cm = &get_sel_stat('sys','v_$session');
      $frm = &get_frm($cm);
      $cm = $cm . ' where paddr = ? ';
   } elsif($sub eq 'database_info'){
      $cm = &get_sel_stat('sys','v_$database');
      $frm = &get_frm($cm);
   } else {
      $cm = &f_str($sub,$num);
   }
   my $sth = $dbh->prepare($cm) || die $dbh->errstr; 

   if ($num_bind > 0){
      my $i;
      for ($i = 1;$i <= $num_bind;$i++){
         $sth->bind_param($i,$bindee[($i - 1)]);
      }
   }
   $sth->execute;
   my $detected = 0;
   while (@res = $sth->fetchrow) {
      if (($detected == 0) &&($flag >= 0)){
         &tit_do($detected,$tit,$frm,$sth,$flag);
      }
      $detected++;
      &crt_frm(('b,' . $frm),$flag,$detected,@res);
   }
   if (($detected == 0) &&($flag >= 0)){
      &tit_do($detected,$tit,$frm,$sth);
      print TEXT "no rows found\n";
   }
   if(($flag == 0) || ($flag == 1) || ($flag == -2)){
      see_plsql( $sth->{"Statement"} );
   }
   $sth->finish;
   return $cm;
} 
sub tit_do {
   my($detect,$tit,$frm,$sth,$flag) = @_;
   if((defined($tit)) && ((length($tit) > 0))){
      print TEXT "REPORT $tit ($v_db):\n\n";
   }
   my @tit_vals;
   my $i;
   for ($i = 0;$i < $sth->{NUM_OF_FIELDS};$i++){
      $tit_vals[$i] = $sth->{NAME}->[$i];
   }
   &crt_frm(('t,' . $frm),$flag,$detect,@tit_vals);
}
sub tune_wait {
   my $cm = &f_str('tune_wait','1');
   my $sth = $dbh->prepare( $cm ) || die $dbh->errstr; 
   $sth->execute;
   my $j = 0;
   my $blnks = 0;
   my $get_str;
   while($j < 5000){
      $get_str = scalar $dbh->func('dbms_output_get');
      if(defined($get_str)){
         print TEXT "$get_str\n";
      }
      if ((!defined($get_str)) || (length($get_str) == 0)){
         $blnks++;
         if ($blnks > 10){
            last;
         }
      } else {
         $blnks = 0;
      }
      $j++;
   }
   &see_plsql($cm);
}
sub tune_pigs {
   my $cm = &f_str('tune_pigs','1');
   my $sth = $dbh->prepare($cm) || die $dbh->errstr; 
   $sth->execute;

   my $j = 0;
   my @banana;
   my $iopigs_fill_counter = 0;
   my $mempigs_fill_counter = 0;
   my $we_have_iopigs = 0;
   my $we_have_mempigs = 0;
   my $get_str;
   while($j < 2000){
      $get_str = scalar $dbh->func('dbms_output_get');
      if((defined($get_str)) && ($get_str =~ /\^/)){
         @banana = split(/\^/, $get_str);
         if ($banana[0] == 99){
            $the_top_title = "$banana[1]: $banana[2]\n\n";
         } elsif ($banana[0] == 3){
            $the_memory_title1 = "$banana[1]\n";
         } elsif ($banana[0] == 4){
            $the_memory_title2 = "$banana[1]\n\n";
         } elsif ($banana[0] == 5){
            $the_io_title1 = "\n\n$banana[1]\n";
         } elsif ($banana[0] == 6){
            $the_io_title2 = "$banana[1]\n\n";
         } elsif ($banana[0] > 200000){
            $mempigs_fill[$mempigs_fill_counter] = $get_str;
            $mempigs_fill_counter++;
            $we_have_mempigs = 1;
         } elsif ($banana[0] > 100000){
            $iopigs_fill[$iopigs_fill_counter] = $get_str;
            $iopigs_fill_counter++;
            $we_have_iopigs = 1;
         }
      }
      if ((defined($get_str)) || (length($get_str)) == 0){
         last;
      }
      $j++;
   }
   print TEXT $the_top_title;
   if (($we_have_mempigs == 0) && ($we_have_iopigs == 0)){
       print TEXT "no memory hoggers found";
   } else {
      if ($we_have_mempigs == 1){
         print TEXT $the_memory_title1;
         print TEXT $the_memory_title2;
         &crt_frm(('t,' . $rp_4_end_big),0,0,'Buffer Gets', 'Username', 'SID', 'SQL Text');
         for ($i = 0;$i < $mempigs_fill_counter;$i++){
            my @ar = split(/\^/, $mempigs_fill[$i]);
            &crt_frm(('b,' . $rp_4_end_big),0,0,$ar[3],$ar[1],$ar[2],$ar[6]);
         }
      }
      if ($we_have_iopigs == 1){
         print TEXT $the_io_title1;
         print TEXT $the_io_title2;
         &crt_frm(('t,' . $rp_6_spread),0,0,'Disk Reads','Execs','Reads/Exec','Username','SID','SQL Text');
         for ($i = 0;$i < $iopigs_fill_counter;$i++){
            my @ar = split(/\^/, $iopigs_fill[$i]);
            &crt_frm(('b,' . $rp_6_spread),0,0,$ar[3],$ar[4],$ar[5],$ar[1],$ar[2],$ar[6]);
         }
      }
   }
   &see_plsql($cm);
}
sub get_sel_stat {
   my($owner,$table) = @_;
   my $cm = "select column_name from dba_tab_columns where " .
            "upper(owner) = upper('${owner}') and upper(table_name) = upper('${table}') order by column_id ";
   my $ret = " select ";
   my $i = 0;
   my $bit_str;
   my $sth = $dbh->prepare($cm) || die $dbh->errstr; 
   $sth->execute;
   while (@res = $sth->fetchrow) {
      if ($i == 0){
         $bit_str = ' ';
         $i++;
      } else {
         $bit_str = ' , ';
      }
      $ret = $ret . $bit_str . $res[0] . ' ';
   }
   $sth->finish;
   $ret = $ret . "\n" . 'from ' . $owner . '.' . $table . " \n";
   return $ret;
}
sub get_frm {
   my($cm) = @_;
   my $sth = $dbh->prepare($cm) || die $dbh->errstr; 
   $sth->execute;
   my $ret;
   if (@res = $sth->fetchrow) {
      my $i = 0;
      my $str = "";
      for($i = 0;$i < $sth->{NUM_OF_FIELDS};$i++){
         $str = $sth->{NAME}->[$i];
         my $l = length($str);
         if ($l < 8){ 
            $l = 8;
         }
         if($i == 0){
            $ret = 'r:' . $l;
         } else {
            $ret = $ret . ',r:' . $l;
         }
      }
   }
   $sth->finish;
   return $ret;
}
sub who_what {
   my ($os_user,$oracle_user,$sid) = @_;
   my $d = $mw->DialogBox(-title   => "Investigation on $os_user");
   my $loc_text = $d->Scrolled('Text',-wrap => 'none',-cursor => undef,-foreground => $fc,-background => $bc);
   $loc_text->pack(-expand => 1, -fil => 'both');
   tie (*TEXT, 'Tk::Text', $loc_text);
   my $cm = &prep_lp('Holding SQL','who_what','1',$rp_8_what,2,$os_user,$oracle_user,$sid);
   my $b = $loc_text->Button(-text => $ssq,-command => sub {&see_sql($d,$cm)});
   $loc_text->window('create','end', -window => $b);
   tie (*TEXT, 'Tk::Text', $v_text);
   &orac_Show($d);
}
sub all_stf {
   my $cm = &f_str($_[0],$_[1]);
   my $sth = $dbh->prepare($cm) || die $dbh->errstr; 
   my $i;
   for ($i = 1;$i <= $_[2];$i++){
      $sth->bind_param($i,'%');
   }
   $sth->execute;
   $i = 0;
   my $ls;
   while($i < 20000){
      $ls = scalar $dbh->func('dbms_output_get');
      if ((!defined($ls)) || (length($ls) == 0)){
         last;
      }
      print TEXT "$ls\n";
      $i++;
   }
   &see_plsql($cm);
}
sub orac_create_db {
   my ($oracle_sid,$dum) = split(/\./, $v_db);

   print TEXT 'rem  ************************************************' . "\n";
   print TEXT 'rem  crdb' . "$oracle_sid" . '.sql' . "\n";
   print TEXT 'rem  ************************************************' . "\n";

   &prep_lp('','orac_create_db','3',$rp_big_one_left,-1);

   print TEXT "rem\nrem  Note:  Use ALTER SYSTEM BACKUP CONTROLFILE TO TRACE;\n";
   print TEXT 'rem  to generate a script to create controlfile' . "\n";
   print TEXT 'rem  and compare it with the output of this script.' . "\n";
   print TEXT 'rem  Add MAXLOGFILES, MAXDATAFILES, etc. if reqd.' . "\n";
   print TEXT 'rem  ************************************************' . "\n\n";
   print TEXT 'spool crdb' . "$oracle_sid" . '.lst' . "\n";
   print TEXT 'connect internal' . "\n";
   print TEXT 'startup nomount' . "\n\n";
   print TEXT 'rem -- please verify/change the following parameters as needed' . "\n\n";

   &prep_lp('','orac_create_db','10',$rp_big_one_left,-1);

   @code_A = undef;
   @code_0 = undef;
   @code_1 = undef;
   @code_2 = undef;
   &fill_the_codes();
   my $i = 0;
   while($code_A[$i]){
      print TEXT "$code_A[$i]\n";
      $i++;
   }
   print TEXT "\nREMOVE => NB: Make sure NOARCHIVELOG/ARCHIVELOG sorted out\n\n";
   print TEXT '   /* You may wish to change the following  values,          */' . "\n";
   print TEXT '   /* and use values found from a control file backed up     */' . "\n";
   print TEXT '   /* to trace.  Alternatively, uncomment these defaults.    */' . "\n";
   print TEXT '   /* (MAXLOGFILES & MAXLOGMEMBERS have been selected from   */' . "\n";
   print TEXT '   /* sys.v_$log, character set from NLS_DATABASE_PARAMETERS.*/' . "\n\n";
   print TEXT '   /* option start:use control file*/' . "\n";

   &prep_lp('','orac_create_db','11',$rp_big_one_left,-1);
   
   print TEXT '   /* MAXDATAFILES  255 */' . "\n";
   print TEXT '   /* MAXINSTANCES    1 */' . "\n";
   print TEXT '   /* MAXLOGHISTORY 100 */' . "\n";
   print TEXT '   /* option end  :use control file*/' . "\n\n";

   $i = 0;
   while($code_0[$i]){
      print TEXT "$code_0[$i]\n";
      $i++;
   }
   print TEXT '    LOGFILE' . "\n";
   $i = 0;
   while($code_1[$i]){
      print TEXT "$code_1[$i]\n";
      $i++;
   }
   print TEXT 'rem ----------------------------------------' . "\n\n";
   print TEXT 'rem  Need a basic rollback segment before proceeding' . "\n\n";
   print TEXT 'CREATE ROLLBACK SEGMENT dummy TABLESPACE SYSTEM '  . "\n";
   print TEXT '    storage (initial 500K next 500K minextents 2);' . "\n";
   print TEXT 'ALTER ROLLBACK SEGMENT dummy ONLINE;' . "\n";
   print TEXT 'commit;' . "\n";
   print TEXT 'rem ----------------------------------------' . "\n\n";
   print TEXT 'rem Create DBA views' . "\n\n";
   print TEXT '@?/rdbms/admin/catalog.sql' . "\n";
   print TEXT 'commit;' . "\n";
   print TEXT 'rem ----------------------------------------' . "\n\n";
   print TEXT 'rem  Additional Tablespaces' . "\n";
   $i = 0;
   while($code_2[$i]){
      print TEXT "$code_2[$i]\n";
      $i++;
   }
   &prep_lp('','orac_create_db','14',$rp_big_one_left,-1);

   print TEXT "\n" . 'rem  Take the initial rollback segment (dummy) offline' . "\n\n";
   print TEXT 'ALTER ROLLBACK SEGMENT dummy OFFLINE;' . "\n\n";
   print TEXT 'rem ----------------------------------------' . "\n\n";

   &prep_lp('','orac_create_db','15',$rp_big_one_left,-1);

   print TEXT "\n\n" . 'rem ----------------------------------------' . "\n\n";
   print TEXT 'rem  Run other @?/rdbms/admin required scripts' . "\n\n";
   print TEXT 'commit;' . "\n\n";
   print TEXT '@?/rdbms/admin/catproc.sql' . "\n\n";
   print TEXT "rem You may wish to uncomment the following scripts?\n\n";
   print TEXT 'rem @?/rdbms/admin/catparr.sql' . "\n";
   print TEXT 'rem @?/rdbms/admin/catexp.sql' . "\n";
   print TEXT 'rem @?/rdbms/admin/catrep.sql' . "\n";
   print TEXT 'rem @?/rdbms/admin/dbmspool.sql' . "\n";
   print TEXT 'rem @?/rdbms/admin/utlmontr.sql' . "\n\n";
   print TEXT 'commit;' . "\n\n";
   print TEXT 'connect system/manager' . "\n";
   print TEXT '@?/sqlplus/admin/pupbld.sql' . "\n";
   print TEXT '@?/rdbms/admin/catdbsyn.sql' . "\n";
   print TEXT 'commit;' . "\n";
   print TEXT 'spool off' . "\n";
   print TEXT 'exit' . "\n\nrem EOF";
}
sub fill_the_codes {
   my $cm = &f_str('fill_the_codes','2');
   my $sth = $dbh->prepare( $cm ) || die $dbh->errstr; 
   $sth->execute;

   my $j = 0;
   my $full_list;
   my $first_bit;
   my $second_bit;
   my $code_A_count = 0;
   my $code_0_count = 0;
   my $code_1_count = 0;
   my $code_2_count = 0;
   while($j < 10000){
      $full_list = scalar $dbh->func('dbms_output_get');
      if ((!defined($full_list))|| (length($full_list) == 0)){
         last;
      }
      ($first_bit,$second_bit) = split(/\^/, $full_list);
      if ($first_bit eq 'A'){
         $code_A[$code_A_count] = $second_bit;
         $code_A_count++;
      } elsif ($first_bit eq '0'){
         $code_0[$code_0_count] = $second_bit;
         $code_0_count++;
      } elsif ($first_bit eq '1'){
         $code_1[$code_1_count] = $second_bit;
         $code_1_count++;
      } elsif ($first_bit eq '2'){
         $code_2[$code_2_count] = $second_bit;
         $code_2_count++;
      }
      $j++;
   }
}
sub selected_error {
   my ($err_bit) = @_;
   &f_clr();
   my ($owner,$object) = split(/\./, $err_bit);
   &prep_lp("Compilation Errors for $err_bit",'selected_error','1',$rp_5_errors,0,$owner,$object);
}
sub univ_form { 
   ($loc_d,$own,$obj,$uf_type) = @_;

   $m_t = "Form for $obj";
   my $bd = $loc_d->DialogBox(-title => $m_t, -buttons => [ "Exit" ]);
   my $uf_txt;
   if ($uf_type eq 'index'){
      $uf_txt = "Select $own.$obj Columns & then Build Index";
   } else {
      $uf_txt = "Provide SQL, indicate order, then 'Select Information'";
   }
   $bd->Label(-text => $uf_txt,-anchor => 'n')->pack();
   my $t = $bd->Scrolled('Text',-height => 16,-wrap => 'none',-cursor => undef,-foreground => $fc,-background => $bc);
   my $cm = &f_str('selected_dba','1');
   my $sth = $dbh->prepare( $cm ) || die $dbh->errstr;
   $sth->bind_param(1,$own);
   $sth->bind_param(2,$obj);
   $sth->execute;

   my @h_t = ('Column','Select SQL','Datatype', 'Ord');
   for $i (0..3){
      unless (($uf_type eq 'index') && ($i == 2)){
         if ($i == 3){
            $w = $t->Entry(-textvariable => \$h_t[$i],-cursor => undef, -width => 3);
         } else {
            $w = $t->Entry(-textvariable => \$h_t[$i],-cursor => undef);
         }
         $w->configure(-background => $fc, -foreground => $ec);
         $t->windowCreate('end', -window => $w);
      }
   }
   $t->insert('end', "\n");

   my @res;
   my @c_t;
   my @t_t;
   $ind_bd_cnt = 0;
   while (@res = $sth->fetchrow) {
      $c_t[$ind_bd_cnt] = $res[0];
      $w = $t->Entry(-textvariable => \$c_t[$ind_bd_cnt],-cursor => undef);
      $t->windowCreate('end', -window => $w);

      unless ($uf_type eq 'index'){
         $sql_entry[$ind_bd_cnt] = "";
         $w = $t->Entry(-textvariable => \$sql_entry[$ind_bd_cnt],-cursor => undef,-foreground => $fc,-background => $ec);
         $t->windowCreate('end', -window => $w);
      }
      $t_t[$ind_bd_cnt] = "$res[1] $res[2]";
      $w = $t->Entry(-textvariable => \$t_t[$ind_bd_cnt],-cursor => undef);
      $t->windowCreate('end', -window => $w);

      $i_ac[$ind_bd_cnt] = "$res[0]";

      $i_uc[$ind_bd_cnt] = 0;
      $w = $t->Checkbutton(-variable => \$i_uc[$ind_bd_cnt],-relief => 'flat');
      $t->windowCreate('end', -window => $w);

      $t->insert('end', "\n");
      $ind_bd_cnt++;
   }
   $ind_bd_cnt--;
   $sth->finish;
   $t->configure(-state => 'disabled');
   $t->pack(-expand =>1, -fill => 'both');

   my(@lb) = qw/-side bottom/;
   my $bb = $bd->Frame->pack(@lb);

   if ($uf_type eq 'index'){
      $uf_txt = '  Build Index  ';
   } else {
      $uf_txt = '  Select Information  ';
   }
   $bb->Button(-text => $uf_txt,-command => sub {$bd->Busy;&selector($bd,$uf_type);$bd->Unbusy}
              )->pack(-side => 'right',-anchor => 'e');
   &orac_Show($bd);
}
sub selector {
   my($sel_d,$uf_type) = @_;

   if ($uf_type eq 'index'){
      &build_ord($sel_d,$uf_type);
      return;
   }
   $l_sel_str = ' select ';
   for $i (0..$ind_bd_cnt){
      if ($i != $ind_bd_cnt){
         $l_sel_str = $l_sel_str . "$i_ac[$i], ";
      } else {
         $l_sel_str = $l_sel_str . "$i_ac[$i] ";
      }
   }
   $l_sel_str = $l_sel_str . "\nfrom ${own}.${obj} ";
   my $flag = 0;
   my $last_one = 0;
   for $i (0..$ind_bd_cnt){
      if ($i_uc[$i] == 1){
         $flag = 1;
         $last_one = $i;
      }
   }
   my $where_bit = "\nwhere ";
   for $i (0..$ind_bd_cnt){
      my $sql_bit = $sql_entry[$i];
      if (defined($sql_bit) && length($sql_bit)){
         $l_sel_str = $l_sel_str . $where_bit . "$i_ac[$i] $sql_bit ";
         $where_bit = "\nand ";
      }
   }
   &build_ord($sel_d,$uf_type);
   &and_finally($sel_d,$l_sel_str);
}
sub and_finally {
   my($af_d,$cm) = @_;

   $ary_ref = $dbh->selectall_arrayref($cm);
   $min_row = 0;
   $max_row = @$ary_ref;
   if ($max_row == 0){
      &mes($af_d,'No rows selected');
   } else {
      $gc = $min_row;
      $c_d = $af_d->DialogBox(-title => $m_t);
      my(@lb) = qw/-side top -expand yes -fill both/;
      my $top_frame = $c_d->Frame->pack(@lb);
   
      my $t = $c_d->Scrolled('Text',-height => 16,-wrap => 'none',-cursor => undef,-foreground => $fc,-background => $bc);
      for my $i (0..$ind_bd_cnt) {
         $lrg_t[$i] = "";
         $w = $t->Entry(-textvariable => \$i_ac[$i],-cursor => undef);
         $t->windowCreate('end', -window => $w);
   
         $w = $t->Entry(-textvariable => \$lrg_t[$i],-cursor => undef,-foreground => $fc,-background => $ec,-width => 40);
         $t->windowCreate('end', -window => $w);
         $t->insert('end', "\n");
      }
      $t->configure(-state => 'disabled');
      $t->pack();

      (@lb) = qw/-side bottom -expand yes -fill both/;
      $c_br = $c_d->Frame->pack(@lb);
   
      $gen_sc = $c_br->Scale( -orient => 'horizontal',-label => "Record of " . $max_row,-length => 400,
                              -sliderrelief => 'raised',-from => 1,-to => $max_row,-tickinterval => ($max_row/8),
                              -command => [ \&calc_scale_record ])->pack(side => 'left');
      $c_br->Button(-text => $ssq,-command => sub {&see_sql($c_d,$l_sel_str)}
                   )->pack(side => 'right');
      &go_for_gold();
      &orac_Show($c_d);
   }
   undef $ary_ref;
}
sub calc_scale_record {
   my($sv) = @_;
   $gc = $sv - 1;
   &go_for_gold();
}
sub go_for_gold {
   my $curr_ref = $ary_ref->[$gc];
   for my $i (0..$ind_bd_cnt) {
      $lrg_t[$i] = $curr_ref->[$i];
   }
   $gen_sc->set(($gc + 1));
}
sub build_ord {
   my($bl_d,$uf_type) = @_;
   my $l_chk = 0;
   for $i (0..$ind_bd_cnt){
      if ($i_uc[$i] == 1){
         $l_chk = 1;
      }
   }
   if ($l_chk == 1){
      &now_build_ord($bl_d,$uf_type);
      if ($uf_type eq 'index'){
         &really_build_index($bl_d,$own,$obj);
      } else {
         $l_sel_str = $l_sel_str . "\norder by ";
         for my $cl (1..$tot_i_cnt){
            $l_sel_str = $l_sel_str . "$tot_ind_ar[$ih[$cl]] ";
            if ($dsc_n[$ih[$cl]] == 1){
               $l_sel_str = $l_sel_str . "desc ";
            }
            if ($cl != $tot_i_cnt){
               $l_sel_str = $l_sel_str . ", ";
            }
         }
      }
   } else {
      if ($uf_type eq 'index'){
         &mes($bl_d,'No Columns Selected');
      }
   }
}
sub now_build_ord {
   my($nbo_d,$uf_type) = @_;
   $tot_i_cnt = 0;
   for $i (0..$ind_bd_cnt){
      if ($i_uc[$i] == 1){
         $tot_i_cnt++;
         $tot_ind_ar[$tot_i_cnt] = $i_ac[$i];
      }
   }
   my $b_d = $nbo_d->DialogBox(-title => $m_t); 
   $b_d->Label(-text => "Please Arrange Index Order, then continue",-anchor => 'n')->pack(-side => 'top');
   my $t = $b_d->Scrolled('Text',-height => 16,-wrap => 'none',-cursor => undef,-foreground => $fc,-background => $bc);
   if ($uf_type eq 'index'){
      my $id_name = 'Index Name:';
      $w = $t->Entry(-textvariable => \$id_name,-background => $fc,-foreground => $ec);
      $t->windowCreate('end',-window => $w);

      $ind_name = 'INDEX_NAME';
      $w = $t->Entry(-textvariable, \$ind_name,-cursor => undef,-foreground => $fc,-background => $ec);
      $t->windowCreate('end',-window => $w);
      $t->insert('end', "\n");

      my $tabp_name = 'Tablespace:';
      $w = $t->Entry(-textvariable => \$tabp_name,-background => $fc,-foreground => $ec);
      $t->windowCreate('end',-window => $w);

      $t_n = "TABSPACE_NAME";
      $t_l = $t->BrowseEntry(-cursor => undef,-variable => \$t_n,-foreground => $fc,-background => $ec);
      $t->windowCreate('end',-window => $t_l);
      $t->insert('end', "\n");
   
      my $sth = $dbh->prepare( &f_str('now_build_ord','1') ) || die $dbh->errstr; 
      $sth->execute;

      my $i = 0;
      my @tot_obj;
      while (@res = $sth->fetchrow) {
         $tot_obj[$i] = $res[0];
         $i++;
      }
      $sth->finish;

      my @h_ar = sort @tot_obj;
      foreach(@h_ar){
         $t_l->insert('end', $_);
      }
      $t->insert('end', "\n");
   }
   my @pos_txt;
   for $i (1..($tot_i_cnt + 2)){
      if ($i <= $tot_i_cnt){
         $pos_txt[$i] = "Pos $i";
         $w = $t->Entry(-textvariable => \$pos_txt[$i],-width => 7,-background => $fc,-foreground => $ec);
      } else {
         if ($i == ($tot_i_cnt + 1)){
            $pos_txt[$i] = "Column";
            $w = $t->Entry(-textvariable => \$pos_txt[$i],-background => $fc,-foreground => $ec);
         } else {
            unless ($uf_type eq 'index'){
               $pos_txt[$i] = "Descend?";
               $w = $t->Entry(-textvariable => \$pos_txt[$i],-width => 8,-background => $fc,-foreground => $ec);
            }
         }
      }
      $t->windowCreate('end',-window => $w);
   }
   $t->insert('end', "\n");

   for $j_row (1..$tot_i_cnt){
      $ih[$j_row] = $j_row;
      $dsc_n[$j_row] = 0;
      $o_ih[$j_row] = $ih[$j_row];
      for $j_col (1..($tot_i_cnt + 2)){
         if ($j_col <= $tot_i_cnt){
            $w = $t->Radiobutton(-relief => 'flat',-value => $j_row,-variable => \$ih[$j_col],-width => 4,-command => [\&j_inri]);
            $t->windowCreate('end', -window => $w);
         } else {
            if ($j_col == ($tot_i_cnt + 1)){
               $w = $t->Entry(-textvariable => \$tot_ind_ar[$j_row], -cursor => undef,-foreground => $fc,-background => $ec);
               $t->windowCreate('end', -window => $w);
            } else {
               unless ($uf_type eq 'index'){
                  $w = $t->Checkbutton(-variable => \$dsc_n[$j_row],-relief => 'flat',-width => 6);
                  $t->windowCreate('end', -window => $w);
               }
            }
         }
      }
      $t->insert('end', "\n");
   }
   $t->configure(-state => 'disabled');
   $t->pack();
   $but_ret = $b_d->Show;
   if ($but_ret eq "Continue") {
      1;
   } else {
      0;
   }
}
sub really_build_index {
   my($rbi_d,$own,$obj) = @_;

   my $d = $rbi_d->DialogBox();
   $d->add("Label",-text => "Index Creation for $own.$obj")->pack(side => 'top');
   my $l_text = $d->Scrolled('Text',-wrap => 'none',-cursor => undef,-foreground => $fc,-background => $bc);
   $l_text->pack(-expand => 1, -fil => 'both');
   tie (*L_TXT, 'Tk::Text', $l_text);

   my $cm = &f_str('build_ind','1');
   for my $cl (1..$tot_i_cnt){
      my $bs = " v_this_build($cl) := '$tot_ind_ar[$ih[$cl]]'; ";
      $cm = $cm . $bs;
   }
   my $cm_part2 = &f_str('build_ind','2');
   $cm = $cm . "\n" . $cm_part2;

   $dbh->func(1000000, 'dbms_output_enable');
   my $sth = $dbh->prepare( $cm ) || die $dbh->errstr; 
   $sth->bind_param(1,$own);
   $sth->bind_param(2,$obj);
   $sth->bind_param(3,$tot_i_cnt);
   $sth->execute;

   my $full_list;
   $full_list = scalar $dbh->func('dbms_output_get');
   if (length($full_list) != 0){
      $avg_entry_size = $full_list + 0.00;

      ($pct_free,$initrans) = &ind_prep(&f_str('build_ind','3'),$own,$obj);
      ($n_rows) =             &ind_prep(&f_str('build_ind','4') . ' ' . $own . '.' . $obj . ' ');
      ($avail_data_space) =   &ind_prep(&f_str('build_ind','5'),$Block_Size,$initrans,$pct_free);
      ($space) =              &ind_prep(&f_str('build_ind','6'),$avail_data_space,$avg_entry_size,$avg_entry_size);
      ($blocks_req) =         &ind_prep(&f_str('build_ind','7'),$n_rows,$avg_entry_size,$space);
      ($initial_extent) =     &ind_prep(&f_str('build_ind','8'),$blocks_req,$Block_Size);
      ($next_extent) =        &ind_prep(&f_str('build_ind','9'),$initial_extent);

      print L_TXT "\nrem  Index Script for new index ${ind_name} on ${own}.${obj}\n\n";
      print L_TXT "create index ${own}.${ind_name} on\n";
      print L_TXT "   ${own}.${obj} (\n";
      for my $cl (1..$tot_i_cnt){
         my $bs = "      $tot_ind_ar[$ih[$cl]]\n";
         if ($cl != $tot_i_cnt){
            $bs = $bs . ', ';
         }
         print L_TXT $bs;
      }
      print L_TXT "   ) tablespace ${t_n}\n";
      print L_TXT "   storage (initial ${initial_extent}K next ${next_extent}K pctincrease 0)\n";
      print L_TXT "   pctfree ${pct_free};\n\n";
      print L_TXT "\nrem Average Index Entry Size:  ${avg_entry_size}   ";

      my $b = $l_text->Button(-text => "Calculation SQL",-command => sub{&see_sql($d,$cm)});
      $l_text->window('create','end', -window => $b);

      print L_TXT "\nrem Database Block Size:       ${Block_Size}\n";
      print L_TXT "rem Current Table Row Count:   ${n_rows}\n";
      print L_TXT "rem Available Space Per Block: ${avail_data_space}\n";
      print L_TXT "rem Space For Each Index:      ${space}\n";
      print L_TXT "rem Blocks Required:           ${blocks_req}\n\n";
   }
   &orac_Show($d);
}
sub ind_prep {
   my $cm = shift;
   my @bindees = @_;
   my $sth = $dbh->prepare($cm) || die $dbh->errstr; 
   $num_bindees = @bindees;
   if ($num_bindees > 0){
      my $i;
      for ($i = 1;$i <= $num_bindees;$i++){
         $sth->bind_param($i,$bindees[($i - 1)]);
      }
   }
   $sth->execute;
   my @res = $sth->fetchrow;
   $sth->finish;
   return @res;
}
sub j_inri {
   my $i = 0;
   my $cl = 0;
   for $cl (1..$tot_i_cnt){
      if ($o_ih[$cl] != $ih[$cl]){
         $i = $cl;
         last;
      }
   }
   if ($i > 0){
      for $cl (1..$tot_i_cnt){
         unless ($cl == $i){
            if ($ih[$cl] == $ih[$i]){
                $ih[$cl] = $o_ih[$i];
                $o_ih[$cl] = $ih[$cl];
                last;
            }
         }
      }
      $o_ih[$i] = $ih[$i];
   }
}
sub tab_det_orac {
   my ($title,$func) = @_;
   my $d = $mw->DialogBox(-title => "$title: $v_db (Block Size $Block_Size)");
   my $cf = $d->Frame;
   $cf->pack(-expand => '1',-fill => 'both');
   my $c = $cf->Scrolled('Canvas',-relief => 'sunken',-bd => 2,-width => 500,-height => 280,-background => $bc);
   $keep_tablespace = 'XXXXXXXXXXXXXXXXX';

   my $cm = &f_str($func,'1');
   my $sth = $dbh->prepare( $cm ) || die $dbh->errstr; 
   if($func eq 'tab_det_orac'){
      my $i;
      for ($i = 1;$i <= 6;$i++){
         $sth->bind_param($i,$Block_Size);
      }
   }
   $sth->execute;

   $i = 1;
   $Grand_Total = 0.00;
   $Grand_Used_Mg = 0.00;
   $Grand_Free_Mg = 0.00;

   while (@res = $sth->fetchrow) {
     my ($T_Space,$Fname,$Total,$Used_Mg,$Free_Mg,$Use_Pct,$dum) = @res;
     if ((!defined($Used_Mg)) || (!defined($Use_Pct))){
        $Used_Mg = 0.00;
        $Use_Pct = 0.00;
     }
     $Grand_Total = $Grand_Total + $Total;
     $Grand_Used_Mg = $Grand_Used_Mg + $Used_Mg;
     $Grand_Free_Mg = $Grand_Free_Mg + $Free_Mg;
     if($func ne 'tab_det_orac'){
        $Fname = '';
     } 
     if($func eq 'tune_health'){
        $Use_Pct = $Total;
     }
     &add_item( $func,$c,$i,$T_Space,$Fname,$Total,$Used_Mg,$Free_Mg,$Use_Pct);
     $i++;
   }
   $sth->finish;

   if($func ne 'tune_health'){
      $Grand_Use_Pct = (($Grand_Used_Mg/$Grand_Total)*100.00);
      &add_item($func,$c,0,'','',$Grand_Total,$Grand_Used_Mg,$Grand_Free_Mg,$Grand_Use_Pct);
   }

   my $b = $c->Button( -text => $ssq,-command => sub{&see_sql($d,$cm)});
   my $y_start = &work_out_why($i);
   $c->create('window', '1c',"$y_start" . 'c', -window => $b,qw/-anchor nw -tags item/);
   $c->configure(-scrollregion => [ $c->bbox("all") ]);
   $c->pack(-expand => 'yes',-fill => 'both');
   &orac_Show($d);
}
sub work_out_why {
    return (0.8 + (1.2 * $_[0]));
}
sub add_item
{
   my ($func,$c,$i,$T_Space,$Fname,$Total,$Used_Mg,$Free_Mg,$Use_Pct) = @_;
   unless($i == 0){
      if ($keep_tablespace eq $T_Space){
         $tab_str = sprintf("%${old_length}s ", '');
      } else {
         $old_length = length($T_Space);
         $tab_str = sprintf("%${old_length}s ", $T_Space);
      }
      $keep_tablespace = $T_Space;
   }
   my $thickness = 0.4;
   my $y_start = &work_out_why($i);
   my $y_end = $y_start + 0.4;
   my $chopper;
   if($func ne 'tune_health'){
      $chopper = 20.0;
   } else {
      $chopper = 10.0;
   }
   $dst_f = ($Use_Pct/$chopper) + 0.4;
   $c->create(('rectangle', "$dst_f" . 'c',"$y_start". 'c','0.4c',"$y_end" . 'c'),-fill => $hc);
  
   $y_start = $y_start - 0.4;
   if($i == 0){
      my $bit = '';
      if($func eq 'tabspace_diag'){
         $bit = ' (Summary slightly more accurate than by datafile - ' . $ssq . ') ';
      }
      $this_text = 'Database ' . sprintf("%5.2f", $Use_Pct) . '% full'. $bit;
   } else {
      $this_text = "$tab_str $Fname " . sprintf("%5.2f", $Use_Pct) . '%';
   }
   $c->create(('text','0.4c',"$y_start" . 'c',-anchor => 'nw',-justify => 'left',-text => $this_text));
   $y_start = $y_start + 0.4;
   if($func ne 'tune_health'){
      $c->create(('text','5.2c',"$y_start" . 'c',-anchor => 'nw',-justify => 'left',
             -text => sprintf("%10.2fM Total %10.2fM Used %10.2fM Free",$Total, $Used_Mg, $Free_Mg)));
   }
}
sub dbwr_fileio {
   my $this_title = "DBWR I/O Report $v_db";
   my $d = $mw->DialogBox(-title => $this_title);
   my $cf = $d->Frame;
   $cf->pack(-expand => '1',-fill => 'both');

   my $c = $cf->Scrolled('Canvas',-relief => 'sunken',-bd => 2,-width => 500,-height => 280,-background => $bc);
   my $cm = &f_str('dbwr_fileio','1');

   my $sth = $dbh->prepare( $cm ) || die $dbh->errstr; 
   $sth->execute;
   my $max_value = 0;
   my $i = 0;
   while (@res = $sth->fetchrow) {
      $dbwr_fi[$i] = [ @res ];
      $i++;
      for $i (1 .. 6){
         if ($res[$i] > $max_value){
            $max_value = $res[$i];
         }
      }
   }
   $sth->finish;
   if($i > 0){
      $i--;
      for $i (0 .. $i){
         &dbwr_print_fileio($c, $max_value, $i,$dbwr_fi[$i][0],$dbwr_fi[$i][1],$dbwr_fi[$i][2],
         $dbwr_fi[$i][3],$dbwr_fi[$i][4],$dbwr_fi[$i][5],$dbwr_fi[$i][6]);
      }
   }
   my $b = $c->Button(-text => $ssq,-command => sub {&see_sql($d,$cm)});
   my $y_start = &this_pak_get_y(($i + 1));
   $c->create('window', '1c', "$y_start" . 'c', -window => $b,qw/-anchor nw -tags item/);
   $c->configure(-scrollregion => [ $c->bbox("all") ]);
   $c->pack(-expand => 'yes',-fill => 'both');
   &orac_Show($d);
}
sub this_pak_get_y {
   return (($_[0] * 2.5) + 0.2);
}
sub dbwr_print_fileio {
   my ($c,$max_value,$y_start,$name,$phyrds,$phywrts,$phyblkrd,$phyblkwrt,$readtim,$writetim) = @_;
   @stf = ('', $phyrds,$phywrts,$phyblkrd,$phyblkwrt,$readtim,$writetim);
   my $local_max = $stf[1];
   for $i (2 .. 6){
      if($stf[$i] > $local_max){
         $local_max = $stf[$i];
      }
   }
   @txt_stf = ('', 'phyrds','phywrts','phyblkrd','phyblkwrt','readtim','writetim');

   my $screen_ratio = 0.00;
   $screen_ratio = ($max_value/10.00);
   $txt_name = 0.1;

   $x_start = 2;
   $y_start = &this_pak_get_y($y_start);
   $act_figure_pos = $x_start + ($local_max/$screen_ratio) + 0.5;
   my $i;
   for $i (1 .. 6){
      $x_stop = $x_start + ($stf[$i]/$screen_ratio);
      $y_end = $y_start + 0.2;

      $c->create(('rectangle',"$x_start" . 'c',"$y_start" . 'c',"$x_stop" . 'c',"$y_end" . 'c'),-fill => $hc);
      $txt_y_start = $y_start - 0.15;

      $c->create(('text', "$txt_name" . 'c', "$txt_y_start" . 'c',-anchor => 'nw',-justify => 'left',-text => "$txt_stf[$i]"));
      $c->create(('text', "$act_figure_pos" . 'c', "$txt_y_start" . 'c',-anchor => 'nw',-justify => 'left',-text => "$stf[$i]"));
      $y_start = $y_start + 0.3;
   }
   $txt_y_start = $y_start - 0.10;

   $c->create(('text', "$x_start" . 'c', "$txt_y_start" . 'c',-anchor => 'nw',-justify => 'left', -text => "$name"));
}
sub gen_hlist {
   ($g_typ,$g_hlst,$gen_sep) = @_;

   $g_mw = $mw->DialogBox(-title => "$g_hlst $v_db");
   $hlist = $g_mw->Scrolled('HList',-drawbranch => 1,-separator => $gen_sep,-indent => 50,
                            -command => \&show_or_hide_tab,-foreground => $fc,-background => $bc);
   $hlist->pack(fill => 'both', expand => 'y');
   
   $open_folder_bitmap = $g_mw->Bitmap(-file => Tk->findINC('openfolder.xbm'));
   $closed_folder_bitmap = $g_mw->Bitmap(-file => Tk->findINC('folder.xbm'));
   $file_bitmap = $g_mw->Bitmap(-file => Tk->findINC('file.xbm'));

   my $no_txt;
   my $yes_txt;
   if ($g_hlst eq 'Tables'){
      $no_txt = 'Original Extents';
      $yes_txt = 'Compressed Extents';
   } else {
      $no_txt = 'No Line Numbers';
      $yes_txt = 'Line Numbers';
   }
   $v_yes_no_txt = 'N';
   $g_mw->Radiobutton(-variable => \$v_yes_no_txt,-text => $no_txt,-value => 'N')->pack (side => 'left');
   $g_mw->Radiobutton(-variable => \$v_yes_no_txt,-text => $yes_txt,-value => 'Y')->pack (side => 'left');
   
   undef %all_the_owners;

   my $cm = &f_str($g_hlst,'1');
   my $sth = $dbh->prepare( $cm ) || die $dbh->errstr; 
   $sth->execute;

   while (@res = $sth->fetchrow) {
      my $owner = $res[0];
      $hlist->add($owner,-itemtype => 'imagetext',-image => $closed_folder_bitmap,-text => $owner);
      $all_the_owners{"$owner"} = 'closed';
   }
   $sth->finish;
   &orac_Show($g_mw);
}
sub show_or_hide_tab {
   my $hlist_thing = $_[0];
   if(!$all_the_owners{"$hlist_thing"}){
      &do_a_generic($hlist_thing, 'Normal', 'dum');
      return;
   } else {
      if($all_the_owners{"$hlist_thing"} eq 'closed'){
         $hlist->info('next', $hlist_thing);
         $hlist->entryconfigure($hlist_thing, -image => $open_folder_bitmap);
         $all_the_owners{"$hlist_thing"} = 'open';
         
         &add_generics($hlist_thing);
      } else {
         $hlist->entryconfigure($hlist_thing, -image => $closed_folder_bitmap);
         $hlist->delete('offsprings', $hlist_thing);
         $all_the_owners{"$hlist_thing"} = 'closed';
      }
   }
}
sub add_generics {
   $g_mw->Busy;
   my $owner = $_[0];
   if ($g_typ == 1){
      my $sth = $dbh->prepare( &f_str($g_hlst,'2') ) || die $dbh->errstr; 
      $sth->bind_param(1,$owner);
      $sth->execute;
      while (@res = $sth->fetchrow) {
         my $gen_thing = "$owner" . $gen_sep . "$res[0]";
         $hlist->add($gen_thing,-itemtype => 'imagetext',-image => $file_bitmap,-text => $gen_thing);
      }
      $sth->finish;
   } else {
      my $gen_thing = "$owner" . $gen_sep . 'sql';
      $hlist->add($gen_thing,-itemtype => 'imagetext',-image => $file_bitmap,-text => $gen_thing);
   }
   $g_mw->Unbusy;
}
sub do_a_generic {
   my ($input,$do_what_flag,$second_hlist) = @_;
   $g_mw->Busy;
   my $owner;
   my $generic;
   my $dum;
   if ($gen_sep eq ":"){
      ($owner, $generic, $dum) = split(/:/, $input);
   } else {
      ($owner, $generic, $dum) = split(/\./, $input);
   }
   my $loc_g_hlst;
   if ($g_hlst eq 'RoleGrants'){
      $loc_g_hlst = 'UserGrants';
   } else {
      if($do_what_flag eq 'Normal'){
         $loc_g_hlst = $g_hlst;
      } else {
         $loc_g_hlst = $second_hlist;
      }
   }
   my $cm = &f_str($loc_g_hlst,'3');

   $dbh->func(1000000, 'dbms_output_enable');
   my $second_sth = $dbh->prepare( $cm ) || die $dbh->errstr; 
   if($g_typ == 1){
      $second_sth->bind_param(1,$owner);
      $second_sth->bind_param(2,$generic);
      if (($loc_g_hlst eq 'Tables')||($loc_g_hlst eq 'Indexes')){
         $second_sth->bind_param(3,$v_yes_no_txt);
      } 
      elsif ($loc_g_hlst eq 'Comments'){
         $second_sth->bind_param(3,$owner);
         $second_sth->bind_param(4,$generic);
      }
   } else {
      unless ($loc_g_hlst eq 'UserGrants'){
         $second_sth->bind_param(1,$owner);
      } else {
         my $i;
         for ($i = 1;$i <= 4;$i++){
            $second_sth->bind_param($i,$owner);
         }
      }
   }
   $second_sth->execute;

   my $d = $g_mw->DialogBox();

   my $strip_plural = $loc_g_hlst;
   $strip_plural =~ s/Indexes/Index/g;
   $strip_plural =~ s/s$//g;
   $d->add("Label",-text => "$strip_plural SQL for $owner.$generic")->pack(side => 'top');
   $l_txt = $d->Scrolled('Text',-height => 16,-wrap => 'none',-cursor => undef,-foreground => $fc,-background => $bc);
   $l_txt->pack(-expand => 1, -fil => 'both');
   tie (*L_TEXT, 'Tk::Text', $l_txt);

   my $j = 0;
   my $full_list;
   my $i = 1;

   while($j < 10000){
      $full_list = scalar $dbh->func('dbms_output_get');
      if(!defined($full_list)){
         last;
      }
      if((length($full_list)) == 0){
         last;
      }
      if (($v_yes_no_txt eq 'N') || ($g_hlst eq 'Tables')){
         print L_TEXT "$full_list\n";
      } else {
         printf L_TEXT "%5d: %s\n", $i, $full_list;
         $i++;
      }
      $j++;
   }
   print L_TEXT "\n\n  ";

   my @b;
   $b[0] = $l_txt->Button(-text => $ssq,-command => sub {&see_sql($d,$cm)});
   $l_txt->window('create', 'end', -window => $b[0]);

   if ($loc_g_hlst eq 'Tables'){
      print L_TEXT "\n\n  ";
      my(@tab_options) = qw/Indexes Constraints Triggers Comments/;
      my $i = 1;
      foreach (@tab_options) {
         my $this_txt = $_;
         $b[$i] = $l_txt->Button(-text => "$this_txt",-command => sub {&do_a_generic($input,'Recursive',"$this_txt")});
         $l_txt->window('create', 'end', -window => $b[$i]);
         print L_TEXT " ";
         $i++;
      }
      print L_TEXT "\n\n  ";
      $b[$i] = $l_txt->Button(-text => "Form",-command => sub {$d->Busy;&univ_form($d,$owner,$generic,'form');$d->Unbusy });
      $l_txt->window('create', 'end', -window => $b[$i]);
      $i++;
      print L_TEXT " ";
      $b[$i] = $l_txt->Button(-text => "Build Index",-command => sub {$d->Busy;&univ_form($d,$owner,$generic,'index');$d->Unbusy });
      $l_txt->window('create','end',-window => $b[$i]);
   }
   print L_TEXT "\n\n";
   &orac_Show($d);
   $g_mw->Unbusy;
}
sub mes {
   my $d = $_[0]->DialogBox();
   $d->Label(text => $_[1])->pack();
   &orac_Show($d);
}
sub sub_win {
   my($flag,$lw,$mod,$pack,$tit,$width) = @_;
   my $sw;
   my $hand;
   my $cm = &f_str($mod,$pack);
   my $sth = $dbh->prepare( $cm ) || die $dbh->errstr; 
   $sth->execute;
   my $detected = 0;
   while (@res = $sth->fetchrow) {
      $detected++;
      if($detected == 1){
         $sw = MainWindow->new();
         $sw->title($tit);
         $sw->Label( text   => 'Double-Click Selection ', anchor => 'n', relief => 'groove')->pack(-expand => 'no');
         $hand = $sw->ScrlListbox(-width => $width,-background => $bc,-foreground => $fc)->pack(-expand => 'yes', -fill => 'both');
         my(@lay_exf) = qw/-side bottom -anchor se -padx 5 -expand no/;
         my $exf = $sw->Frame->pack(@lay_exf);
         $exf->Button(-text => 'Exit',-command => sub {$sw->withdraw();$sw_flag[$flag]->configure(-state => 'active') } 
             )->pack(-side => 'bottom', -anchor => 'se');
      }
      $hand->insert('end', @res);
   }
   $sth->finish;
   if($detected == 0){
      $lw->Busy;
      &mes($lw,'no rows found');
      $lw->Unbusy;
   } else {
      $sw_flag[$flag]->configure(-state => 'disabled');
      $hand->pack();
      if ($flag == 0){
         $hand->bind('<Double-1>',
            sub {
                 &univ_form($sw,'SYS',$hand->get('active'),'form');
                });
      } elsif ($flag == 1){
         $hand->bind('<Double-1>', sub {$sw->Busy;&selected_error($hand->get('active'));$sw->Unbusy});
      } elsif ($flag == 2){
         $hand->bind('<Double-1>', sub {$sw->Busy;
             &prep_lp('Paddr Results','sel_addr','','',0,$hand->get('active'));$sw->Unbusy});
      } elsif ($flag == 3){
         $hand->bind('<Double-1>', sub {$sw->Busy;
             &prep_lp('Sid Stats','sel_sid','1',$rp_4_mid_big,0,$hand->get('active'));$sw->Unbusy});
      }
   }
}
sub orac_Show {
   # Written to replace DialogBox $x->Show command, to stop bottom frame from filling up screen
   # on user dialog screen expansions.
   my($d) = @_;
   my $old_focus = $d->focusSave;
   my $old_grab = $d->grabSave;
   $d->Subwidget("top")->pack(fill => 'both',expand => 'y');
   $d->Subwidget("bottom")->pack(expand => 'n');
   $d->Popup();
   $d->grab;
   $d->waitVisibility;
   $d->focus;
   $d->waitVariable(\$d->{"selected_button"});
   $d->grabRelease;
   $d->withdraw;
   &$old_focus;
   &$old_grab;
}
BEGIN {
   $SIG{__WARN__} = sub {
      if (defined $mw) {
         &mes($mw,$_[0]);
      } else {
         print STDOUT join("\n",@_),"n";
      }
   };
}
