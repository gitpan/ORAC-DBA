package orac_UnixHelp;

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
sub cron_help {
   my($prefix,$dummy) = @_;
   package main;
   open(DBFILE, "txt_files/${prefix}_help.txt");
   while(<DBFILE>){
      print TEXT $_;
   }
   close(DBFILE);
}
sub help_orac {
   my($top,$first_prt,$second_prt, $third_prt,$dummy) = @_;

   my $help_dialog = 
        $top->DialogBox( -title => "Orac Help", -buttons => [ "Dismiss" ]);
   my $help_file = "help_files/${first_prt}.${second_prt}.${third_prt}.help";
   open(DBFILE, "$help_file");
   my $help_text = "";
   while(<DBFILE>){
      $help_text = $help_text . $_;
   }
   close(DBFILE);
   my $loc_text = 
        $help_dialog->Scrolled('Text', 
                               background => $main::this_is_the_colour,
                               foreground => $main::this_is_the_forecolour);
   $loc_text->pack(-expand => 1,
                   -fil    => 'both');
   tie (*THIS_HEPL2_TEXT, 'Tk::Text', $loc_text);
   print THIS_HEPL2_TEXT "$help_text\n";
   $help_dialog->Show;
}
1;
