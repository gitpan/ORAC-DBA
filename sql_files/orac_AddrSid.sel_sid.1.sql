select /*+ use_nl(c,a) */ a.username, b.name, c.value 
from v$session a, v$statname b, v$sesstat c 
where a.sid = c.sid and b.statistic# = c.statistic#  
and a.sid = orac_insert_sid 
and c.value > 0 
order by b.name 
