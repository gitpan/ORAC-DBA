declare 
  cursor ind_cursor is 
    select uniqueness,upper(owner),upper(index_name),upper(table_owner),upper(table_name),ini_trans,max_trans,tablespace_name,initial_extent,next_extent,min_extents,max_extents,freelists,freelist_groups,pct_increase,pct_free,table_type 
    from sys.dba_indexes 
    where owner = 'orac_insert_owner' and 
    table_name = 'orac_insert_table' 
    order by owner, index_name; 
  cursor segments_cursor (s_own VARCHAR2, s_ind VARCHAR2) is 
    select bytes 
    from sys.dba_segments 
    where segment_name = s_ind and owner = s_own and 
    segment_type = 'INDEX'; 
cursor col_cursor (c_own varchar2, c_ind varchar2) is 
    select upper(column_name), column_position 
    from sys.dba_ind_columns 
    where index_name = c_ind and index_owner = c_own 
    order by column_position; 
  lv_uniqueness sys.dba_indexes.uniqueness%TYPE; 
  lv_owner sys.dba_indexes.owner%TYPE; 
  lv_index_name sys.dba_indexes.index_name%TYPE; 
  lv_towner sys.dba_indexes.table_owner%TYPE; 
  lv_table_name sys.dba_indexes.table_name%TYPE; 
  lv_ini_trans sys.dba_indexes.ini_trans%TYPE; 
  lv_max_trans sys.dba_indexes.max_trans%TYPE; 
  lv_tablespace_name sys.dba_indexes.tablespace_name%TYPE; 
  lv_initial_extent sys.dba_indexes.initial_extent%TYPE; 
  lv_next_extent sys.dba_indexes.next_extent%TYPE; 
  lv_min_extents sys.dba_indexes.min_extents%TYPE; 
  lv_max_extents sys.dba_indexes.max_extents%TYPE; 
  lv_freelists sys.dba_indexes.freelists%TYPE; 
  lv_freelist_groups sys.dba_indexes.freelist_groups%TYPE; 
  lv_pct_increase sys.dba_indexes.pct_increase%TYPE; 
  lv_pct_free sys.dba_indexes.pct_free%TYPE; 
  lv_table_type sys.dba_indexes.table_type%TYPE; 
  segment_bytes sys.dba_segments.bytes%TYPE; 
  lv_column_name sys.dba_ind_columns.column_name%TYPE; 
  lv_column_position sys.dba_ind_columns.column_position%TYPE; 
  lv_lineno number := 0; 
  initial_extent_size varchar2(16); 
  next_extent_size varchar2(16); 
  a_lin varchar2(80); 
function wri(x_lin in varchar2, x_str in varchar2, x_force in number) return varchar2 is 
begin 
  if length(x_lin) + length(x_str) > 80 then 
    lv_lineno := lv_lineno + 1; 
    dbms_output.put_line(x_lin); 
    if x_force = 0 then 
      return x_str; 
    else 
      lv_lineno := lv_lineno + 1; 
      dbms_output.put_line(x_str); 
      return ''; 
    end if; 
  else 
    if x_force = 0 then 
      return x_lin||x_str; 
    else 
      lv_lineno := lv_lineno + 1; 
      dbms_output.put_line(x_lin||x_str); 
      return ''; 
    end if; 
  end if; 
end wri; 
begin 
  a_lin := ''; 
  open ind_cursor; 
  loop 
    fetch ind_cursor into lv_uniqueness,lv_owner,lv_index_name,lv_towner,lv_table_name,lv_ini_trans,lv_max_trans,lv_tablespace_name,lv_initial_extent,lv_next_extent,lv_min_extents,lv_max_extents,lv_freelists,lv_freelist_groups,lv_pct_increase,lv_pct_free,lv_table_type; 
    exit when ind_cursor%NOTFOUND; 
    if 'orac_insert_v_usesegs' = 'Y' then 
      open segments_cursor (lv_owner, lv_index_name); 
      fetch segments_cursor into segment_bytes; 
      if segments_cursor%found then 
        lv_initial_extent := segment_bytes; 
        if lv_next_extent > lv_initial_extent then 
          lv_next_extent := lv_initial_extent; 
        end if; 
      end if; 
      close segments_cursor; 
    end if; 
    if to_char(lv_ini_trans) = '0' then 
      lv_ini_trans := 1; 
    end if; 
    if to_char(lv_max_trans) = '0' then 
      lv_max_trans := 1; 
    end if; 
    if lv_uniqueness = 'UNIQUE' then 
      a_lin := wri(a_lin, 'create unique index ' || lv_owner, 0); 
    elsif lv_uniqueness = 'BITMAP' then 
      a_lin := wri(a_lin, 'create bitmap index ' || lv_owner, 0); 
    else 
      a_lin := wri(a_lin, 'create index ' || lv_owner, 0); 
    end if; 
    a_lin := wri(a_lin, '.' || lv_index_name, 0); 
    a_lin := wri(a_lin, ' on ', 0); 
    a_lin := wri(a_lin, lv_towner, 0); 
    a_lin := wri(a_lin, '.' || lv_table_name, 0); 
    if lv_table_type = 'TABLE' then 
      a_lin := wri(a_lin, ' (', 0); 
      open col_cursor(lv_owner,lv_index_name); 
      loop 
        fetch col_cursor into lv_column_name, lv_column_position; 
        exit when col_cursor%notfound; 
        if lv_column_position <> 1 then 
          a_lin := wri(a_lin, ',', 0); 
        end if; 
        a_lin := wri(a_lin, chr(34) || lv_column_name || chr(34), 0); 
      end loop; 
      close col_cursor; 
      a_lin := wri(a_lin, ')', 0); 
    end if; 
    a_lin := wri(a_lin, ' TABLESPACE ' || lv_tablespace_name, 0); 
    a_lin := wri(a_lin, ' INITRANS ' || to_char(lv_ini_trans), 0); 
    a_lin := wri(a_lin, ' MAXTRANS ' || to_char(lv_max_trans), 0); 
    a_lin := wri(a_lin, ' PCTFREE ' || to_char(lv_pct_free), 1); 
    /* Calculate extent sizes in Mbytes or Kbytes, if possible */ 
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
    a_lin := wri(a_lin, ' STORAGE (INITIAL ' || initial_extent_size, 0); 
    a_lin := wri(a_lin, ' NEXT ' || next_extent_size, 0); 
    a_lin := wri(a_lin, ' MINEXTENTS ' || to_char(lv_min_extents), 0); 
    a_lin := wri(a_lin, ' MAXEXTENTS ' || to_char(lv_max_extents), 0); 
    a_lin := wri(a_lin, ' PCTINCREASE ' || to_char(lv_pct_increase), 0); 
    a_lin := wri(a_lin, ' FREELISTS ' || to_char(lv_freelists), 0); 
    a_lin := wri(a_lin, ' FREELIST GROUPS ' || to_char(lv_freelist_groups), 0); 
    a_lin := wri(a_lin, ');', 1); 
  end loop; 
  close ind_cursor; 
  exception 
  when others then 
  raise_application_error(-20000,'Unexpected error on '||lv_index_name||', '||lv_column_name||': '||to_char(SQLCODE)||' - Aborting...'); 
end; 
