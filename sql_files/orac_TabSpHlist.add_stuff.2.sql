select  segment_name 
from    dba_segments 
where   tablespace_name = 'orac_insert_tabspace' and 
        owner = 'orac_insert_owner' and 
        bytes > to_number(nvl('orac_insert_vsize','0')) / 300 and 
        segment_type = 'orac_insert_tabind' 
order by segment_name 
