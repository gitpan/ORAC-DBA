declare 
cursor tbl is 
select column_name, data_type, data_length, data_precision, data_scale 
from sys.dba_tab_columns 
where table_name = 'orac_insert_table' and  
owner = 'orac_insert_owner' 
order by column_id; 
cursor ind is 
select index_name, owner, uniqueness 
from sys.dba_indexes 
where table_name = 'orac_insert_table' 
and owner = 'orac_insert_owner'; 
lv_column_name sys.dba_tab_columns.column_name%TYPE; 
lv_data_type sys.dba_tab_columns.data_type%TYPE; 
lv_data_length sys.dba_tab_columns.data_length%TYPE; 
lv_data_precision sys.dba_tab_columns.data_precision%TYPE; 
lv_data_scale sys.dba_tab_columns.data_scale%TYPE; 
lv_index_name sys.dba_indexes.index_name%TYPE; 
lv_owner sys.dba_indexes.owner%TYPE; 
lv_uniqueness sys.dba_indexes.uniqueness%TYPE; 
column_name char(30); 
data_type char(9); 
the_length char(7); 
my_cursor number; 
dummy number; 
pct_dist number; 
linen number; 
txt varchar2(80); 
function pct_distinct(a_col IN varchar2) return char is 
begin 
  if orac_insert_kount = 0 then 
    return '       0'; 
  else 
    my_cursor := dbms_sql.open_cursor; 
    dbms_sql.parse(my_cursor, 'select count(distinct ' || a_col || ')' || 
    ' from orac_insert_owner.orac_insert_table ', dbms_sql.v7); 
    dbms_sql.define_column(my_cursor, 1, pct_dist); 
    dummy := dbms_sql.execute(my_cursor); 
    if dbms_sql.fetch_rows(my_cursor) > 0 then 
      dbms_sql.column_value(my_cursor, 1, pct_dist); 
    else 
      pct_dist := 0; 
    end if; 
    dbms_sql.close_cursor(my_cursor); 
    return lpad(round(pct_dist * 100 / orac_insert_kount), 7); 
  end if; 
end pct_distinct; 
begin 
  linen := 0; 
  txt := ' '; 
  linen := linen + 1; 
  dbms_output.put_line(txt); 
  if 'orac_insert_percent_of_distinct_cols' = 'Y' then 
    txt := '                                                    ' || 
    'Percent'; 
    linen := linen + 1; 
    dbms_output.put_line( txt); 
    txt := '                                                    ' || 'distinct'; 
    linen := linen + 1; 
    dbms_output.put_line( txt); 
    txt := '   Column                         Datatype   Length ' || ' values'; 
    linen := linen + 1; 
    dbms_output.put_line( txt); 
    txt := '   ------------------------------ --------- ------- ' || '--------'; 
  else 
    txt := '   Column                         Datatype   Length'; 
    linen := linen + 1; 
    dbms_output.put_line( txt); 
    txt := '   ------------------------------ --------- -------'; 
  end if; 
  linen := linen + 1; 
  dbms_output.put_line( txt); 
  open tbl; 
  loop 
    fetch tbl into lv_column_name, lv_data_type, lv_data_length, lv_data_precision, lv_data_scale; 
    exit when tbl%notfound; 
    column_name := lv_column_name; 
    data_type := lv_data_type; 
    if lv_data_type = 'NUMBER' and lv_data_precision is not null or lv_data_type = 'FLOAT' then 
      if nvl(lv_data_scale, 0) = 0 then 
        the_length := lpad('(' || 
        to_char(lv_data_precision) || ')', 7); 
      else 
        the_length := lpad('(' || 
        to_char(lv_data_precision) || ',' || 
        to_char(lv_data_scale) || ')', 7); 
      end if; 
    else 
      the_length := to_char(lv_data_length, '999999'); 
    end if; 
    if lv_data_type = 'LONG' then 
      txt := '   ' || column_name || ' ' || data_type || ' ' || the_length || '    n/a'; 
    else 
      if 'orac_insert_percent_of_distinct_cols' = 'N' then 
        txt := '   ' || column_name || ' ' || data_type || ' ' || the_length; 
      else 
        txt := '   ' || column_name || ' ' || data_type || ' ' || the_length || pct_distinct(lv_column_name) || '%'; 
      end if; 
    end if; 
    linen := linen + 1; 
    dbms_output.put_line( txt); 
  end loop; 
  close tbl; 
  open ind; 
  loop 
    fetch ind into lv_index_name, lv_owner, lv_uniqueness; 
    exit when ind%notfound; 
    declare 
    lv_col_name sys.dba_ind_columns.column_name%TYPE; 
    lv_col_pos sys.dba_ind_columns.column_position%TYPE; 
    cursor ind_col is 
    select column_name, column_position 
    from sys.dba_ind_columns 
    where index_name = lv_index_name and 
    index_owner = lv_owner 
    order by column_position; 
    begin 
      open ind_col; 
      loop 
        fetch ind_col into lv_col_name, lv_col_pos; 
        exit when ind_col%notfound; 
        if lv_col_pos = 1 then 
          if lv_uniqueness = 'UNIQUE' then 
            txt := '     Unique Index ' || rtrim(lv_index_name) || ' on ' || rtrim(lv_col_name); 
          elsif lv_uniqueness = 'BITMAP' then 
            txt := '     Bitmap Index ' || rtrim(lv_index_name) || ' on ' || rtrim(lv_col_name); 
          else 
            txt := '     Index ' || rtrim(lv_index_name) || ' on ' || rtrim(lv_col_name); 
          end if; 
        else 
          if lv_uniqueness = 'UNIQUE' then 
            txt := '            '|| rpad(' ',length(rtrim( lv_index_name))+10) || rtrim(lv_col_name); 
          elsif lv_uniqueness = 'BITMAP' then 
            txt := '            '|| rpad(' ',length(rtrim( lv_index_name))+10) || rtrim(lv_col_name); 
          else 
            txt := '     '|| rpad(' ',length(rtrim( lv_index_name))+10) || rtrim(lv_col_name); 
          end if; 
        end if; 
        linen := linen + 1; 
        dbms_output.put_line( txt); 
      end loop; 
      close ind_col; 
    end; 
  end loop; 
  close ind; 
end; 
