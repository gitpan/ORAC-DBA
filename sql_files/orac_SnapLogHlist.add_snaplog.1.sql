select master 
from   dba_snapshot_logs 
where  UPPER(log_owner) = UPPER('orac_insert_owner') 
order by master 
