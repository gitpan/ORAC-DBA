package orac_RoleUser;

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
sub single_role_user {
   $local_top = $_[0];
   $dbh       = $_[1];
   $v_type    = $_[2];
   $this_title = "Orac $v_type Grants";
   $top = $local_top->DialogBox( -title => $this_title,
                                 -buttons => [ "Dismiss" ]);
   $label = 
      $top->Label( 
          text   => "Double-Click on a $v_type - Reports may take some time",
          anchor => 'n',
          relief => 'groove',
          width  => 120,
          height => 1);
   $label->pack(side => 'top');

   $grant_list = 
      $top->ScrlListbox("width" => 24, "height" => 21, 
                        "background" => $main::this_is_the_colour,
                        "foreground" => $main::this_is_the_forecolour,
      )->pack(side => 'left');

   if ($v_type eq 'Role') {
      $v_command = orac_Utils::file_string('sql_files', 'orac_RoleUser',
                                           'single_role_user', '1','sql');
   }
   else {
      $v_command = orac_Utils::file_string('sql_files', 'orac_RoleUser',
                                           'single_role_user', '2','sql');
   }
   my $sth = $dbh->prepare( $v_command )|| die $dbh->errstr;
   $rv = $sth->execute;
   while ($v_this_text = $sth->fetchrow) {
      $grant_list->insert('end', $v_this_text);
   }
   $rc = $sth->finish;
   $grant_list->bind('<Double-1>', 
                     sub { $top->Busy;&get_grants;$top->Unbusy } );
   $v_text = 
     $top->Scrolled('Text', background => $main::this_is_the_colour,
                            foreground => $main::this_is_the_forecolour);
   $v_text->pack(-expand => 1, -fil => 'both');

   tie (*TEXT, 'Tk::Text', $v_text);

   $top->Show();
}
sub get_grants {
   my $user_role = $grant_list->get('active');
   printf TEXT "\nDirect Grants made to " .
               "$user_role:\n\n%-8s %28s %4s %9s %26s %10s\n",
      'LEVEL', 'PRIVILEGE', 'GTBL', 'OWNER', 'TABLE_NAME', 'COL_NAME';
   printf TEXT "%-8s %28s %4s %9s %26s %10s\n\n",
      '-----', '---------', '----', '-----', '----------', '--------';

   my $v_command = orac_Utils::file_string('sql_files', 'orac_RoleUser',
                                           'get_grants', '1','sql');
   $v_command =~ s/orac_insert_user_role/$user_role/g;

   my $fir_sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $fir_sth->execute;

   while (@v_this_text = $fir_sth->fetchrow) {
      printf TEXT "%-8s %28s %4s %9s %26s %10s\n",
         $v_this_text[0],
         $v_this_text[1],
         $v_this_text[2],
         $v_this_text[3],
         $v_this_text[4],
         $v_this_text[5];
   }
   $rc = $fir_sth->finish;
   printf TEXT "\nRoles granted to $user_role:\n\n%-25s\n", 'GRANTED_ROLE';
   printf TEXT "%-25s\n\n", '------------';

   $v_command = orac_Utils::file_string('sql_files', 'orac_RoleUser',
                                        'get_grants', '2','sql');
   $v_command =~ s/orac_insert_user_role/$user_role/g;

   my $sec_sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $sec_sth->execute;

   while (@v_this_text = $sec_sth->fetchrow) {
      printf TEXT "%-25s\n",
         $v_this_text[0];
   }
   $rc = $sec_sth->finish;

   printf TEXT "\nRoles granted to PUBLIC:\n\n%-25s\n", 'GRANTED_ROLE';
   printf TEXT "%-25s\n\n", '------------';

   $v_command = orac_Utils::file_string('sql_files', 'orac_RoleUser',
                                        'single_role_user', '3','sql');
   $v_command =~ s/orac_insert_user_role/$user_role/g;

   my $thi_sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $thi_sth->execute;

   while (@v_this_text = $thi_sth->fetchrow) {
      printf TEXT "%-25s\n",
         $v_this_text[0];
   }
   $rc = $thi_sth->finish;

   printf TEXT "\nRoles granted to roles which " .
               "are granted to $user_role:\n\n%-25s\n", 'GRANTED_ROLE';
   printf TEXT "%-25s\n\n", '------------';

   $v_command = orac_Utils::file_string('sql_files', 'orac_RoleUser',
                                        'single_role_user', '4','sql');
   $v_command =~ s/orac_insert_user_role/$user_role/g;

   my $fou_sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $fou_sth->execute;

   while (@v_this_text = $fou_sth->fetchrow) {
      printf TEXT "%-25s\n",
         $v_this_text[0];
   }
   $rc = $fou_sth->finish;

   printf TEXT "\nPRIVLIST - List Privileges " .
               "for $user_role:\n\n%-13s %30s %12s %15s %5s\n",
               'OWNER', 'TABLE_NAME', 'PRIVILEGE', 'GRANTED_ROLE', 'ADMIN';
   printf TEXT "%-13s %30s %12s %15s %5s\n\n",
               '-----', '----------', '---------', '------------', '-----';

   $v_command = orac_Utils::file_string('sql_files', 'orac_RoleUser',
                                        'single_role_user', '5','sql');
   $v_command =~ s/orac_insert_user_role/$user_role/g;

   my $fif_sth = $dbh->prepare( $v_command ) || die $dbh->errstr; 
   $rv = $fif_sth->execute;

   while (@v_this_text = $fif_sth->fetchrow) {
      printf TEXT "%-13s %30s %12s %15s %5s\n",
         $v_this_text[0],
         $v_this_text[1],
         $v_this_text[2],
         $v_this_text[3],
         $v_this_text[4];
   }
   $rc = $fif_sth->finish;
}
1;
