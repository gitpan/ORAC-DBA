 select 'rem  Database log_buffers :', value || ' blocks' "VAL" 
 from   sys.v_$parameter 
 where  name = 'log_buffer' 
