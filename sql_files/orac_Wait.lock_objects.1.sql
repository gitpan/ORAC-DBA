select s.osuser, s.username, s.serial#, 
s.sid, a.owner||'.'||a.object tablename, 
a.type lock_mode 
from sys.v_$session s, sys.v_$access a 
where a.sid = s.sid 
order by 6, 1, 2, 3, 4, 5 
