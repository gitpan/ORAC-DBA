select trigger_name from dba_triggers 
where UPPER(table_owner) = UPPER('orac_insert_owner') 
and UPPER(table_name) = UPPER('orac_insert_table') 
