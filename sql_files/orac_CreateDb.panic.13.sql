select 'create public database link ' || db_link || chr(10) || 
       'connect to ' || username || ' identified by XXXXXX using ''' || 
       host || ''';' 
from   sys.dba_db_links 
where  owner = 'PUBLIC' 
