select username, tablespace_name, bytes / 1024 "MB", 
decode(max_bytes,-1,'unlimited', rpad(max_bytes / 1024, 9)) "MMB" 
from dba_ts_quotas 
order by 1, 2 
