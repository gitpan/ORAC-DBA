declare 
  cursor snap_log_cursor is 
    select s.log_owner,s.master,t.pct_free,t.pct_used,t.ini_trans,t.max_trans,t.tablespace_name,t.initial_extent,t.next_extent,t.min_extents,t.max_extents,t.pct_increase 
    from sys.dba_snapshot_logs s, sys.dba_tables t 
    where s.log_owner = 'orac_insert_owner' 
    and s.master = 'orac_insert_snaplog' 
    and s.log_owner = t.owner and s.log_table = t.table_name 
    order by s.log_owner, s.master, s.log_table; 
  lv_log_owner sys.dba_snapshot_logs.log_owner%TYPE; 
  lv_master sys.dba_snapshot_logs.master%TYPE; 
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
  lv_lineno number; 
  a_lin varchar2(80); 
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
begin 
  a_lin := ''; 
  lv_lineno := 0; 
  open snap_log_cursor; 
  loop 
    fetch snap_log_cursor into lv_log_owner,lv_master,lv_pct_free,lv_pct_used,lv_ini_trans,lv_max_trans,lv_tablespace_name,lv_initial_extent,lv_next_extent,lv_min_extents,lv_max_extents,lv_pct_increase; 
    exit when snap_log_cursor%NOTFOUND; 
    a_lin := wri(a_lin, 'create snapshot log on ', 0); 
    a_lin := wri(a_lin, lv_log_owner || '.' || lv_master, 1); 
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
    a_lin := wri(a_lin, ');', 1); 
  end loop; 
  close snap_log_cursor; 
  exception 
  when others then 
  raise_application_error(-20000,'Unexpected error on '||lv_log_owner||'.'||lv_master||': '||to_char(SQLCODE)||' - Aborting...'); 
end; 
