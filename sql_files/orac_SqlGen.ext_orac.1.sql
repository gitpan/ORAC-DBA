select owner,tablespace_name,segment_type,segment_name,max_extents,extents,  
       (extents/max_extents*100) PCT, 
       decode(sign(75 - (extents/max_extents*100)), -1, '** FIX **', 
       decode(sign(20 - extents) , -1, '** FIX **', '')) Error 
from   sys.dba_segments 
where  extents > 1 
and    segment_type != 'ROLLBACK' 
and    segment_type != 'CACHE' 
and    owner        != 'SYS' 
order by Error, PCT desc, extents desc, owner, segment_type 
