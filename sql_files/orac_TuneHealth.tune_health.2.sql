select (sum(reloads)/sum(pins))*100 lc_hit_ratio 
from v$librarycache 
