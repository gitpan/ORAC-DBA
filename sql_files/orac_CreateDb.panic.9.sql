select 'alter USER '||username||' quota '||decode(max_bytes,-1,'unlimited',
       to_char(max_bytes/1024)||' K')||' on tablespace '||tablespace_name||';' 
from   sys.dba_ts_quotas 
