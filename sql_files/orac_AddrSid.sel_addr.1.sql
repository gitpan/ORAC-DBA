select column_name 
from dba_tab_columns 
where table_name = 'V_$SESSION' 
order by column_id 
