select db_link 
from   dba_db_links 
where  UPPER(owner) = UPPER('orac_insert_owner') 
order by 1 
