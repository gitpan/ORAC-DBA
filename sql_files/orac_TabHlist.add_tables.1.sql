select table_name 
from   dba_tables 
where  UPPER(owner) = UPPER('orac_insert_owner') 
order by table_name 
