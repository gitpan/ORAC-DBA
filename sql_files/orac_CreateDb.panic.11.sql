select 'grant ' || X.name || ' to ' || U.username || ';' 
from   sys.user$ X, sys.dba_users U 
where  X.user#  IN ( select  privilege#  
                     from    sys.sysauth$  
                     connect by  grantee# = prior privilege#  
                             and privilege# > 0 
                     start   with grantee#  in (1, U.user_id ) 
                             and privilege# > 0 
                   ) 
