select p.pid, p.spid, s.sid, lower(s.username) ora_user, p.username unix_user, 
       to_char(s.logon_time,'mm/dd/yy hh24:mi:ss') whenon, 
       to_char(sysdate - (s.last_call_et) / 86400,'mm/dd/yy hh24:mi:ss') 
       whendo 
from   v$process p, v$session s 
where  s.paddr(+) = p.addr 
order by s.logon_time 
