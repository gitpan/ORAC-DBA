select sum(bytes) sumbytes 
from dba_segments where tablespace_name = 'orac_insert_tabspace' 
