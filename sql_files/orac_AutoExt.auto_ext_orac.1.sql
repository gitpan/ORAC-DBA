select b.tablespace_name, a.filename, 
       a.filesize, a.maxsize, 
       a.nextsize, a.freesize 
from dba_autoextend a, dba_data_files b 
where a.filename = 
substr(b.file_name, ( 1 + instr(b.file_name, '/', -1))) 
order by b.tablespace_name, a.filename
