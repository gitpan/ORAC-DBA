select grantor, grantee, table_name, privilege, 
       decode(owner,grantor,'',owner) Owner, 
       decode(grantable,'NO','',grantable) Grantable 
from   dba_tab_privs 
order by grantor, grantee, table_name 
