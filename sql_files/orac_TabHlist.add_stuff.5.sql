select comments from dba_tab_comments 
where UPPER(owner) = UPPER('orac_insert_owner') 
and UPPER(table_name) = UPPER('orac_insert_table') 
and comments is not null 
