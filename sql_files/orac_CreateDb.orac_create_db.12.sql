 select '   MAXLOGFILES    ' || max(group#)*max(members)*4 "MEMBER" 
 from   sys.v_$log 
