SELECT (SUM(getmisses)/SUM(gets))*100 dc_hit_ratio
FROM v$rowcache 
