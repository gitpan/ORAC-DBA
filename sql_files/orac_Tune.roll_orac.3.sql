select name, 
tablespace_name, 
v$rollstat.status status 
from v$rollstat, v$rollname, dba_rollback_segs 
where v$rollstat.usn = v$rollname.usn and name = segment_name 
