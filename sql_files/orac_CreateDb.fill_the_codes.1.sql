declare
  cursor mode_cursor is 
    select log_mode
    from sys.v_$database;
  cursor datafile_cursor (my_tablespace in varchar2) is 
    select file_name,bytes
    from sys.dba_data_files
    where tablespace_name = my_tablespace
    order by file_id;
  cursor log_cursor is 
    select group#,members,bytes
    from sys.v_$log
    where thread# = 1
    order by 1;
  cursor thread_cursor is 
    select thread#,group#,members,bytes
    from sys.v_$log
    where thread# > 1
    order by 1,2;
  cursor logfile_cursor (my_group in number) is 
    select member
    from sys.v_$logfile
    where group# = my_group;
  cursor tablespace_cursor is 
    select ts.name,ts.blocksize * ts.dflinit,ts.blocksize * ts.dflincr,
    ts.dflminext,ts.dflmaxext,ts.dflextpct,
    decode(mod(ts.online$,65536),1,'ONLINE',2,'OFFLINE',4,'READ ONLY','UNDEFINED'),
    decode(floor(ts.online$/65536),0,'PERMANENT',1,'TEMPORARY')
    from sys.ts$ ts
    where ts.name <> 'SYSTEM' and mod(ts.online$,65536) != 3
    order by 1;
  cursor rollback_cursor is 
    select owner,segment_name,tablespace_name,initial_extent,
    next_extent,min_extents,max_extents,pct_increase
    from sys.dba_rollback_segs
    where segment_name not in ('SYSTEM','R000')
    order by segment_name;
  cursor optimal_cursor (my_segment_name in varchar2) is 
    select decode(c.optsize,NULL,a.initial_extent * a.min_extents,c.optsize)
    from sys.dba_rollback_segs a,sys.v_$rollname b,sys.v_$rollstat c
    where my_segment_name not in ('SYSTEM','R000')
    and a.segment_name = my_segment_name and a.segment_name = b.name and b.usn = c.usn;
  lv_log_mode sys.v_$database.log_mode%TYPE;
  lv_file_name sys.dba_data_files.file_name%TYPE;
  lv_bytes number;
  prev_thread# sys.v_$log.thread#%TYPE;
  lv_thread# sys.v_$log.thread#%TYPE;
  prev_group# sys.v_$log.group#%TYPE;
  lv_group# sys.v_$log.group#%TYPE;
  lv_members sys.v_$log.members%TYPE;
  lv_member sys.v_$logfile.member%TYPE;
  lv_tablespace_name sys.dba_tablespaces.tablespace_name%TYPE;
  lv_initial_extent sys.dba_tablespaces.initial_extent%TYPE;
  lv_next_extent sys.dba_tablespaces.next_extent%TYPE;
  lv_min_extents sys.dba_tablespaces.min_extents%TYPE;
  lv_max_extents sys.dba_tablespaces.max_extents%TYPE;
  lv_pct_increase sys.dba_tablespaces.pct_increase%TYPE;
  lv_tablesp_status varchar2(30);
  lv_tablesp_contents varchar2(30);
  lv_owner sys.dba_rollback_segs.owner%TYPE;
  lv_segment_name sys.dba_rollback_segs.segment_name%TYPE;
  lv_optimal number;
  initial_extent_size varchar2(16);
  next_extent_size varchar2(16);
  owner_name varchar2(6);
  optimal_size varchar2(10);
  lv_lineno number := 0;
  bytes_size varchar2(16);
  a_lin varchar2(80);
  n number;
  r number;
function wri(x_cod in varchar2,x_lin in varchar2,x_str in varchar2,x_force in number) return varchar2 is
begin
  if length(x_lin) + length(x_str) > 80 then
    lv_lineno := lv_lineno + 1;
    dbms_output.put_line(x_cod||'^'||x_lin);
    if x_force = 0 then
      return '    '||x_str;
    else
      lv_lineno := lv_lineno + 1;
      dbms_output.put_line(x_cod||'^'||'    '||x_str);
      return '';
    end if;
  else
    if x_force = 0 then
      return x_lin||x_str;
    else
      lv_lineno := lv_lineno + 1;
      dbms_output.put_line(x_cod||'^'||x_lin||x_str);
      return '';
    end if;
  end if;
end wri;
begin
  dbms_output.enable(1000000);
  a_lin := '';
  open mode_cursor;
  fetch mode_cursor into lv_log_mode;
  if mode_cursor%found then
    a_lin := wri('A',a_lin,'    '||lv_log_mode,1);
  end if;
  close mode_cursor;
  a_lin := wri('0',a_lin,'    DATAFILE ',0);
  r := 0;
  open datafile_cursor ('SYSTEM');
  loop
    fetch datafile_cursor into
      lv_file_name,
      lv_bytes;
    exit when datafile_cursor%notfound;
    r := r + 1;
    if r != 1 then
      a_lin := wri('0',a_lin,',',1);
    end if;
    if mod(lv_bytes,1048576) = 0 then
      bytes_size := to_char(lv_bytes / 1048576)||'M';
    elsif mod(lv_bytes,1024) = 0 then
      bytes_size := to_char(lv_bytes / 1024)||'K';
    else
      bytes_size := to_char(lv_bytes);
    end if;
    a_lin := wri('0',a_lin,chr(39)||lv_file_name||chr(39)||' SIZE '||bytes_size,0);
  end loop;
  close datafile_cursor;
  a_lin := wri('0',a_lin,'',1);
  prev_group# := 99999;
  open log_cursor;
  loop
    fetch log_cursor into lv_group#,lv_members,lv_bytes;
    exit when log_cursor%notfound;
    if mod(lv_bytes,1048576) = 0 then
      bytes_size := to_char(lv_bytes / 1048576)||'M';
    elsif mod(lv_bytes,1024) = 0 then
      bytes_size := to_char(lv_bytes / 1024)||'K';
    else
      bytes_size := to_char(lv_bytes);
    end if;
    if prev_group# != 99999 then
      a_lin := wri('1',a_lin,',',1);
    end if;
      a_lin := wri('1',a_lin,'    GROUP'||to_char(lv_group#,'B99')||' (',0);
      prev_group# := lv_group#;
      r := 0;
      open logfile_cursor (lv_group#);
      loop
        fetch logfile_cursor into lv_member;
        exit when logfile_cursor%notfound;
        r := r + 1;
        if r != 1 then
          a_lin := wri('1',a_lin,'',1);
          a_lin := wri('1',a_lin,'    ',0);
        end if;
        if r = lv_members then
          a_lin := wri('1',a_lin,chr(39)||rpad(lv_member||chr(39),orac_insert_maxmemlen,' '),0);
        else
          a_lin := wri('1',a_lin,chr(39)||rpad(lv_member||chr(39),orac_insert_maxmemlen,' ')||',',0);
        end if;
      end loop;
      close logfile_cursor;
      a_lin := wri('1',a_lin,') SIZE '||bytes_size,0);
    end loop;
    close log_cursor;
    a_lin := wri('1',a_lin,';',1);
    prev_thread# := 99999;
    open thread_cursor;
    loop
      fetch thread_cursor into lv_thread#,lv_group#,lv_members,lv_bytes;
      exit when thread_cursor%notfound;
      if prev_thread# <> lv_thread# then
        prev_thread# := lv_thread#;
        a_lin := wri('1',a_lin,' ',1);
        a_lin := wri('1',a_lin,'ALTER DATABASE ADD LOGFILE THREAD '||to_char(lv_thread#),1);
        prev_group# := 99999;
      end if;
      if mod(lv_bytes,1048576) = 0 then
        bytes_size := to_char(lv_bytes / 1048576)||'M';
      elsif mod(lv_bytes,1024) = 0 then
        bytes_size := to_char(lv_bytes / 1024)||'K';
      else
        bytes_size := to_char(lv_bytes);
      end if;
      if prev_group# != 99999 then
        a_lin := wri('1',a_lin,',',1);
      end if;
      a_lin := wri('1',a_lin,'    GROUP'||to_char(lv_group#,'B99')||' (',0);
      prev_group# := lv_group#;
      r := 0;
      open logfile_cursor (lv_group#);
      loop
        fetch logfile_cursor into lv_member;
        exit when logfile_cursor%notfound;
        r := r + 1;
        if r != 1 then
          a_lin := wri('1',a_lin,'',1);
          a_lin := wri('1',a_lin,'    ',0);
        end if;
        if r = lv_members then
          a_lin := wri('1',a_lin,chr(39)||rpad(lv_member||chr(39),orac_insert_maxmemlen,' '),0);
        else
          a_lin := wri('1',a_lin,chr(39)||rpad(lv_member||chr(39),orac_insert_maxmemlen,' ')||',',0);
        end if;
      end loop;
      close logfile_cursor;
      a_lin := wri('1',a_lin,') SIZE '||bytes_size,0);
    end loop;
    close thread_cursor;
    a_lin := wri('1',a_lin,';',1);
    if prev_thread# <> 99999 then
      a_lin := wri('1',a_lin,'rem',1);
    end if;
    open tablespace_cursor;
  loop
  fetch tablespace_cursor into lv_tablespace_name, lv_initial_extent,lv_next_extent,lv_min_extents,lv_max_extents,
    lv_pct_increase,
    lv_tablesp_status,
    lv_tablesp_contents;
  exit when tablespace_cursor%notfound;
  a_lin := wri('2',a_lin,'rem',1);
  a_lin := wri('2',a_lin,'rem ----------------------------------------',1);
  a_lin := wri('2',a_lin,'rem',1);
  a_lin := wri('2',a_lin,'CREATE TABLESPACE '||lv_tablespace_name||' DATAFILE',1);
  r := 0;
  open datafile_cursor (lv_tablespace_name);
  loop
    fetch datafile_cursor into
      lv_file_name,
      lv_bytes;
      exit when datafile_cursor%notfound;
      r := r + 1;
      if r != 1 then
        a_lin := wri('2',a_lin,',',1);
      end if;
      if mod(lv_bytes,1048576) = 0 then
        bytes_size := to_char(lv_bytes / 1048576)||'M';
      elsif mod(lv_bytes,1024) = 0 then
        bytes_size := to_char(lv_bytes / 1024)||'K';
      else
        bytes_size := to_char(lv_bytes);
      end if;
      a_lin := wri('2',a_lin,'    '||chr(39)||lv_file_name||chr(39)||' SIZE '||bytes_size,0);
    end loop;
    close datafile_cursor;
    a_lin := wri('2',a_lin,' ',0);
    if mod(lv_initial_extent,1048576) = 0 then
      initial_extent_size := to_char(lv_initial_extent / 1048576)||'M';
    elsif mod(lv_initial_extent,1024) = 0 then
      initial_extent_size := to_char(lv_initial_extent / 1024)||'K';
    else
      initial_extent_size := to_char(lv_initial_extent);
    end if;
    if mod(lv_next_extent,1048576) = 0 then
      next_extent_size := to_char(lv_next_extent / 1048576)||'M';
    elsif mod(lv_next_extent,1024) = 0 then
      next_extent_size := to_char(lv_next_extent / 1024)||'K';
    else
      next_extent_size := to_char(lv_next_extent);
    end if;
    a_lin := wri('2',a_lin,'default storage',1);
    a_lin := wri('2',a_lin,'    (initial '||initial_extent_size,0);
    a_lin := wri('2',a_lin,' next '||next_extent_size,0);
    a_lin := wri('2',a_lin,' pctincrease '||lv_pct_increase,0);
    a_lin := wri('2',a_lin,' minextents '||lv_min_extents,0);
    a_lin := wri('2',a_lin,' maxextents '||lv_max_extents,0);
    a_lin := wri('2',a_lin,')',0);
    if lv_tablesp_contents = 'TEMPORARY' then
      a_lin := wri('2',a_lin,' TEMPORARY',0);
    end if;
    a_lin := wri('2',a_lin,';',1);
    if lv_tablesp_status = 'READ ONLY' then
      a_lin := wri('2',a_lin,'ALTER TABLESPACE '||lv_tablespace_name||' READ ONLY;',1);
    end if;
  end loop;
  close tablespace_cursor;
  a_lin := wri('2',a_lin,'rem',1);
  a_lin := wri('2',a_lin,'rem ----------------------------------------',1);
  a_lin := wri('2',a_lin,'rem',1);
  a_lin := wri('2',a_lin,'rem  Create additional rollback segments'||' in the rollback tablespace',1);
  a_lin := wri('2',a_lin,'rem',1);
  a_lin := wri('2',a_lin,'rem ----------------------------------------',1);
  a_lin := wri('2',a_lin,'rem',1);
  open rollback_cursor;
  loop
    fetch rollback_cursor into
      lv_owner,lv_segment_name,lv_tablespace_name,lv_initial_extent,
      lv_next_extent,lv_min_extents,lv_max_extents,lv_pct_increase;
    exit when rollback_cursor%notfound;
    if lv_owner = 'PUBLIC' then
      owner_name := ' PUBLIC ';
    else
      owner_name := ' ';
    end if;
    if mod(lv_initial_extent,1048576) = 0 then
      initial_extent_size := to_char(lv_initial_extent / 1048576)||'M';
    elsif mod(lv_initial_extent,1024) = 0 then
      initial_extent_size := to_char(lv_initial_extent / 1024)||'K';
    else
      initial_extent_size := to_char(lv_initial_extent);
    end if;
    if mod(lv_next_extent,1048576) = 0 then
      next_extent_size := to_char(lv_next_extent / 1048576)||'M';
    elsif mod(lv_next_extent,1024) = 0 then
      next_extent_size := to_char(lv_next_extent / 1024)||'K';
    else
      next_extent_size := to_char(lv_next_extent);
    end if;
    a_lin := wri('2',a_lin,'CREATE'||owner_name||'ROLLBACK SEGMENT '||lv_segment_name,0);
    a_lin := wri('2',a_lin,' TABLESPACE '||lv_tablespace_name||' STORAGE',1);
    a_lin := wri('2',a_lin,'    (initial '||initial_extent_size,0);
    a_lin := wri('2',a_lin,' next '||next_extent_size,0);
    a_lin := wri('2',a_lin,' minextents '||lv_min_extents,0);
    a_lin := wri('2',a_lin,' maxextents '||lv_max_extents,0);
    open optimal_cursor (lv_segment_name);
    fetch optimal_cursor into lv_optimal;
    if optimal_cursor%found then
      if mod(lv_optimal,1048576) = 0 then
        optimal_size := to_char(lv_optimal / 1048576)||'M';
      elsif mod(lv_optimal,1024) = 0 then
        optimal_size := to_char(lv_optimal / 1024)||'K';
      else
        optimal_size := to_char(lv_optimal);
      end if;
      if lv_optimal != 0 then
        a_lin := wri('2',a_lin,' optimal '||optimal_size,0);
      end if;
    end if;
    close optimal_cursor;
    a_lin := wri('2',a_lin,');',1);
  end loop;
  close rollback_cursor;
end;
