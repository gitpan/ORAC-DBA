 select 'ALTER USER SYS TEMPORARY TABLESPACE ' || 
 temporary_tablespace || ';' 
 from sys.dba_users where username = 'SYS' 
