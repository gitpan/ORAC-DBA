select 'alter tablespace ' || T.tablespace_name || chr(10) || 
       'add datafile ''' || F.file_name || ''' size ' || 
       to_char(F.bytes/1048576) || 'M ;' || chr(10) 
from sys.dba_data_files F, sys.dba_tablespaces T 
where T.tablespace_name = F.tablespace_name 
and   F.file_id != ( select min(file_id) 
                     from   sys.dba_data_files 
                     where  tablespace_name = T.tablespace_name ) 
