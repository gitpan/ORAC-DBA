select owner, db_link, table_name, synonym_name, table_owner 
from   dba_synonyms 
where  UPPER(db_link) like UPPER('orac_insert_small_db_link%')
