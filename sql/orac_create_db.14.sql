select 'ALTER ROLLBACK SEGMENT '||segment_name||' '||status||';'
from   sys.dba_rollback_segs
where  segment_name not in ('SYSTEM','R000')
and    status = 'ONLINE'
order by 1
