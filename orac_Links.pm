package orac_Links;

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
sub links_orac {
   package main;

   my $sth = $dbh->prepare(
       orac_Utils::file_string('sql_files','orac_Links','links_orac','1','sql')
                          ) || die $dbh->errstr;
   $rv = $sth->execute;

   my $here_we_are = 0;
   my $v_this_text;
   while ($v_this_text = $sth->fetchrow) {
      if($here_we_are == 0){
         $orac_Links::dialog = $top->DialogBox( -title => "Orac Links",
                                    -buttons => [ "Dismiss" ]);
      
         $label = $orac_Links::dialog->Label( text   => "Double-Click Link",
                                  anchor => 'nw',
                                  relief => 'groove',
                                  height => 1);
         $label->pack(side => 'top');
      
         $orac_Links::link_list = 
            $orac_Links::dialog->ScrlListbox(-height => 20, 
                                 -width  => 40,
                                 -background => $main::this_is_the_colour,
                                 -foreground => $main::this_is_the_forecolour,
            );
   
         $here_we_are = 1;
      }
      $orac_Links::link_list->insert('end', $v_this_text);
   }
   $rc = $sth->finish;
   unless ($here_we_are == 1){
      my $warn_dialog = $orac_Links::dialog->DialogBox( 
                                          -title => "Orac Warning",
                                          -buttons => [ "Dismiss" ]);
      $warn_dialog->add("Label", -text => "No database links found")->pack();
      $warn_dialog->Show;
      return;
   }
   $orac_Links::link_list->bind('<Double-1>', 
                sub { $orac_Links::dialog->Busy;
                      &clear_orac;
                      package orac_Links;

                      # I've had to do this named package stuff,
                      # 'coz this may be a bug?

                      &sel_link;
                      package main;
                      $orac_Links::dialog->Unbusy } );

   $orac_Links::link_list->pack(side => 'left');
   $orac_Links::dialog->Show();
}
sub sel_link {
   package main;

   $link = $orac_Links::link_list->get('active');
   my @db_link = split(/\./, $link);

   $top->Busy;
   orac_Links::link_orac($link, $db_link[0]);
   orac_Links::syn_orac($link, $db_link[0]);
   orac_Links::source_orac($link, $db_link[0]);
   $top->Unbusy;
}
   
sub link_orac {
   package main;

   my ($link,$db_link) = @_;

   my @titles = ('OWNER', 'DB_LINK', 'USERNAME', 'HOST', 'CREATED');
   orac_Links::print_link_stuff ( @titles );

   my @titles = ('-----', '-------', '--------', '----', '-------');
   orac_Links::print_link_stuff ( @titles );

   my $v_command = orac_Utils::file_string('sql_files', 'orac_Links',
                                           'link_orac', '1','sql');
   $v_command =~ s/orac_insert_link/$link/g;

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   @v_this_text = $sth->fetchrow;
   orac_Links::print_link_stuff ( @v_this_text );
   $rc = $sth->finish;

   $v_command = orac_Utils::file_string('sql_files', 'orac_Links',
                                           'link_orac', '2','sql');
   $v_command =~ s/orac_insert_small_db_link/$db_link/g;

   my $sec_sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   print TEXT "\n" . 'sys.link$' . "\n---------";
   $v_counter = 1;
   $rv = $sec_sth->execute;
   while(@v_this_text = $sec_sth->fetchrow){
      printf TEXT "\nRecord %3d   Values\n----------   ------\n",   $v_counter;
      printf TEXT "%10s : %-80s\n", 'OWNER#',   $v_this_text[0];
      printf TEXT "%10s : %-10s\n", 'NAME',     $v_this_text[1];
      printf TEXT "%10s : %-10s\n", 'CTIME',    $v_this_text[2];
      printf TEXT "%10s : %-10s\n", 'HOST',     $v_this_text[3];
      printf TEXT "%10s : %-10s\n", 'USERID',   $v_this_text[4];
      printf TEXT "%10s : %s ----- Please protect " .
                  "this output carefully!!!-----\n",
                  'PASSWORD', $v_this_text[5];
      printf TEXT "%10s : %-10s\n", 'FLAG',     $v_this_text[6];
      printf TEXT "%10s : %-10s\n", 'AUTHUSR',  $v_this_text[7];
      printf TEXT "%10s : %-10s\n", 'AUTHPWD',  $v_this_text[8];
      $v_counter++;
   }
   $rc = $sec_sth->finish;
}

sub print_link_stuff {
   package main;

   my($owner,$db_link,$username,$host,$created) = @_;

#234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
$^A = "";
$str = formline <<'END',$owner,$db_link,$username,$host,$created;
^<<<<<<<<<<<<<< ^<<<<<<<<<<<<<<<<<<<<<<< ^<<<<<<<<<<<<<<< ^<<<<<<<<<<<<<<<<<<<<<<< ^>>>>>>>>>> ~~
END
print TEXT "$^A";
}
sub print_syn_stuff {
   package main;

   my($owner,$db_link,$tab_name,$syn_name,$tab_owner) = @_;

#234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
$^A = "";
$str = formline <<'END',$owner,$db_link,$username,$host,$created;
^<<<<<<<<<<<<<< ^<<<<<<<<<<<<<<<<<< ^<<<<<<<<<<<<<<<<<<<< ^<<<<<<<<<<<<<<<<<< ^>>>>>>>>>>>>>>> ~~
END
print TEXT "$^A";
}
sub syn_orac {
   package main;

   my($link,$db_link) = @_;

   printf TEXT "\n\nDBA_SYNONYMS\n\n";

   my @titles = ('OWNER','DB_LINK','TABLE_NAME','SYNONYM_NAME','TABLE_OWNER');
   orac_Links::print_syn_stuff ( @titles );

   my @titles = ('-----','-------','----------','------------','-----------');
   orac_Links::print_syn_stuff ( @titles );

   my $small_db_link = $v_small_db_link[0];
   my $v_third_command = orac_Utils::file_string('sql_files', 'orac_Links',
                                                 'syn_orac', '1','sql');
   $v_third_command =~ s/orac_insert_small_db_link/$db_link/g;

   my $third_sth = $dbh->prepare( $v_third_command ) || die $dbh->errstr; 
   $rv = $third_sth->execute;

   my $v_counter = 0;
   while(@v_this_text = $third_sth->fetchrow){
      orac_Links::print_syn_stuff ( @v_this_text );
      $v_counter++;
   }
   if ($v_counter == 0){
      print TEXT "no rows selected\n";
   }
   $third_rc = $third_sth->finish;
}
sub source_orac {
   package main;

   my($link,$db_link) = @_;

   my $dialog_text =
      "DBA_SOURCE Report for " . '@' . "$db_link \n" .
      "could take SOME TIME to run examining PL/SQL code. \n" .
      "Do you wish to run it?";

   my $dialog = $orac_Links::dialog->DialogBox( -title => "Orac Dialog",
                                                -buttons => [ "Yes", "No" ]);

   $dialog->add("Label", -text => $dialog_text)->pack();
   my $button = $dialog->Show;
   if($button eq 'Yes'){
      printf TEXT "\n" . '@' . "$db_link appears in dba_source\n\n" .
                  "%-24s %24s %12s\n" .
                  "%-24s %24s %12s\n", 
         'OWNER', 'NAME', 'TYPE',
         '-----', '----', '----';

      my $v_fourth_command = orac_Utils::file_string('sql_files', 'orac_Links',
                                                    'source_orac', '1','sql');
      $v_fourth_command =~ s/orac_insert_small_db_link/$db_link/g;

      my $fourth_sth = $dbh->prepare( $v_fourth_command ) || die $dbh->errstr; 
      $rv = $fourth_sth->execute;

      $v_counter = 0;
      while(@v_this_text = $fourth_sth->fetchrow){
         printf TEXT "%-24s %24s %12s\n",
            $v_this_text[0],
            $v_this_text[1],
            $v_this_text[2];
         $v_counter++;
      }
      if ($v_counter == 0){
         print TEXT "no rows selected\n";
      }
      $fourth_rc = $fourth_sth->finish;
   }
}
1;
