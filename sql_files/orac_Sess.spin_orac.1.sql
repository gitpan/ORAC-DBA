select column_name 
from   dba_tab_columns 
where  table_name = 'V_$PROCESS' 
order by column_id 
