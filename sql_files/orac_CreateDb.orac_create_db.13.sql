 select '   MAXLOGMEMBERS  ' || max(members) * 2 "MEMBER" 
 from   sys.v_$log 
