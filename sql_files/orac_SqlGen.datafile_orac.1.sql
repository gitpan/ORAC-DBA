select 'Data' type, tablespace_name, REPLACE(file_name,'?', 
       'orac_insert_oracle_home') file_name, bytes/1048576 MB, 
       decode(status,'AVAILABLE','Avail' ,'INVALID','Inval','****') stat 
from   dba_data_files 
union 
select 'Redo', 'Grp ' || a.group#, member, bytes/1048576 MB, 
       decode(b.status,'CURRENT','Curr',' INACTIVE','Inact','UNUSED',
              'Unuse','****') 
from   v$logfile a, v$log b 
where  a.group# = b.group# 
union 
select 'Parm', 'Ctrl 1', REPLACE(nvl(ltrim(substr(value,1,instr 
                                  (value||',',',',1,1)-1)),'  (none)'), 
       '?', 'orac_insert_oracle_home') file_name, 0, '' 
from   v$parameter where name = 'control_files' 
union 
select 'Parm', 'Ctrl 2', REPLACE(nvl(ltrim(substr(value,instr
                             (value||',',',',1,1)+1, 
                             instr(value||',',',',1,2)-instr
                               (value||',',',',1,1)-1)),'  (none)'), 
       '?', 
       'orac_insert_oracle_home') file_name, 0, '' 
from   v$parameter where name = 'control_files' 
union 
select 'Parm', 'Ctrl 3', 
       REPLACE(nvl(ltrim(substr(value,instr(value||',',',',1,2)+1, 
       instr(value||',',',',1,3)-instr
       (value||',',',',1,2)-1)),'  (none)'), 
       '?', 'orac_insert_oracle_home') file_name, 0, '' 
from   v$parameter where name = 'control_files' 
union 
select 'Parm', 'Ctrl 4', 
       REPLACE(nvl(ltrim(substr(value,instr(value||',',',',1,3)+1, 
       instr(value||',',',',1,4)-instr
       (value||',',',',1,3)-1)),'  (none)'), 
       '?', 'orac_insert_oracle_home') file_name, 0, '' 
from   v$parameter where name = 'control_files' 
union 
select 'Parm', 'Ifile', REPLACE(value,'?', 
       'orac_insert_oracle_home') file_name, 0, '' 
from   v$parameter where name = 'ifile' 
union 
select 'Parm', 'Archive', DECODE(d.log_mode, 'ARCHIVELOG', 
       REPLACE(p.value,'?', 'orac_insert_oracle_home') || ' - ENABLED', 
       REPLACE(p.value,'?', 
               'orac_insert_oracle_home') || ' - Disabled') file_name, 
       0, '' 
from   v$parameter p, v$database d 
where  p.name = 'log_archive_dest' 
order by 1, 2, 3 
