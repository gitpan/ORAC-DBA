select pct_free from dba_tables 
where owner = 'orac_insert_owner' and table_name = 'orac_insert_table' 
