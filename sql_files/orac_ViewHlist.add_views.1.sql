select view_name from dba_views 
where UPPER(owner) = UPPER('orac_insert_owner') 
order by view_name 
