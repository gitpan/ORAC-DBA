select 'create rollback segment ' || segment_name || 
       ' tablespace ' || tablespace_name || chr(10) || 
       'storage (initial ' || to_char(initial_extent) || 
       ' next ' || to_char(next_extent) || ' minextents ' || 
       to_char(min_extents) || chr(10) || 
       ' maxextents ' || to_char(max_extents) || ') ' || 
       status || ';' || chr(10) 
from   sys.dba_rollback_segs 
where  segment_name != 'SYSTEM' 
