  select a.tablespace_name name,
         b.tablespace_name dummy,
         sum(b.bytes)/count( distinct a.file_id||'.'||a.block_id ) bytes,
         sum(b.bytes)/count( distinct a.file_id||'.'||a.block_id ) - 
         sum(a.bytes)/count( distinct b.file_id ) used,
         sum(a.bytes)/count( distinct b.file_id ) free, 
         100 * ( (sum(b.bytes)/count ( distinct a.file_id||'.'||a.block_id )) - 
               (sum(a.bytes)/count( distinct b.file_id ) )) / 
               (sum(b.bytes)/count
               ( distinct a.file_id||'.'||a.block_id )) pct_used 
  from sys.dba_free_space a, sys.dba_data_files b 
  where a.tablespace_name = b.tablespace_name 
  group by a.tablespace_name, b.tablespace_name
