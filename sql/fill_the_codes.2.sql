/* From Oracle Scripts, O Reilly and Associates, Inc. */
/* Copyright 1998 by Brian Lomasky, DBA Solutions, Inc., */
/* lomasky@earthlink.net */

declare
cursor m_c is select log_mode from sys.v_$database;
cursor mml_c is select max(length(member) + 2) maxmem1 from sys.v_$logfile;
cursor d_c (my_tablespace in varchar2) is select file_name,bytes from sys.dba_data_files
where tablespace_name = my_tablespace
order by file_id;
cursor l_c is select group#,members,bytes from sys.v_$log where thread# = 1 order by 1;
cursor thd_c is
select thread#,group#,members,bytes from sys.v_$log where thread# > 1 order by 1,2;
cursor lfile_c (my_group in number) is select member from sys.v_$logfile where group# = my_group;
cursor tbsp_c is
select ts.name,ts.blocksize * ts.dflinit,ts.blocksize * ts.dflincr,ts.dflminext,ts.dflmaxext,ts.dflextpct,
decode(mod(ts.online$,65536),1,'ONLINE',2,'OFFLINE',4,'READ ONLY','UNDEFINED'),
decode(floor(ts.online$/65536),0,'PERMANENT',1,'TEMPORARY')
from sys.ts$ ts
where ts.name <> 'SYSTEM' and mod(ts.online$,65536) != 3
order by 1;
cursor r_c is
select owner,segment_name,tablespace_name,initial_extent,next_extent,min_extents,max_extents,pct_increase
from sys.dba_rollback_segs
where segment_name not in ('SYSTEM','R000')
order by segment_name;
cursor o_c (my_segment_name in varchar2) is
select decode(c.optsize,NULL,a.initial_extent * a.min_extents,c.optsize)
from sys.dba_rollback_segs a,sys.v_$rollname b,sys.v_$rollstat c
where my_segment_name not in ('SYSTEM','R000')
and a.segment_name = my_segment_name and a.segment_name = b.name and b.usn = c.usn;
l_lm sys.v_$database.log_mode%TYPE;
l_maxmemlen number;
l_fn sys.dba_data_files.file_name%TYPE;
l_byt number;
p_thd# sys.v_$log.thread#%TYPE;
l_thd# sys.v_$log.thread#%TYPE;
p_grp# sys.v_$log.group#%TYPE;
l_gp# sys.v_$log.group#%TYPE;
l_mbs sys.v_$log.members%TYPE;
l_mr sys.v_$logfile.member%TYPE;
l_tbsp sys.dba_tablespaces.tablespace_name%TYPE;
l_iex sys.dba_tablespaces.initial_extent%TYPE;
l_nexex sys.dba_tablespaces.next_extent%TYPE;
l_minex sys.dba_tablespaces.min_extents%TYPE;
l_maxexs sys.dba_tablespaces.max_extents%TYPE;
l_pctin sys.dba_tablespaces.pct_increase%TYPE;
l_tbsp_st varchar2(30);
l_tbsp_cont varchar2(30);
l_on sys.dba_rollback_segs.owner%TYPE;
l_segn sys.dba_rollback_segs.segment_name%TYPE;
l_opt number;
l_iexs varchar2(16);
l_nxtex_siz varchar2(16);
l_ownam varchar2(16);
l_opt_siz varchar2(10);
l_ln number := 0;
l_bsz varchar2(16);
l_l varchar2(80);
n number;
r number;
function pt(x_cod in varchar2,x_lin in varchar2,x_str in varchar2,x_force in number) return varchar2 is
begin
if length(x_lin) + length(x_str) > 80 then
l_ln := l_ln + 1;
dbms_output.put_line(x_cod||'^'||x_lin);
if x_force = 0 then
return '    '||x_str;
else
l_ln := l_ln + 1;
dbms_output.put_line(x_cod||'^'||'    '||x_str);
return '';
end if;
else
if x_force = 0 then
return x_lin||x_str;
else
l_ln := l_ln + 1;
dbms_output.put_line(x_cod||'^'||x_lin||x_str);
return '';
end if;
end if;
end pt;
begin
open mml_c;
fetch mml_c into l_maxmemlen;
close mml_c;
dbms_output.enable(1000000);
l_l := '';
open m_c;
fetch m_c into l_lm;
if m_c%found then
l_l := pt('A',l_l,'    '||l_lm,1);
end if;
close m_c;
l_l := pt('0',l_l,'    DATAFILE ',0);
r := 0;
open d_c ('SYSTEM');
loop
fetch d_c into
l_fn,
l_byt;
exit when d_c%notfound;
r := r + 1;
if r != 1 then
l_l := pt('0',l_l,',',1);
end if;
if mod(l_byt,1048576) = 0 then
l_bsz := to_char(l_byt / 1048576)||'M';
elsif mod(l_byt,1024) = 0 then
l_bsz := to_char(l_byt / 1024)||'K';
else
l_bsz := to_char(l_byt);
end if;
l_l := pt('0',l_l,chr(39)||l_fn||chr(39)||' SIZE '||l_bsz,0);
end loop;
close d_c;
l_l := pt('0',l_l,'',1);
p_grp# := 99999;
open l_c;
loop
fetch l_c into l_gp#,l_mbs,l_byt;
exit when l_c%notfound;
if mod(l_byt,1048576) = 0 then
l_bsz := to_char(l_byt / 1048576)||'M';
elsif mod(l_byt,1024) = 0 then
l_bsz := to_char(l_byt / 1024)||'K';
else
l_bsz := to_char(l_byt);
end if;
if p_grp# != 99999 then
l_l := pt('1',l_l,',',1);
end if;
l_l := pt('1',l_l,'    GROUP'||to_char(l_gp#,'B99')||' (',0);
p_grp# := l_gp#;
r := 0;
open lfile_c (l_gp#);
loop
fetch lfile_c into l_mr;
exit when lfile_c%notfound;
r := r + 1;
if r != 1 then
l_l := pt('1',l_l,'',1);
l_l := pt('1',l_l,'    ',0);
end if;
if r = l_mbs then
l_l := pt('1',l_l,chr(39)||rpad(l_mr||chr(39),l_maxmemlen,' '),0);
else
l_l := pt('1',l_l,chr(39)||rpad(l_mr||chr(39),l_maxmemlen,' ')||',',0);
end if;
end loop;
close lfile_c;
l_l := pt('1',l_l,') SIZE '||l_bsz,0);
end loop;
close l_c;
l_l := pt('1',l_l,';',1);
p_thd# := 99999;
open thd_c;
loop
fetch thd_c into l_thd#,l_gp#,l_mbs,l_byt;
exit when thd_c%notfound;
if p_thd# <> l_thd# then
p_thd# := l_thd#;
l_l := pt('1',l_l,' ',1);
l_l := pt('1',l_l,'ALTER DATABASE ADD LOGFILE THREAD '||to_char(l_thd#),1);
p_grp# := 99999;
end if;
if mod(l_byt,1048576) = 0 then
l_bsz := to_char(l_byt / 1048576)||'M';
elsif mod(l_byt,1024) = 0 then
l_bsz := to_char(l_byt / 1024)||'K';
else
l_bsz := to_char(l_byt);
end if;
if p_grp# != 99999 then
l_l := pt('1',l_l,',',1);
end if;
l_l := pt('1',l_l,'    GROUP'||to_char(l_gp#,'B99')||' (',0);
p_grp# := l_gp#;
r := 0;
open lfile_c (l_gp#);
loop
fetch lfile_c into l_mr;
exit when lfile_c%notfound;
r := r + 1;
if r != 1 then
l_l := pt('1',l_l,'',1);
l_l := pt('1',l_l,'    ',0);
end if;
if r = l_mbs then
l_l := pt('1',l_l,chr(39)||rpad(l_mr||chr(39),l_maxmemlen,' '),0);
else
l_l := pt('1',l_l,chr(39)||rpad(l_mr||chr(39),l_maxmemlen,' ')||',',0);
end if;
end loop;
close lfile_c;
l_l := pt('1',l_l,') SIZE '||l_bsz,0);
end loop;
close thd_c;
l_l := pt('1',l_l,';',1);
if p_thd# <> 99999 then
l_l := pt('1',l_l,'rem',1);
end if;
open tbsp_c;
loop
fetch tbsp_c into l_tbsp,l_iex,l_nexex,l_minex,l_maxexs,
l_pctin,l_tbsp_st,l_tbsp_cont;
exit when tbsp_c%notfound;
l_l := pt('2',l_l,'rem',1);
l_l := pt('2',l_l,'rem ----------------------------------------',1);
l_l := pt('2',l_l,'rem',1);
l_l := pt('2',l_l,'CREATE TABLESPACE '||l_tbsp||' DATAFILE',1);
r := 0;
open d_c (l_tbsp);
loop
fetch d_c into
l_fn,
l_byt;
exit when d_c%notfound;
r := r + 1;
if r != 1 then
l_l := pt('2',l_l,',',1);
end if;
if mod(l_byt,1048576) = 0 then
l_bsz := to_char(l_byt / 1048576)||'M';
elsif mod(l_byt,1024) = 0 then
l_bsz := to_char(l_byt / 1024)||'K';
else
l_bsz := to_char(l_byt);
end if;
l_l := pt('2',l_l,'    '||chr(39)||l_fn||chr(39)||' SIZE '||l_bsz,0);
end loop;
close d_c;
l_l := pt('2',l_l,' ',0);
if mod(l_iex,1048576) = 0 then
l_iexs := to_char(l_iex / 1048576)||'M';
elsif mod(l_iex,1024) = 0 then
l_iexs := to_char(l_iex / 1024)||'K';
else
l_iexs := to_char(l_iex);
end if;
if mod(l_nexex,1048576) = 0 then
l_nxtex_siz := to_char(l_nexex / 1048576)||'M';
elsif mod(l_nexex,1024) = 0 then
l_nxtex_siz := to_char(l_nexex / 1024)||'K';
else
l_nxtex_siz := to_char(l_nexex);
end if;
l_l := pt('2',l_l,'default storage',1);
l_l := pt('2',l_l,'    (initial '||l_iexs,0);
l_l := pt('2',l_l,' next '||l_nxtex_siz,0);
l_l := pt('2',l_l,' pctincrease '||l_pctin,0);
l_l := pt('2',l_l,' minextents '||l_minex,0);
l_l := pt('2',l_l,' maxextents '||l_maxexs,0);
l_l := pt('2',l_l,')',0);
if l_tbsp_cont = 'TEMPORARY' then
l_l := pt('2',l_l,' TEMPORARY',0);
end if;
l_l := pt('2',l_l,';',1);
if l_tbsp_st = 'READ ONLY' then
l_l := pt('2',l_l,'ALTER TABLESPACE '||l_tbsp||' READ ONLY;',1);
end if;
end loop;
close tbsp_c;
l_l := pt('2',l_l,'rem',1);
l_l := pt('2',l_l,'rem ----------------------------------------',1);
l_l := pt('2',l_l,'rem',1);
l_l := pt('2',l_l,'rem  Create additional rollback segments'||' in the rollback tablespace',1);
l_l := pt('2',l_l,'rem',1);
l_l := pt('2',l_l,'rem ----------------------------------------',1);
l_l := pt('2',l_l,'rem',1);
open r_c;
loop
fetch r_c into
l_on,l_segn,l_tbsp,l_iex,
l_nexex,l_minex,l_maxexs,l_pctin;
exit when r_c%notfound;
if l_on = 'PUBLIC' then
l_ownam := ' PUBLIC ';
else
l_ownam := ' ';
end if;
if mod(l_iex,1048576) = 0 then
l_iexs := to_char(l_iex / 1048576)||'M';
elsif mod(l_iex,1024) = 0 then
l_iexs := to_char(l_iex / 1024)||'K';
else
l_iexs := to_char(l_iex);
end if;
if mod(l_nexex,1048576) = 0 then
l_nxtex_siz := to_char(l_nexex / 1048576)||'M';
elsif mod(l_nexex,1024) = 0 then
l_nxtex_siz := to_char(l_nexex / 1024)||'K';
else
l_nxtex_siz := to_char(l_nexex);
end if;
l_l := pt('2',l_l,'CREATE'||l_ownam||'ROLLBACK SEGMENT '||l_segn,0);
l_l := pt('2',l_l,' TABLESPACE '||l_tbsp||' STORAGE',1);
l_l := pt('2',l_l,'    (initial '||l_iexs,0);
l_l := pt('2',l_l,' next '||l_nxtex_siz,0);
l_l := pt('2',l_l,' minextents '||l_minex,0);
l_l := pt('2',l_l,' maxextents '||l_maxexs,0);
open o_c (l_segn);
fetch o_c into l_opt;
if o_c%found then
if mod(l_opt,1048576) = 0 then
l_opt_siz := to_char(l_opt / 1048576)||'M';
elsif mod(l_opt,1024) = 0 then
l_opt_siz := to_char(l_opt / 1024)||'K';
else
l_opt_siz := to_char(l_opt);
end if;
if l_opt != 0 then
l_l := pt('2',l_l,' optimal '||l_opt_siz,0);
end if;
end if;
close o_c;
l_l := pt('2',l_l,');',1);
end loop;
close r_c;
end;
