select 'rem  Database name        :'||value from sys.v_$parameter where name = 'db_name'
union
select 'rem  Database created     :'||created from sys.v_$database
union
select 'rem  Database log_mode    :'||log_mode from sys.v_$database
union
select 'rem  Database blocksize   :'||value||' bytes' from sys.v_$parameter where name = 'db_block_size'
union
select 'rem  Database buffers     :'||value||' blocks' from sys.v_$parameter where name = 'db_block_buffers'
union
select 'rem  Database log_buffers :'||value||' blocks' from sys.v_$parameter where name = 'log_buffer'
union
select 'rem  Database ifile       :'||value from sys.v_$parameter where name = 'ifile'
