 select 'rem  Database name        :', value 
 from sys.v_$parameter 
 where name = 'db_name' 
