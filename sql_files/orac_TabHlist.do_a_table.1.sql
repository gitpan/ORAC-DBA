declare 
  cursor tab_cursor is 
    select upper(owner),upper(table_name),pct_free,pct_used,ini_trans,max_trans,tablespace_name,initial_extent,next_extent,min_extents,max_extents,freelists,freelist_groups,pct_increase 
    from sys.dba_tables 
    where owner = 'orac_insert_owner' and 
    table_name = 'orac_insert_table' 
    order by owner, table_name; 
  cursor segments_cursor (s_own VARCHAR2, s_tab VARCHAR2) is 
    select bytes 
    from sys.dba_segments 
    where segment_name = s_tab and owner = s_own and segment_type = 'TABLE'; 
  cursor col_cursor (c_own VARCHAR2, c_tab VARCHAR2) is 
    select owner,upper(column_name),upper(data_type),data_length,data_precision,data_scale,nullable,default_length,data_default,column_id 
    from sys.dba_tab_columns 
    where table_name = c_tab and owner = c_own 
    order by column_id; 
  lv_owner sys.dba_tables.owner%TYPE; 
  lv_table_name sys.dba_tables.table_name%TYPE; 
  lv_pct_free sys.dba_tables.pct_free%TYPE; 
  lv_pct_used sys.dba_tables.pct_used%TYPE; 
  lv_ini_trans sys.dba_tables.ini_trans%TYPE; 
  lv_max_trans sys.dba_tables.max_trans%TYPE; 
  lv_tablespace_name sys.dba_tables.tablespace_name%TYPE; 
  lv_initial_extent sys.dba_tables.initial_extent%TYPE; 
  lv_next_extent sys.dba_tables.next_extent%TYPE; 
  lv_min_extents sys.dba_tables.min_extents%TYPE; 
  lv_max_extents sys.dba_tables.max_extents%TYPE; 
  lv_freelists sys.dba_tables.freelists%TYPE; 
  lv_freelist_groups     sys.dba_tables.freelist_groups%TYPE; 
  lv_pct_increase sys.dba_tables.pct_increase%TYPE; 
  segment_bytes sys.dba_segments.bytes%TYPE; 
  lv_column_name sys.dba_tab_columns.column_name%TYPE; 
  lv_data_type sys.dba_tab_columns.data_type%TYPE; 
  lv_data_length sys.dba_tab_columns.data_length%TYPE; 
  lv_data_precision sys.dba_tab_columns.data_precision%TYPE; 
  lv_data_scale sys.dba_tab_columns.data_scale%TYPE; 
  lv_nullable sys.dba_tab_columns.nullable%TYPE; 
  lv_default_length sys.dba_tab_columns.default_length%TYPE; 
  lv_data_default sys.dba_tab_columns.data_default%TYPE; 
  lv_column_id sys.dba_tab_columns.column_id%TYPE; 
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
  open tab_cursor; 
  loop 
    fetch tab_cursor into lv_owner,lv_table_name,lv_pct_free,lv_pct_used,lv_ini_trans,lv_max_trans,lv_tablespace_name,lv_initial_extent,lv_next_extent,lv_min_extents,lv_max_extents,lv_freelists,lv_freelist_groups,lv_pct_increase; 
    exit when tab_cursor%notfound; 
    if 'orac_insert_v_usesegs' = 'Y' then 
      open segments_cursor (lv_owner, lv_table_name); 
      fetch segments_cursor into segment_bytes; 
      if segments_cursor%found then 
        lv_initial_extent := segment_bytes; 
        if lv_next_extent > lv_initial_extent then 
          lv_next_extent := lv_initial_extent; 
        end if; 
      end if; 
      close segments_cursor; 
    end if; 
    a_lin := wri(a_lin, 'create table ', 0); 
    a_lin := wri(a_lin, lv_owner || '.' || lv_table_name, 0); 
    a_lin := wri(a_lin, ' (', 0); 
    if (to_char(lv_ini_trans) = '0') then 
      lv_ini_trans := 1; 
    end if; 
    if (to_char(lv_max_trans) = '0') then 
      lv_max_trans := 1; 
    end if; 
    open col_cursor(lv_owner, lv_table_name); 
    loop 
      fetch col_cursor into lv_owner,lv_column_name,lv_data_type,lv_data_length,lv_data_precision,lv_data_scale,lv_nullable,lv_default_length,lv_data_default,lv_column_id; 
      exit when col_cursor%notfound; 
      if lv_column_id <> 1 then 
        a_lin := wri(a_lin, ',', 0); 
      end if; 
      a_lin := wri(a_lin, chr(34) || lv_column_name || chr(34), 0); 
      a_lin := wri(a_lin, ' ' || lv_data_type, 0); 
      if lv_data_type = 'CHAR' or lv_data_type = 'VARCHAR2' or lv_data_type = 'RAW' then 
        a_lin := wri(a_lin, '(' || lv_data_length || ')', 0); 
      end if; 
      if (lv_data_type = 'NUMBER' and nvl(lv_data_precision, 0) != 0) or lv_data_type = 'FLOAT' then 
        if nvl(lv_data_scale, 0) = 0 then 
          a_lin := wri(a_lin, '(' || lv_data_precision || ')', 0); 
        else 
          a_lin := wri(a_lin, '(' || lv_data_precision || ',' || lv_data_scale || ')', 0); 
        end if; 
      end if; 
      if lv_default_length != 0 then 
        if lv_default_length < 80 then 
          a_lin := wri(a_lin, ' DEFAULT ', 0); 
          a_lin := wri(a_lin, lv_data_default, 0); 
        else 
          dbms_output.put_line( 'Skipping default clause on ' || 'column ' || lv_column_name); 
          dbms_output.put_line( ' on table ' || lv_table_name); 
          dbms_output.put_line( ' since length is ' || to_char(lv_default_length)); 
        end if; 
      end if; 
      if lv_nullable = 'N' then 
        a_lin := wri(a_lin, ' NOT NULL', 0); 
      end if; 
    end loop; 
    close col_cursor; 
    a_lin := wri(a_lin, ')', 1); 
    a_lin := wri(a_lin, ' PCTFREE ' || to_char(lv_pct_free), 0); 
    a_lin := wri(a_lin, ' PCTUSED ' || to_char(lv_pct_used), 0); 
    a_lin := wri(a_lin, ' INITRANS ' || to_char(lv_ini_trans), 0); 
    a_lin := wri(a_lin, ' MAXTRANS ' || to_char(lv_max_trans), 0); 
    a_lin := wri(a_lin, ' TABLESPACE ' || lv_tablespace_name, 1); 
    a_lin := wri(a_lin, ' STORAGE (', 0); 
    if mod(lv_initial_extent, 1048576) = 0 then 
      initial_extent_size := to_char(lv_initial_extent / 1048576) || 'M'; 
    elsif mod(lv_initial_extent, 1024) = 0 then 
      initial_extent_size := to_char(lv_initial_extent / 1024) || 'K'; 
    else 
      initial_extent_size := to_char(lv_initial_extent); 
    end if; 
    if mod(lv_next_extent, 1048576) = 0 then 
      next_extent_size := to_char(lv_next_extent / 1048576) || 'M'; 
    elsif mod(lv_next_extent, 1024) = 0 then 
      next_extent_size := to_char(lv_next_extent / 1024) || 'K'; 
    else 
      next_extent_size := to_char(lv_next_extent); 
    end if; 
    a_lin := wri(a_lin, ' INITIAL ' || initial_extent_size, 0); 
    a_lin := wri(a_lin, ' NEXT ' || next_extent_size, 0); 
    a_lin := wri(a_lin, ' MINEXTENTS ' || to_char(lv_min_extents), 0); 
    a_lin := wri(a_lin, ' MAXEXTENTS ' || to_char(lv_max_extents), 0); 
    a_lin := wri(a_lin, ' PCTINCREASE ' || to_char(lv_pct_increase), 0); 
    a_lin := wri(a_lin, ' FREELISTS ' || to_char(lv_freelists), 0); 
    a_lin := wri(a_lin, ' FREELIST GROUPS ' || 
    to_char(lv_freelist_groups), 0); 
    a_lin := wri(a_lin, ');', 1); 
  end loop; 
  close tab_cursor; 
  exception 
  when others then 
  raise_application_error(-20000,'Unexpected error on '||lv_table_name||', '||lv_column_name||': '||to_char(SQLCODE) ||' - Aborting...'); 
end; 
