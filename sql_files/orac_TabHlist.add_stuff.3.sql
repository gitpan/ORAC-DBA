select constraint_name from dba_constraints 
where UPPER(owner) = UPPER('orac_insert_owner') 
and UPPER(table_name) = UPPER('orac_insert_table') 
