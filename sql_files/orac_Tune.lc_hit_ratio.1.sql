SELECT (SUM(reloads)/SUM(pins))*100 lc_hit_ratio 
FROM v$librarycache 
