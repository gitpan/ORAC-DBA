select blocks allocated_blocks, 
       count (distinct substr(t.rowid,1,8)||substr(t.rowid,15,4)) used, 
       ((count (distinct substr
       (t.rowid,1,8)||substr(t.rowid,15,4))/blocks) * 100) pct_used 
from   sys.dba_segments e, orac_insert_owner.orac_insert_table t 
where  e.segment_name = upper('orac_insert_table') 
and    e.owner = upper('orac_insert_owner') 
and    e.segment_type = 'TABLE' 
group by e.blocks 
