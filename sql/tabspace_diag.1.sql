/* From Oracle Scripts, O Reilly and Associates, Inc. */
/* Copyright 1998 by Brian Lomasky, DBA Solutions, Inc., */
/* lomasky@earthlink.net */

select a.tablespace_name tbsp_nam,
b.tablespace_name dummy,
round(((sum(b.bytes)/count(distinct a.file_id||'.'||a.block_id))/(1024*1024)),2) bytes,
round(((sum(b.bytes)/count(distinct a.file_id||'.'||a.block_id) - 
sum(a.bytes)/count(distinct b.file_id))/(1024*1024)),2) used,
round(((sum(a.bytes)/count(distinct b.file_id))/(1024*1024)),2) free,
round((100 * ((
sum(b.bytes)/count ( distinct a.file_id||'.'||a.block_id )
) - (
sum(a.bytes)/count(distinct b.file_id )
)) / (
sum(b.bytes)/count( distinct a.file_id||'.'||a.block_id )
)),2) pct_used
from sys.dba_free_space a,sys.dba_data_files b
where a.tablespace_name = b.tablespace_name
group by a.tablespace_name,b.tablespace_name
