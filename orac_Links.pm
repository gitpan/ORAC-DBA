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
use Tk::Balloon;
sub links_orac {
   $local_top = $_[0];
   $dbh = $_[1];
   $v_db = $_[2];

   my $sth = $dbh->prepare(
       orac_Utils::file_string('sql_files','orac_Links','links_orac','1','sql')
                          ) || die $dbh->errstr;
   $rv = $sth->execute;

   $here_we_are = 0;
   while ($v_this_text = $sth->fetchrow) {
      if($here_we_are == 0){
         $top = $local_top->DialogBox( -title => "Orac Links",
                                       -buttons => [ "Dismiss" ]);
      
         $label = $top->Label( text   => "Double-Click Link",
                               anchor => 'nw',
                               relief => 'groove',
                               height => 1);
         $label->pack(side => 'top');
      
         $link_list = 
            $top->ScrlListbox(-height => 20, 
                              -width  => 40,
                              -background => $main::this_is_the_colour,
                              -foreground => $main::this_is_the_forecolour,
            );
   
         $here_we_are = 1;
      }
      $link_list->insert('end', $v_this_text);
   }
   $rc = $sth->finish;
   unless ($here_we_are == 1){
      my $dialog = $local_top->DialogBox( -title => "Orac Warning",
                                          -buttons => [ "Dismiss" ]);
      $dialog->add("Label", -text => "No database links found")->pack();
      $dialog->Show;
      return;
   }
   $link_list->pack(side => 'left');
   $link_list->bind('<Double-1>', sub { $top->Busy;&sel_link;$top->Unbusy } );
   my $balloon = $top->Balloon();
   $balloon->attach($link_list, 
                    -msg => "Double-Click on required\nlink " .
                            "bring up the links screen");
   $top->Show();
}
sub sel_link {
   $link = $link_list->get('active');
   @v_small_db_link = split(/\./, $link);
   $this_title = "Orac DBLink $link";
   $this_top = $top->DialogBox( -title => $this_title,
                                -buttons => [ "Dismiss" ]);

   my(@layout_menu_bar) = qw/-side top -padx 5 -expand yes -fill both/;
   $menu_bar = $this_top->Frame()->pack(@layout_menu_bar);
   $menu_bar->Label(
       -text        => 'Link Information',
       -font        => '-adobe-helvetica-bold-r-narrow--18-120-75-75-p-46-*-1',
       -borderwidth => 2,
       -relief      => 'flat',
       )->pack(-side => 'right', -anchor => 'e');
   $link_mb = $menu_bar->Menubutton(text        => 'Link',
                                    relief      => 'raised',
                                    borderwidth => 2,
                                     )->pack('-side' => 'left',
                                             '-padx' => 2,
                                            );
   $link_mb->command(-label         => 'Database Link Info',
                     -underline     => 14,
                     -command       => sub { $this_top->Busy;
                                             &link_orac;
                                             $this_top->Unbusy } );
   $link_mb->command(-label         => 'Database Link Synonyms',
                     -underline     => 15,
                     -command       => sub { $this_top->Busy;
                                             &syn_orac;
                                             $this_top->Unbusy } );
   $link_mb->separator();
   $link_mb->command(-label         => 'Source Using Database Link',
                     -underline     => 0,
                     -command       => sub { $this_top->Busy;
                                             &source_orac;
                                             $this_top->Unbusy } );
   
   $label = $this_top->Label( text   => "SPECIFIC DB_LINK $link Output:",
                         anchor => 'n',
                         relief => 'groove',
                         width  => 120,
                         height => 1);
   $label->pack();
   $v_text = 
      $this_top->Scrolled('Text', 
                          background => $main::this_is_the_colour,
                          foreground => $main::this_is_the_forecolour);
   $v_text->pack(-expand => 1,
              -fil    => 'both');
   tie (*TEXT, 'Tk::Text', $v_text);
   
   my $balloon = $this_top->Balloon();
   my $link_mb_balls = $link_mb->cget(-menu);
   $balloon->attach($link_mb_balls,
	            -balloonposition => 'mouse',
	            -msg => ['',
         "This report displays the contents of 'dba_db_links' and the\n" .
         'related information within the \'sys.link$\' table.' . "\n" .
         "\n" .
         'The \'sys.link$\' table is searched with just the first part' . "\n" .
         "of the link, '$v_small_db_link[0]', in order to seek out\n" .
         "possibly related information.",
         "This report displays the contents of 'dba_synonyms' and its\n" .
         "related information.\n" .
         "\n" .
         "The table is searched with just the first part of the named link,\n" .
         "'$v_small_db_link[0]', in order to seek out " .
         "possibly related information.",
         '',
         "This report displays all the distinct Owners, " .
         "Names and Types of all the\n" .
         "entries in 'dba_source' which contain " .
         "the " . '\'@' . "$v_small_db_link[0]' string.",
	           ]);
   $this_top->Show();
}
   
sub link_orac {
   printf TEXT "\n$link\n\ndba_db_links\n------------\n" .
               "%-16s %32s %16s %30s %12s\n", 
               'OWNER', 'DB_LINK', 'USERNAME', 'HOST', 'CREATED';
   printf TEXT "%-16s %32s %16s %30s %12s\n", 
               '-----', '-------', '--------', '----', '-------';
   
   my $v_command = orac_Utils::file_string('sql_files', 'orac_Links',
                                           'link_orac', '1','sql');
   $v_command =~ s/orac_insert_link/$link/g;

   my $sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sth->execute;

   @v_this_text = $sth->fetchrow;
   printf TEXT "%-16s %32s %16s %30s %12s\n", 
      $v_this_text[0],
      $v_this_text[1],
      $v_this_text[2],
      $v_this_text[3],
      $v_this_text[4];
   $rc = $sth->finish;

   my $small_db_link = $v_small_db_link[0];
   $v_command = orac_Utils::file_string('sql_files', 'orac_Links',
                                           'link_orac', '2','sql');
   $v_command =~ s/orac_insert_small_db_link/$small_db_link/g;

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
sub syn_orac {
   printf TEXT "\ndba_synonyms\n------------\n%-16s %30s %20s %20s %20s\n", 
      'OWNER', 'DB_LINK', 'TABLE_NAME', 'SYNONYM_NAME', 'TABLE_OWNER';
   printf TEXT "%-16s %30s %20s %20s %20s\n", 
      '-----', '-------', '----------', '------------', '-----------';

   my $small_db_link = $v_small_db_link[0];
   my $v_third_command = orac_Utils::file_string('sql_files', 'orac_Links',
                                                 'syn_orac', '1','sql');
   $v_third_command =~ s/orac_insert_small_db_link/$small_db_link/g;

   my $third_sth = $dbh->prepare( $v_third_command ) || die $dbh->errstr; 
   $rv = $third_sth->execute;

   $v_counter = 0;
   while(@v_this_text = $third_sth->fetchrow){
      printf TEXT "%-16s %30s %20s %20s %20s\n", 
         $v_this_text[0],
         $v_this_text[1],
         $v_this_text[2],
         $v_this_text[3],
         $v_this_text[4];
      $v_counter++;
   }
   if ($v_counter == 0){
      print TEXT "no rows selected\n";
   }
   $third_rc = $third_sth->finish;
}
sub source_orac {
   my $dialog_text =
      "This Report could take SOME TIME to run.  " .
      "Are you sure you wish to run it?";
   my $dialog = $this_top->DialogBox( -title => "Orac Dialog",
                                 -buttons => [ "Yes", "No" ]);
   $dialog->add("Label", -text => $dialog_text)->pack();
   my $button = $dialog->Show;
   if($button eq 'Yes'){
      printf TEXT "\n" . '@' . "$v_small_db_link[0] appears in dba_source\n\n" .
                  "%-30s %30s %12s\n" .
                  "%-30s %30s %12s\n", 
         'OWNER', 'NAME', 'TYPE',
         '-----', '----', '----';

      my $small_db_link = $v_small_db_link[0];
      my $v_fourth_command = orac_Utils::file_string('sql_files', 'orac_Links',
                                                    'source_orac', '1','sql');
      $v_fourth_command =~ s/orac_insert_small_db_link/$small_db_link/g;

      my $fourth_sth = $dbh->prepare( $v_fourth_command ) || die $dbh->errstr; 
      $rv = $fourth_sth->execute;

      $v_counter = 0;
      while(@v_this_text = $fourth_sth->fetchrow){
         printf TEXT "%-30s %30s %12s\n",
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
