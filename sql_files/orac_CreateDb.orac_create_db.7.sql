 select 'rem  Database buffers     :', value || ' blocks' "VAL" 
 from   sys.v_$parameter 
 where  name = 'db_block_buffers' 
