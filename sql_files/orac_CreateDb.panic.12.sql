select 'create public synonym ' || synonym_name || ' for ' || 
       decode(table_owner,'','',table_owner||'.') || table_name ||  
       decode(db_link,'','','@'||db_link) || ';' 
from   sys.dba_synonyms 
where  owner = 'PUBLIC' 
and    table_owner != 'SYS' 
