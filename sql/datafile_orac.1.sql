select 'Data' Type,
tablespace_name Tablespace,
REPLACE(file_name,'?', ? ) File_Name,
to_char(round((bytes/1048576),2)) Act_MB,
decode(status,'AVAILABLE','Avail','INVALID','Inval','****') Status
from dba_data_files
union
select 'Redo' Type,
'Grp '||a.group# Tablespace,
member File_Name,
to_char(round((bytes/1048576),2)) Act_MB,
decode(b.status,'CURRENT','Curr',' INACTIVE','Inact','UNUSED','Unuse','****') Status
from v$logfile a,v$log b where a.group# = b.group#
union
select 'Parm' Type,
'Ctrl 1' Tablepspace,
REPLACE(nvl(ltrim(substr(value,1,instr (value||',',',',1,1)-1)),'  (none)'),'?', ? ) File_Name,
'' Act_MB,
'' Status
from v$parameter where name = 'control_files'
union
select 'Parm' Type,
'Ctrl 2' Tablspace,
REPLACE(nvl(ltrim(substr(value,instr (value||',',',',1,1)+1,instr(value||',',',',1,2) - 
instr (value||',',',',1,1)-1)),'  (none)'), '?', ? ) File_Name,'' Act_MB, '' Status
from v$parameter where name = 'control_files'
union
select 'Parm' Type,
'Ctrl 3' Tablespace,
REPLACE(nvl(ltrim(substr(value,instr(value||',',',',1,2)+1,instr(value||',',',',1,3) - 
instr (value||',',',',1,2)-1)),'  (none)'),'?', ? ) File_Name, '' Act_MB,
'' Status
from v$parameter where name = 'control_files'
union
select 'Parm' Type,
'Ctrl 4' Tablespace,
REPLACE(nvl(ltrim(substr(value,instr(value||',',',',1,3)+1, instr(value||',',',',1,4) - 
instr (value||',',',',1,3)-1)),'  (none)'),'?', ? ) File_Name, '' Act_MB, '' Status
from v$parameter where name = 'control_files'
union
select 'Parm' Type,
'Ifile' Tablespace,
REPLACE(value,'?', ? ) File_Name,
'' Act_MB,
'' Status
from v$parameter where name = 'ifile'
union
select 'Parm' Type,
'Archive' Tablespace,
DECODE(d.log_mode,'ARCHIVELOG',REPLACE(p.value,'?', ? )||' - 
ENABLED', REPLACE(p.value,'?', ? )||' - Disabled') File_Name,'' Act_MB,
'' Status
from v$parameter p,v$database d
where p.name = 'log_archive_dest'
order by 1,2,3
