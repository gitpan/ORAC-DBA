select 'grant ' || S.name || ' to ' || U.username || ';' 
from   system_privilege_map S, sys.sysauth$ P, sys.dba_users U 
where  U.user_id    = P.grantee# 
and    P.privilege# = S.privilege 
and    P.privilege# < 0 
