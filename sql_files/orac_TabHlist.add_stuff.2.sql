select index_name from dba_indexes 
where  UPPER(table_owner) = UPPER('orac_insert_owner') 
and    UPPER(table_name) = UPPER('orac_insert_table') 
