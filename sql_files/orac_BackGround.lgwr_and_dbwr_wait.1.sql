select event, total_waits, 
       time_waited 
from v$system_event 
where event like '%file%' 
order by total_waits desc 
