 select substr(d.tablespace_name,1,15) tspace, 
 d.file_id file_id, 
 d.bytes/1024/1024 tot_mb, 
 d.bytes/orac_insert_Block_Size ora_blks, 
 nvl(sum(e.blocks), 0.00) tot_used, 
 nvl(round(((sum(e.blocks)/
 (d.bytes/orac_insert_Block_Size))*100),2),0.00) pct_used 
 from sys.dba_extents e, 
 sys.dba_data_files d 
 where d.file_id = e.file_id (+) 
 group by d.tablespace_name,D.file_id,d.bytes 
