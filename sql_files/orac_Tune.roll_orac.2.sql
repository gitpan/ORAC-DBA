select name, waits, floor(100 * waits / gets) pct_wait, 
       decode(sign(9999999-gets), -1, lpad(trunc(gets / 1000000), 3)||' M', 
       decode(sign(9999-gets), -1, lpad(trunc(gets / 1000), 3)||' k', 
       lpad(gets, 5))) gets, decode(sign(9999999-writes)
       , -1, lpad(trunc(writes / 1000000), 3)||' M', 
       decode(sign(9999-writes),-1,lpad(trunc(writes / 1000), 3)||' k', 
       lpad(writes, 5))) writes, 
       rssize / 1048576 v1, optsize /1048576 v2, hwmsize / 1048576 v3, 
       shrinks, extends, 
       decode(sign(9999999-aveactive), -1, 
       lpad(trunc(aveactive / 1000000), 3)||' M', 
       decode(sign(9999-aveactive), -1, 
       lpad(trunc(aveactive / 1000), 3)||' k', 
       lpad(aveactive, 5))) aveactive, 
       extents, xacts, wraps, 
       decode(sign(9999999-aveshrink)
       , -1, lpad(trunc(aveshrink / 1000000), 3)||' M', 
       decode(sign(9999-aveshrink)
       ,-1,lpad(trunc(aveshrink / 1000), 3)||' k', 
       lpad(aveshrink, 5))) aveshrink 
from   v$rollstat, v$rollname 
where  v$rollstat.usn = v$rollname.usn 
