select r.usn, r.name, s.osuser, 
s.username, s.sid, x.extents, 
x.extends, x.waits, x.shrinks, 
x.wraps 
from sys.v_$rollstat X, 
sys.v_$rollname R, 
sys.v_$session S, 
sys.v_$transaction T 
where t.addr = s.taddr (+) 
and x.usn (+) = r.usn 
and t.xidusn (+) = r.usn 
order by r.usn 
