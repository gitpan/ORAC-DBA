declare 
  t_owner sys.dba_constraints.owner%TYPE; 
  t_constraint_name sys.dba_constraints.constraint_name%TYPE; 
  t_constraint_type sys.dba_constraints.constraint_type%TYPE; 
  t_table_name sys.dba_constraints.table_name%TYPE; 
  t_search_condition sys.dba_constraints.search_condition%TYPE; 
  t_r_owner sys.dba_constraints.r_owner%TYPE; 
  t_r_table sys.dba_constraints.table_name%TYPE; 
  t_r_constraint_name sys.dba_constraints.r_constraint_name%TYPE; 
  t_delete_rule sys.dba_constraints.delete_rule%TYPE; 
  t_status sys.dba_constraints.status%TYPE; 
  lineno number; 
  pending number; 
  nn_pos number; 
  columns_reqd varchar2(1); 
  initial_extent_size varchar2(16); 
  next_extent_size varchar2(16); 
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
  a_lin varchar2(2000); 
  my_lin varchar2(2000); 
  search_for_break boolean; 
  start_break_search number; 
  cursor c1 is 
    select dc1.owner,dc1.table_name,dc1.constraint_name,dc1.constraint_type,dc1.search_condition,dc2.table_name r_table,dc1.r_owner,dc1.r_constraint_name,dc1.delete_rule,dc1.status 
    from  dba_constraints dc1, dba_constraints dc2 
    where dc1.r_constraint_name = dc2.constraint_name (+)  
    and   dc1.owner = 'orac_insert_owner'  
    and   dc1.table_name = 'orac_insert_table'  
    order by decode(dc1.constraint_type,'P',0,'U',0,'R',1,2),dc1.owner,dc1.table_name,dc1.constraint_name,decode(dc1.constraint_type,'P',0,1); 
function wri(x_lin in varchar2, x_str in varchar2, x_force in number) 
return varchar2 is 
begin 
  if length(x_lin) + length(x_str) > 80 then 
    lineno := lineno + 1; 
    dbms_output.put_line(x_lin); 
    if x_force = 0 then 
      return '    '||x_str; 
    else 
      lineno := lineno + 1; 
      if substr(x_lin,1,2) = '  ' then 
        dbms_output.put_line(x_str); 
      else 
        dbms_output.put_line('    '||x_str); 
      end if; 
      return ''; 
    end if; 
  else 
    if x_force = 0 then 
      return x_lin||x_str; 
    else 
      lineno := lineno + 1; 
      dbms_output.put_line(x_lin||x_str); 
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
      break_pos := instr(x_str, ' '||chr(9), 
      start_break_search); 
      if break_pos > 0 then 
        bef_chars := ltrim(substr(x_str, start_break_search, break_pos - start_break_search + 1)); 
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
        substr(out_line, out_start, out_len), new_line); 
        out_start := out_start + out_len; 
      end loop; 
    end if; 
    startp := startp + xchar + offset; 
  end loop; 
  return my_lin; 
end brkline; 
begin 
  lineno := 0; 
  a_lin := ''; 
  open c1; 
  loop 
    fetch c1 into t_owner,t_table_name,t_constraint_name,t_constraint_type,t_search_condition,t_r_table,t_r_owner,t_r_constraint_name,t_delete_rule,t_status; 
    exit when c1%notfound; 
    columns_reqd := 'n'; 
    if t_constraint_type = 'C' then 
      a_lin := wri(a_lin, 'alter table ', 0); 
      a_lin := wri(a_lin, t_owner||'.'||t_table_name, 0); 
      nn_pos := instr(t_search_condition, ' IS NOT NULL'); 
      if nn_pos = 0 then 
        a_lin := wri(a_lin, ' add (', 0); 
        if substr(t_constraint_name, 1, 5) != 'SYS_C' then 
          a_lin := wri(a_lin, 'constraint ', 0); 
          a_lin := wri(a_lin, t_constraint_name, 0); 
          a_lin := wri(a_lin, ' ', 0); 
        end if; 
        a_lin := wri(a_lin, 'check(', 0); 
        a_lin := brkline(a_lin, t_search_condition, 0); 
        a_lin := wri(a_lin, ')', 0); 
      else 
        a_lin := wri(a_lin, ' modify (', 0); 
        a_lin := wri(a_lin, substr(t_search_condition, 1, nn_pos - 1), 0); 
        if substr(t_constraint_name, 1, 5) != 'SYS_C' then 
          a_lin := wri(a_lin, ' constraint ', 0); 
          a_lin := wri(a_lin, t_constraint_name, 0); 
        end if; 
        a_lin := wri(a_lin, ' NOT NULL', 0); 
      end if; 
      if t_status = 'DISABLED' then 
        a_lin := wri(a_lin, ' DISABLE', 0); 
      end if; 
      a_lin := wri(a_lin, ');', 1); 
    end if; 
    if t_constraint_type = 'P' then 
      a_lin := wri(a_lin, 'alter table ', 0); 
      a_lin := wri(a_lin, t_owner||'.'||t_table_name, 0); 
      a_lin := wri(a_lin, ' add constraint ', 0); 
      a_lin := wri(a_lin, t_constraint_name, 0); 
      a_lin := wri(a_lin, ' primary key (', 0); 
      columns_reqd := 'Y'; 
    end if; 
    if t_constraint_type = 'R' then 
      a_lin := wri(a_lin, 'alter table ', 0); 
      a_lin := wri(a_lin, t_owner||'.'||t_table_name, 0); 
      a_lin := wri(a_lin, ' add constraint ', 0); 
      a_lin := wri(a_lin, t_constraint_name, 0); 
      a_lin := wri(a_lin, ' foreign key (', 0); 
      columns_reqd := 'Y'; 
    end if; 
    if t_constraint_type = 'U' then 
      a_lin := wri(a_lin, 'alter table ', 0); 
      a_lin := wri(a_lin, t_owner||'.'||t_table_name, 0); 
      a_lin := wri(a_lin, ' add constraint ', 0); 
      a_lin := wri(a_lin, t_constraint_name, 0); 
      a_lin := wri(a_lin, ' unique (', 0); 
      columns_reqd := 'Y'; 
    end if; 
    if columns_reqd = 'Y' then 
      declare 
      c_owner sys.dba_cons_columns.owner%TYPE; 
      c_constraint_name sys.dba_cons_columns.constraint_name%TYPE; 
      c_table_name sys.dba_cons_columns.table_name%TYPE; 
      c_column_name sys.dba_cons_columns.column_name%TYPE; 
      c_position sys.dba_cons_columns.position%TYPE; 
      cursor c2 is 
        select owner, constraint_name, table_name, column_name, position 
        from dba_cons_columns 
        where owner = t_owner and constraint_name = t_constraint_name and table_name = t_table_name 
        order by position; 
      begin 
        open c2; 
        loop 
          fetch c2 into c_owner, c_constraint_name, c_table_name, c_column_name, c_position; 
          exit when c2%notfound; 
          if c_position > 1 then 
            a_lin := wri(a_lin, ', ', 0); 
          end if; 
          a_lin := wri(a_lin, chr(34) || c_column_name || chr(34), 0); 
        end loop; 
        close c2; 
      end; 
      if t_constraint_type = 'P' or t_constraint_type = 'U' then 
        declare 
          tbs_name sys.dba_indexes.tablespace_name%TYPE; 
          ini_tr sys.dba_indexes.ini_trans%TYPE; 
          max_tr sys.dba_indexes.max_trans%TYPE; 
          init_ex sys.dba_indexes.initial_extent%TYPE; 
          next_ex sys.dba_indexes.next_extent%TYPE; 
          min_ex sys.dba_indexes.min_extents%TYPE; 
          max_ex sys.dba_indexes.max_extents%TYPE; 
          pct_inc sys.dba_indexes.pct_increase%TYPE; 
          pct_fr sys.dba_indexes.pct_free%TYPE; 
          missing_pri_index exception; 
          cursor c5 (t_cons varchar2) is 
            select tablespace_name,ini_trans,max_trans,initial_extent,next_extent,min_extents,max_extents,pct_increase,pct_free 
            from dba_indexes 
            where index_name = t_cons; 
        begin 
          open c5 (t_constraint_name); 
          fetch c5 into tbs_name, ini_tr, max_tr, init_ex, next_ex, min_ex, max_ex, pct_inc, pct_fr; 
          if c5%notfound then 
            raise missing_pri_index; 
          end if; 
          close c5; 
          if mod(init_ex, 1048576) = 0 then 
            initial_extent_size := to_char(init_ex / 1048576) || 'M'; 
          elsif mod(init_ex, 1024) = 0 then 
            initial_extent_size := to_char(init_ex / 1024) || 'K'; 
          else 
            initial_extent_size := to_char(init_ex); 
          end if; 
          if mod(next_ex, 1048576) = 0 then 
            next_extent_size := to_char(next_ex / 1048576) || 'M'; 
          elsif mod(next_ex, 1024) = 0 then 
            next_extent_size := to_char(next_ex / 1024) || 'K'; 
          else 
            next_extent_size := to_char(next_ex); 
          end if; 
          a_lin := wri(a_lin, ') using index ', 0); 
          a_lin := wri(a_lin, 'tablespace ', 0); 
          a_lin := wri(a_lin, tbs_name, 0); 
          a_lin := wri(a_lin, ' storage(', 0); 
          a_lin := wri(a_lin, 'initial ', 0); 
          a_lin := wri(a_lin, initial_extent_size, 0); 
          a_lin := wri(a_lin, ' next ', 0); 
          a_lin := wri(a_lin, next_extent_size, 0); 
          a_lin := wri(a_lin, ' pctincrease ', 0); 
          a_lin := wri(a_lin, pct_inc, 0); 
          a_lin := wri(a_lin, ' minextents ', 0); 
          a_lin := wri(a_lin, min_ex, 0); 
          a_lin := wri(a_lin, ' maxextents ', 0); 
          a_lin := wri(a_lin, max_ex, 0); 
          a_lin := wri(a_lin, ') ', 0); 
          a_lin := wri(a_lin, 'pctfree ', 0); 
          a_lin := wri(a_lin, pct_fr, 0); 
          a_lin := wri(a_lin, ' initrans ', 0); 
          a_lin := wri(a_lin, ini_tr, 0); 
          a_lin := wri(a_lin, ' maxtrans ', 0); 
          a_lin := wri(a_lin, max_tr, 0); 
          exception 
          when missing_pri_index then 
          close c5; 
          a_lin := wri(a_lin, ')', 0); 
        end; 
        if t_status = 'DISABLED' then 
          a_lin := wri(a_lin, ' DISABLE', 0); 
        end if; 
        a_lin := wri(a_lin, ';', 1); 
      end if; 
      if t_constraint_type = 'R' then 
        declare 
          c_owner sys.dba_cons_columns.owner%TYPE; 
          c_table_name sys.dba_cons_columns.table_name%TYPE; 
          cursor c3 is 
            select owner, table_name 
            from dba_cons_columns 
            where owner = t_r_owner and constraint_name = t_r_constraint_name 
            order by position; 
        begin 
          open c3; 
          loop 
            fetch c3 into c_owner, c_table_name; 
            exit when c3%notfound; 
          end loop; 
          close c3; 
          a_lin := wri(a_lin, ')', 0); 
          a_lin := wri(a_lin, ' references ', 0); 
          a_lin := wri(a_lin, c_owner||'.'|| 
          c_table_name, 0); 
        end; 
      end if; 
    end if; 
    if t_constraint_type = 'R' then 
      pending := 0; 
      declare 
      c_owner sys.dba_cons_columns.owner%TYPE; 
      c_constraint_name sys.dba_cons_columns.constraint_name%TYPE; 
      c_table_name sys.dba_cons_columns.table_name%TYPE; 
      c_column_name sys.dba_cons_columns.column_name%TYPE; 
      c_position sys.dba_cons_columns.position%TYPE; 
      cursor c4 is 
      select owner, constraint_name, 
      table_name, column_name, 
      position 
      from dba_cons_columns 
      where owner = t_r_owner and 
      constraint_name = t_r_constraint_name and table_name = t_r_table 
      order by position; 
      begin 
        open c4; 
        loop 
          fetch c4 into c_owner, c_constraint_name, c_table_name, c_column_name, c_position; 
          exit when c4%notfound; 
          if c_position = 1 then 
            a_lin := wri(a_lin, ' (', 0); 
            a_lin := wri(a_lin, chr(34) || c_column_name || chr(34), 0); 
            pending := 1; 
          else 
            a_lin := wri(a_lin, ', ', 0); 
            a_lin := wri(a_lin, chr(34) || c_column_name || chr(34), 0); 
          end if; 
        end loop; 
        close c4; 
      end; 
      if pending = 1 then 
        a_lin := wri(a_lin, ')', 0); 
        if t_delete_rule = 'CASCADE' then 
          a_lin := wri(a_lin, ' on delete cascade', 0); 
        end if; 
        if t_status = 'DISABLED' then 
          a_lin := wri(a_lin, ' DISABLE', 0); 
        end if; 
        a_lin := wri(a_lin, ';', 1); 
      end if; 
    end if; 
  end loop; 
  close c1; 
end; 
