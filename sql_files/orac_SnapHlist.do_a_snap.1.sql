declare 
  cursor snap_cursor is 
    select s.owner,s.name,s.table_name,s.type,s.next,s.start_with,s.query,t.pct_free,t.pct_used,t.ini_trans,t.max_trans,t.tablespace_name,t.initial_extent,t.next_extent,t.min_extents,t.max_extents,t.pct_increase 
    from sys.dba_snapshots s,sys.dba_tables t 
    where s.owner = 'orac_insert_owner' 
    and s.name = 'orac_insert_snap' 
    and s.owner = t.owner and s.table_name = t.table_name 
    order by s.table_name; 
  lv_owner sys.dba_snapshots.owner%TYPE; 
  lv_name sys.dba_snapshots.name%TYPE; 
  lv_table_name sys.dba_snapshots.table_name%TYPE; 
  lv_type sys.dba_snapshots.type%TYPE; 
  lv_next sys.dba_snapshots.next%TYPE; 
  lv_start_with sys.dba_snapshots.start_with%TYPE; 
  lv_query sys.dba_snapshots.query%TYPE; 
  lv_pct_free sys.dba_tables.pct_free%TYPE; 
  lv_pct_used sys.dba_tables.pct_used%TYPE; 
  lv_ini_trans sys.dba_tables.ini_trans%TYPE; 
  lv_max_trans sys.dba_tables.max_trans%TYPE; 
  lv_tablespace_name sys.dba_tables.tablespace_name%TYPE; 
  lv_initial_extent sys.dba_tables.initial_extent%TYPE; 
  lv_next_extent sys.dba_tables.next_extent%TYPE; 
  lv_min_extents sys.dba_tables.min_extents%TYPE; 
  lv_max_extents sys.dba_tables.max_extents%TYPE; 
  lv_pct_increase sys.dba_tables.pct_increase%TYPE; 
  initial_extent_size varchar2(16); 
  next_extent_size varchar2(16); 
  start_date_char varchar2(30); 
  lv_lineno number; 
  text_length number; 
  startp number; 
  xchar number; 
  break_pos number; 
  lf_pos number; 
  semi_pos number; 
  lf_break number; 
  backwords number; 
  new_line number; 
  offset number; 
  out_start number; 
  out_len number; 
  l number; 
  out_line varchar2(2000); 
  bef_chars varchar2(2000); 
  a_lin varchar2(80); 
  my_lin varchar2(2000); 
  search_for_break boolean; 
  start_break_search number; 
function wri(x_lin in varchar2, x_str in varchar2, x_force in number) return varchar2 is 
begin 
  if length(x_lin) + length(x_str) > 80 then 
    lv_lineno := lv_lineno + 1; 
    dbms_output.put_line( x_lin); 
    if x_force = 0 then 
      return x_str; 
    else 
      lv_lineno := lv_lineno + 1; 
      dbms_output.put_line( x_str); 
      return ''; 
    end if; 
  else 
    if x_force = 0 then 
      return x_lin||x_str; 
    else 
      lv_lineno := lv_lineno + 1; 
      dbms_output.put_line( x_lin||x_str); 
      return ''; 
    end if; 
  end if; 
end wri; 
function brkline(x_lin in varchar2, x_str in varchar2, x_force in number) return varchar2 is 
begin 
  my_lin := x_lin; 
  text_length := nvl(length(x_str), 0); 
  startp := 1; 
  while startp <= text_length 
  loop 
    backwords := 0; 
    offset := 0; 
    new_line := 1; 
    search_for_break := TRUE; 
    start_break_search := startp; 
    while search_for_break 
    loop 
      search_for_break := FALSE; 
      break_pos := instr(x_str, ' '||chr(9), start_break_search); 
      if break_pos > 0 then 
        bef_chars := ltrim(substr(x_str, 
        start_break_search, 
        break_pos - start_break_search + 
        1)); 
        if nvl(bef_chars, '@@xyzzy') = '@@xyzzy' then 
          break_pos := 0; 
          if start_break_search + 2 < text_length then 
            search_for_break := TRUE; 
            start_break_search := start_break_search + 1; 
          end if; 
        end if; 
      end if; 
    end loop; 
    lf_pos := instr(x_str, chr(10), startp); 
    lf_break := 0; 
    if (lf_pos < break_pos or break_pos = 0) and lf_pos > 0 then 
      break_pos := lf_pos; 
      lf_break := 1; 
    end if; 
    semi_pos := instr(x_str, ';', startp); 
    if break_pos + lf_pos = 0 or (break_pos > semi_pos and semi_pos > 0) then 
      if semi_pos = 0 then 
        break_pos := startp + 80; 
        if break_pos > text_length then 
          break_pos := text_length + 1; 
        end if; 
        backwords := 1; 
        new_line := 0; 
      else 
        break_pos := semi_pos + 1; 
      end if; 
    else 
      if lf_break = 0 then 
        break_pos := break_pos + 1; 
        offset := 1; 
      else 
        offset := 1; 
      end if; 
    end if; 
    if break_pos - startp > 80 then 
      break_pos := startp + 79; 
      if break_pos > text_length then 
        break_pos := text_length + 1; 
      end if; 
      backwords := 1; 
    end if; 
    while backwords = 1 
    loop 
      if break_pos > text_length then 
        backwords := 0; 
        exit; 
      end if; 
      if break_pos <= startp then 
        break_pos := startp + 79; 
        if break_pos > text_length then 
          break_pos := text_length + 1; 
        end if; 
        backwords := 0; 
        exit; 
      end if; 
      if substr(x_str, break_pos, 1) = ' ' then 
        backwords := 0; 
        exit; 
      end if; 
      break_pos := break_pos - 1; 
    end loop; 
    xchar := break_pos - startp; 
    if xchar = 0 then 
      if offset = 0 then 
        return my_lin; 
      end if; 
    else 
      out_line := replace(substr(x_str, startp, xchar), chr(9), '        '); 
      out_start := 1; 
      l := length(out_line); 
      if nvl(l, -1) = -1 then 
        return my_lin; 
      end if; 
      while out_start <= l 
      loop 
        if l >= out_start + 79 then 
          out_len := 80; 
        else 
          out_len := l - out_start + 1; 
        end if; 
        my_lin := wri(my_lin, 
        substr(out_line, out_start, 
        out_len), new_line); 
        out_start := out_start + out_len; 
      end loop; 
    end if; 
    startp := startp + xchar + offset; 
  end loop; 
  return my_lin; 
end brkline; 
begin 
  a_lin := ''; 
  lv_lineno := 0; 
  open snap_cursor; 
  loop 
    fetch snap_cursor into lv_owner,lv_name,lv_table_name,lv_type,lv_next,lv_start_with,lv_query,lv_pct_free,lv_pct_used,lv_ini_trans,lv_max_trans,lv_tablespace_name,lv_initial_extent,lv_next_extent,lv_min_extents,lv_max_extents,lv_pct_increase; 
    exit when snap_cursor%NOTFOUND; 
    a_lin := wri(a_lin, 'create snapshot ' || lv_owner, 0); 
    a_lin := wri(a_lin, '.' || lv_name, 1); 
    a_lin := wri(a_lin, ' PCTFREE ' || to_char(lv_pct_free), 0); 
    a_lin := wri(a_lin, ' PCTUSED ' || to_char(lv_pct_used), 0); 
    a_lin := wri(a_lin, ' INITRANS ' || to_char(lv_ini_trans), 0); 
    a_lin := wri(a_lin, ' MAXTRANS ' || to_char(lv_max_trans), 0); 
    a_lin := wri(a_lin, ' TABLESPACE ' || lv_tablespace_name, 1); 
    a_lin := wri(a_lin, ' STORAGE (', 0); 
    if mod(lv_initial_extent, 1048576) = 0 then 
      initial_extent_size := 
      to_char(lv_initial_extent / 1048576) || 'M'; 
    elsif mod(lv_initial_extent, 1024) = 0 then 
      initial_extent_size := 
      to_char(lv_initial_extent / 1024) || 'K'; 
    else 
      initial_extent_size := to_char(lv_initial_extent); 
    end if; 
    if mod(lv_next_extent, 1048576) = 0 then 
      next_extent_size := 
      to_char(lv_next_extent / 1048576) || 'M'; 
    elsif mod(lv_next_extent, 1024) = 0 then 
      next_extent_size := 
      to_char(lv_next_extent / 1024) || 'K'; 
    else 
      next_extent_size := to_char(lv_next_extent); 
    end if; 
    a_lin := wri(a_lin, ' INITIAL ' || initial_extent_size, 0); 
    a_lin := wri(a_lin, ' NEXT ' || next_extent_size, 0); 
    a_lin := wri(a_lin, ' MINEXTENTS ' || to_char(lv_min_extents), 0); 
    a_lin := wri(a_lin, ' MAXEXTENTS ' || to_char(lv_max_extents), 0); 
    a_lin := wri(a_lin, ' PCTINCREASE ' || to_char(lv_pct_increase), 0); 
    a_lin := wri(a_lin, ')', 1); 
    a_lin := wri(a_lin, ' refresh', 0); 
    if lv_type = ' ' then 
      lv_type := 'FORCE'; 
    end if; 
    a_lin := wri(a_lin, ' ' || lv_type, 0); 
    start_date_char := to_char(lv_start_with, 'DD-MON-YY'); 
    if nvl(start_date_char, ' ') != ' ' then 
      a_lin := wri(a_lin, ' start with ' || start_date_char, 0); 
    end if; 
    if nvl(lv_next, ' ') != ' ' then 
      a_lin := brkline(a_lin, ' next ' || lv_next, 0); 
    end if; 
    a_lin := wri(a_lin, ' as ', 0); 
    a_lin := brkline(a_lin, lv_query, 0); 
    a_lin := wri(a_lin, ';', 1); 
  end loop; 
  close snap_cursor; 
  exception 
  when others then 
  raise_application_error(-20000,'Unexpected error on '||lv_owner||'.'||lv_table_name||': '||to_char(SQLCODE)||' - Aborting...'); 
end; 
