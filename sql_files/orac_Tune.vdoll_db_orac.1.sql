select column_name from 
dba_tab_columns where owner = 'SYS' 
and table_name = 'V_$DATABASE' 
order by column_id 
