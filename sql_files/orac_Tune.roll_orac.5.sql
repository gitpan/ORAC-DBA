select 1 so, 'Rollback contention for system undo header = '|| 
       (round(max(decode(class, 'system undo header', count, 0)) / 
       (sum(count)+0.00000000001),4))*100||'%'|| 
       '   (Total requests = '||sum(count)||')' 
from v$waitstat 
union 
select 2 so, 'Rollback contention for system undo block  = '|| 
       (round(max(decode(class, 'system undo block', count, 0)) / 
       (sum(count)+0.00000000001),4))*100||'%'|| 
       '   (Total requests = '||sum(count)||')' 
from v$waitstat 
union 
select 3 so, 'Rollback contention for undo header        = '|| 
       (round(max(decode(class, 'undo header', count, 0)) / 
       (sum(count)+0.00000000001),4))*100||'%'|| 
       '   (Total requests = '||sum(count)||')' 
from v$waitstat 
union 
select 4 so, 'Rollback contention for undo block         = '|| 
       (round(max(decode(class, 'undo block', count, 0)) / 
       (sum(count)+0.00000000001),4))*100||'%'|| 
       '   (Total requests = '||sum(count)||')' 
from v$waitstat 
union 
select 5 so, 'If percentage is more than 1%, create more rollback segments' 
from dual 
order by 1 
