select distinct owner, name, type 
from   dba_source 
where  UPPER(text) like UPPER('%@orac_insert_small_db_link%')
