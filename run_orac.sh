#!/bin/sh

cd $HOME/ORAC-DBA-0.02
ORACLE_HOME=/os/804
export ORACLE_HOME

perl orac_dba.pl &
