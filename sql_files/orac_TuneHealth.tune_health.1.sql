select (sum(getmisses)/sum(gets))*100 dc_hit_ratio 
from v$rowcache 
