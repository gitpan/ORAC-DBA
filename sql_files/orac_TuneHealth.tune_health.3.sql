select name, decode(name,'physical reads',value) 
from v$sysstat 
where name in ('physical reads') 
union 
select name, decode(name,'consistent gets',value) 
from v$sysstat 
where name in ('consistent gets') 
union 
select name, decode(name,'db block gets',value) 
from v$sysstat 
where name in ('db block gets') 
order by 1 
