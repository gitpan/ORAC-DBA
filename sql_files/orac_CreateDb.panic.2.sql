select 'create tablespace ' || T.tablespace_name || chr(10) || 
       'datafile ''' || F.file_name || ''' size ' || 
       to_char(F.bytes/1048576) || 'M' || chr(10) || 
       'default storage (Initial '|| to_char(T.initial_extent) || 
       ' next ' || to_char(T.next_extent) || ' minextents ' ||  
       to_char(T.min_extents) || chr(10) || 
       '         maxextents ' || 
       to_char(T.max_extents) || ' pctincrease ' ||  
       to_char(T.pct_increase) || ') online ;' || chr(10) 
from sys.dba_data_files F, sys.dba_tablespaces T 
where T.tablespace_name = F.tablespace_name 
and   T.tablespace_name != 'SYSTEM' 
and   F.file_id = ( select min(file_id) 
                    from   sys.dba_data_files 
                    where  tablespace_name = T.tablespace_name ) 
