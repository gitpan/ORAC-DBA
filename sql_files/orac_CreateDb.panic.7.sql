select 'create USER ' || username || ' identified by XXXXX ' || chr(10) || 
       ' default tablespace ' || default_tablespace || 
       ' temporary tablespace '|| temporary_tablespace || chr(10) || 
       ' quota unlimited on ' || default_tablespace || ' ' || 
       ' quota unlimited on ' || temporary_tablespace || ';' || chr(10) 
from   sys.dba_users 
where  username not in ('SYSTEM','SYS','_NEXT_USER','PUBLIC') 
