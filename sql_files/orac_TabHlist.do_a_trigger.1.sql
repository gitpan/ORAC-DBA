declare 
cursor trig_cursor is select 
owner, 
trigger_name, 
trigger_type, 
triggering_event, 
table_owner, 
table_name, 
referencing_names, 
when_clause, 
status, 
description, 
trigger_body 
from sys.dba_triggers 
where table_owner = 'orac_insert_owner' 
and table_name = 'orac_insert_table' 
order by 1, 2; 
cursor trig_col_cursor (ownr in varchar2, trigname in varchar2, 
tabown in varchar2, tabnam in varchar2) is select 
column_name 
from sys.dba_trigger_cols 
where trigger_owner = ownr and trigger_name = trigname and 
table_owner = tabown and table_name = tabnam; 
lv_owner sys.dba_triggers.owner%TYPE; 
lv_trigger_name sys.dba_triggers.trigger_name%TYPE; 
lv_trigger_type sys.dba_triggers.trigger_type%TYPE; 
lv_triggering_event sys.dba_triggers.triggering_event%TYPE; 
lv_table_owner sys.dba_triggers.table_owner%TYPE; 
lv_table_name sys.dba_triggers.table_name%TYPE; 
lv_referencing_names sys.dba_triggers.referencing_names%TYPE; 
lv_when_clause sys.dba_triggers.when_clause%TYPE; 
lv_status sys.dba_triggers.status%TYPE; 
lv_description sys.dba_triggers.description%TYPE; 
lv_trigger_body sys.dba_triggers.trigger_body%TYPE; 
lv_column_name sys.dba_trigger_cols.column_name%TYPE; 
need_or boolean; 
comma_needed boolean; 
break_wanted boolean; 
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
function wri(x_lin in varchar2, x_str in varchar2, 
x_force in number) return varchar2 is 
begin 
  if length(x_lin) + length(x_str) > 80 
    then 
    lv_lineno := lv_lineno + 1; 
    dbms_output.put_line(x_lin); 
    if x_force = 0 
      then 
      return x_str; 
    else 
      lv_lineno := lv_lineno + 1; 
      dbms_output.put_line(x_str); 
      return ''; 
    end if; 
  else 
    if x_force = 0 
      then 
      return x_lin||x_str; 
    else 
      lv_lineno := lv_lineno + 1; 
      dbms_output.put_line(x_lin||x_str); 
      return ''; 
    end if; 
  end if; 
end wri; 
function brkline(x_lin in varchar2, x_str in varchar2, 
x_force in number) return varchar2 is 
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
      if break_pos > 0 
        then 
        bef_chars := ltrim(substr(x_str, 
        start_break_search, 
        break_pos - start_break_search + 
        1)); 
        if nvl(bef_chars, '@@xyzzy') = '@@xyzzy' 
          then 
          break_pos := 0; 
          if start_break_search + 2 < 
            text_length 
            then 
            search_for_break := 
            TRUE; 
            start_break_search := 
            start_break_search 
            + 1; 
          end if; 
        end if; 
      end if; 
    end loop; 
    lf_pos := instr(x_str, chr(10), startp); 
    lf_break := 0; 
    if (lf_pos < break_pos or break_pos = 0) and lf_pos > 0 
      then 
      break_pos := lf_pos; 
      lf_break := 1; 
    end if; 
    semi_pos := instr(x_str, ';', startp); 
    if break_pos + lf_pos = 0 or (break_pos > semi_pos and 
      semi_pos > 0) 
      then 
      if semi_pos = 0 
        then 
        break_pos := startp + 80; 
        if break_pos > text_length 
          then 
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
    if break_pos - startp > 80 
      then 
      break_pos := startp + 79; 
      if break_pos > text_length 
        then 
        break_pos := text_length + 1; 
      end if; 
      backwords := 1; 
    end if; 
    while backwords = 1 
    loop 
      if break_pos > text_length 
        then 
        backwords := 0; 
        exit; 
      end if; 
      if break_pos <= startp 
        then 
        break_pos := startp + 79; 
        if break_pos > text_length 
          then 
          break_pos := text_length + 1; 
        end if; 
        backwords := 0; 
        exit; 
      end if; 
      if substr(x_str, break_pos, 1) = ' ' 
        then 
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
      out_line := replace(substr(x_str, startp, 
      xchar), chr(9), '        '); 
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
  open trig_cursor; 
  loop 
    fetch trig_cursor into 
    lv_owner, 
    lv_trigger_name, 
    lv_trigger_type, 
    lv_triggering_event, 
    lv_table_owner, 
    lv_table_name, 
    lv_referencing_names, 
    lv_when_clause, 
    lv_status, 
    lv_description, 
    lv_trigger_body; 
    exit when trig_cursor%NOTFOUND; 
    a_lin := wri(a_lin, 'create trigger ', 0); 
    a_lin := wri(a_lin, lv_owner || '.' || lv_trigger_name, 1); 
    if substr(lv_trigger_type, 1, 6) = 'BEFORE' then 
      a_lin := wri(a_lin, ' before', 0); 
    else 
      a_lin := wri(a_lin, ' after', 0); 
    end if; 
    need_or := FALSE; 
    if instr(lv_triggering_event, 'INSERT') != 0 then 
      a_lin := wri(a_lin, ' INSERT', 0); 
      need_or := TRUE; 
    end if; 
    if instr(lv_triggering_event, 'UPDATE') != 0 then 
      if need_or then 
        a_lin := wri(a_lin, ' OR', 0); 
      end if; 
      a_lin := wri(a_lin, ' UPDATE OF', 0); 
      need_or := TRUE; 
      comma_needed := FALSE; 
      open trig_col_cursor (lv_owner, lv_trigger_name, 
      lv_table_owner, lv_table_name); 
      loop 
        fetch trig_col_cursor into 
        lv_column_name; 
        exit when trig_col_cursor%NOTFOUND; 
        if comma_needed then 
          a_lin := wri(a_lin, ',', 0); 
        end if; 
        a_lin := wri(a_lin, ' ' || lv_column_name, 0); 
        comma_needed := TRUE; 
      end loop; 
      close trig_col_cursor; 
    end if; 
    if instr(lv_triggering_event, 'DELETE') != 0 then 
      if need_or then 
        a_lin := wri(a_lin, ' OR', 0); 
      end if; 
      a_lin := wri(a_lin, ' DELETE', 0); 
      need_or := TRUE; 
    end if; 
    a_lin := wri(a_lin, '', 1); 
    a_lin := wri(a_lin, ' on ', 0); 
    a_lin := wri(a_lin, lv_table_owner || '.' || lv_table_name, 1); 
    break_wanted := FALSE; 
    if nvl(lv_referencing_names, ' ') != ' ' then 
      if lv_referencing_names != 
        'REFERENCING NEW AS NEW OLD AS OLD' 
        then 
        a_lin := brkline(a_lin, lv_referencing_names, 
        0); 
        break_wanted := TRUE; 
      end if; 
    end if; 
    if lv_trigger_type = 'BEFORE EACH ROW' or 
      lv_trigger_type = 'AFTER EACH ROW' 
      then 
      a_lin := wri(a_lin, ' FOR EACH ROW', 0); 
      break_wanted := TRUE; 
    end if; 
    if break_wanted then 
      a_lin := wri(a_lin, ' ', 1); 
    end if; 
    if nvl(lv_when_clause, ' ') != ' ' then 
      a_lin := wri(a_lin, ' WHEN (', 0); 
      a_lin := brkline(a_lin, lv_when_clause, 0); 
      a_lin := wri(a_lin, ')', 1); 
    end if; 
    a_lin := brkline(a_lin, lv_trigger_body, 0); 
    if lv_status = 'DISABLED' then 
      a_lin := wri(a_lin, 'alter trigger ', 0); 
      a_lin := wri(a_lin, lv_owner || '.' || lv_trigger_name, 
      0); 
      a_lin := wri(a_lin, ' DISABLE', 0); 
      a_lin := wri(a_lin, ';', 0); 
    end if; 
  end loop; 
  close trig_cursor; 
  exception 
  when others then 
  raise_application_error(-20000, 
  'Unexpected error on ' || lv_owner || 
  '.' || lv_trigger_name || ': ' || 
  to_char(SQLCODE) || ' - Aborting...'); 
end; 
