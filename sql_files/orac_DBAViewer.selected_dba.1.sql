select column_name, data_type, decode(nullable, 'N', 'Not Null', 'Y', 'Null'), 
       data_length 
from   dba_tab_columns 
where  owner = 'SYS'  
and    table_name = 'orac_insert_dbaed_bit'  
and    data_type in ('NUMBER','FLOAT','VARCHAR2','VARCHAR','DATE','CHAR') 
order by column_id 
