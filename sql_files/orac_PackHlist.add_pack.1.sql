select distinct name from dba_source 
where UPPER(owner) = UPPER('orac_insert_owner') 
and type = 'PACKAGE' 
order by name 
