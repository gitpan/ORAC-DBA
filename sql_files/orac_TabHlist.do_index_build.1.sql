select column_name, data_type, 
       decode(nullable, 'N', 'Not Null', 'Y', 'Null') 
from   dba_tab_columns 
where  owner = 'orac_insert_ind_owner'  
and    table_name = 'orac_insert_ind_table'  
and    data_type in 
         ('NUMBER','FLOAT', 'VARCHAR2','VARCHAR','LONG','DATE','ROWID','CHAR') 
order by column_id 
