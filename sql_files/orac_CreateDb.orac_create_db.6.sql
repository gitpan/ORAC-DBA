 select 'rem  Database blocksize   :', value || ' bytes' "VAL" 
 from   sys.v_$parameter 
 where  name = 'db_block_size' 
