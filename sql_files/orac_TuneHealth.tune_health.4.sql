select round((sum(waits) / 
(sum(gets) + .00000001)) * 100,2)||'%' ratio 
from v$rollstat 
