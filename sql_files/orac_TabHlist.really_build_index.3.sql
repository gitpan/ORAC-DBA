select pct_free, ini_trans 
from dba_tables 
where owner = upper('orac_insert_ind_owner') 
and table_name = upper('orac_insert_ind_table')
