select vs.username, vs.osuser, 
       vsn.name, vss.value 
from v$session vs, v$sesstat vss, v$statname vsn 
where (vss.statistic#=vsn.statistic#) and 
      (vs.sid = vss.sid) and 
      (vsn.name like '%sort%') 
order by 2, 3 
