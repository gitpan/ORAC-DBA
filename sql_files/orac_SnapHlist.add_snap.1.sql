select name 
from   dba_snapshots 
where  UPPER(owner) = UPPER('orac_insert_owner') 
order by name 

