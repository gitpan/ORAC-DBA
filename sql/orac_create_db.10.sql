select 'CREATE DATABASE "'||value||'"' from sys.v_$parameter where name = 'db_name'
