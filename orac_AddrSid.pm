package orac_AddrSid;

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
use DBI;
use Cwd;
use Tk::DialogBox;
sub addr_orac {
   $local_top = $_[0];
   $dbh = $_[1];
   $this_title = "Orac Specific Addresses and Sids";
   $top = $local_top->DialogBox( 
              -title => $this_title, 
              -buttons => [ "Dismiss" ]);

   $label = $top->Label( text => "Double-Click for Report", 
                         relief => 'groove', 
                         height => 1);
   $label->pack(side => 'top', anchor => 'w');
   $addr_list = 
   $top->ScrlListbox("width" => 10, "height" => 21, 
                     "background" => $main::this_is_the_colour, 
                     "foreground" => $main::this_is_the_forecolour, 
                     -label => 'Address',
   )->pack(side => 'left');

   my $v_command = orac_Utils::file_string('sql_files', 'orac_AddrSid',
                                           'addr_orac','1','sql');

   my $sth = $dbh->prepare( $v_command )
      || die $dbh->errstr;
   $rv = $sth->execute;

   while ($v_this_text = $sth->fetchrow) {
      $addr_list->insert('end', $v_this_text);
   }
   $rc = $sth->finish;

   $addr_list->bind('<Double-1>', sub { $top->Busy;&sel_addr;$top->Unbusy } );
   $sid_list = $top->ScrlListbox("width" => 10, "height" => 21, 
                                 "background" => $main::this_is_the_colour, 
                                 "foreground" => $main::this_is_the_forecolour, 
                                 -label => 'Sid',
      )->pack(side => 'left');

   $v_command = orac_Utils::file_string('sql_files', 'orac_AddrSid',
                                        'addr_orac','2','sql');

   my $sth = $dbh->prepare($v_command)|| die $dbh->errstr;
   $rv = $sth->execute;

   while ($v_this_text = $sth->fetchrow) {
      $sid_list->insert('end', $v_this_text);
   }
   $rc = $sth->finish;

   $sid_list->bind('<Double-1>', sub { $top->Busy;&sel_sid;$top->Unbusy } );
   $v_text = $top->Scrolled('Text', 
                            background => $main::this_is_the_colour,
                            foreground => $main::this_is_the_forecolour,
                           );
   $v_text->pack(-expand => 1, -fil    => 'both');
   tie (*TEXT, 'Tk::Text', $v_text);
   $top->Show();
}
sub sel_addr {
   my $addr = $addr_list->get('active');

   my $v_command = orac_Utils::file_string('sql_files', 'orac_AddrSid',
                                           'sel_addr','1','sql');

   my $first_sth = $dbh->prepare( $v_command );
   $rv = $first_sth->execute;

   $v_counter = 0;
   while ($v_this_text = $first_sth->fetchrow) {
      $v_final_text[$v_counter] = "${v_this_text}:";
      $v_counter++;
   }
   $rc = $first_sth->finish;

   $v_command = orac_Utils::file_string('sql_files', 'orac_AddrSid',
                                        'sel_addr','2','sql');
   $v_command =~ s/orac_insert_addr/$addr/g;

   my $nxt_sth = 
      $dbh->prepare( $v_command ) || die $dbh->errstr;
   $rv = $nxt_sth->execute;

   @v_this_text = $nxt_sth->fetchrow;
   $rc = $nxt_sth->finish;
   $v_counter = 0;
   printf TEXT "\n%21s %-49s\n\n", "RESULTS:", "(PADDR = '$addr')";
   foreach $element (@v_this_text){
      printf TEXT "%21s %-49s\n", $v_final_text[$v_counter], $element;
      $v_counter++;
   }
}

sub sel_sid {
   my $sid = $sid_list->get('active');
   printf 
    TEXT "\nStatistics for $v_machine $v_db SID $sid:\n\n%10s %57s %9s\n\n",
      'USERNAME', 'NAME', 'VALUE';

   my $v_command = orac_Utils::file_string('sql_files', 'orac_AddrSid',
                                           'sel_sid','1','sql');
   $v_command =~ s/orac_insert_sid/$sid/g;

   my $first_sth = $dbh->prepare( $v_command ) || die $dbh->errstr;
   $rv = $first_sth->execute;

   while (@v_this_text = $first_sth->fetchrow) {
      printf TEXT "%10s %57s %9d\n",
         $v_this_text[0],
         $v_this_text[1],
         $v_this_text[2];
   }
   $rc = $first_sth->finish;
}
1;
