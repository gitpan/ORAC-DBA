select 'GETS  - # of gets on the rollback segment header: '||
       sum(gets)||chr(10)||
       'WAITS - # of waits for the rollback segment header: '||sum(waits)|| 
       chr(10)||'The ratio of Rollback waits/gets is '|| 
       round((sum(waits) / 
       (sum(gets) + .00000001)) * 100,2)||'%'||chr(10)|| 
       '  If ratio is more than 1%, create more rollback segments' 
from v$rollstat 
