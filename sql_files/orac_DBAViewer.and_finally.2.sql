select column_name, comments 
from   dba_col_comments 
where  owner = 'SYS' and 
       table_name = 'orac_insert_dbaed_bit' 
