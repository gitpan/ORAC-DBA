/* sql (1):         => dc_hit_ratio
   sql (2):         => lc_hit_ratio
   sql (5/(3 + 4)): => buffer cache hit ratio
   sql (6):         => w2wait_ratio
   sql (7):         => rollback ratio            */

select 1 step_order,(sum(getmisses)/sum(gets))*100 dc_hit_ratio
from v$rowcache
union
select 2 step_order,(sum(reloads)/sum(pins))*100 lc_hit_ratio
from v$librarycache
union
select 3 step_order,value
from v$sysstat
where name in ('physical reads')
union
select 4 step_order,value
from v$sysstat
where name in ('consistent gets')
union
select 5 step_order,value
from v$sysstat
where name in ('db block gets')
union
select 6 step_order,round((sum(waits) / (sum(gets) + .00000001)) * 100,2) ratio
from v$rollstat
union
select 7 step_order,(l.misses/l.gets)*100 w2wait_ratio
from v$latch l,v$latchname n
where n.name in ('redo allocation')
and n.latch# = l.latch#
