select 'ALTER USER SYSTEM TEMPORARY TABLESPACE ' || 
temporary_tablespace || ' DEFAULT TABLESPACE ' || 
default_tablespace || ';' 
from sys.dba_users where username = 'SYSTEM' 
