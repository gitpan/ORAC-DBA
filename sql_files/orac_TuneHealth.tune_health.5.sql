select (l.misses/l.gets)*100 w2wait_ratio 
from v$latch l, v$latchname n 
where n.name in ('redo allocation') 
and n.latch# = l.latch# 
