declare 
  cursor seq_cursor is 
    select sequence_owner, sequence_name, min_value, max_value, increment_by, cycle_flag, order_flag, cache_size 
    from sys.dba_sequences 
    where sequence_owner = 'orac_insert_owner' 
    and sequence_name = 'orac_insert_seq' 
    order by 1, 2; 
  lv_sequence_owner sys.dba_sequences.sequence_owner%TYPE; 
  lv_sequence_name sys.dba_sequences.sequence_name%TYPE; 
  lv_min_value sys.dba_sequences.min_value%TYPE; 
  lv_max_value sys.dba_sequences.max_value%TYPE; 
  lv_increment_by sys.dba_sequences.increment_by%TYPE; 
  lv_cycle_flag sys.dba_sequences.cycle_flag%TYPE; 
  lv_order_flag sys.dba_sequences.order_flag%TYPE; 
  lv_cache_size sys.dba_sequences.cache_size%TYPE; 
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
  bef_chars varchar2(80); 
  out_line varchar2(640); 
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
  lv_lineno := 0; 
  open seq_cursor; 
  loop 
    fetch seq_cursor into lv_sequence_owner,lv_sequence_name,lv_min_value,lv_max_value,lv_increment_by,lv_cycle_flag,lv_order_flag,lv_cache_size; 
    exit when seq_cursor%NOTFOUND; 
    a_lin := wri(a_lin, 'create sequence ', 0); 
    a_lin := wri(a_lin, lv_sequence_owner || '.' || 
    lv_sequence_name, 1); 
    a_lin := wri(a_lin, ' increment by ' || 
    to_char(lv_increment_by), 0); 
    if lv_increment_by > 0 then 
      if lv_min_value = 1 then 
        a_lin := wri(a_lin, ' nominvalue', 0); 
      else 
        a_lin := wri(a_lin, ' minvalue ' || 
        to_char(lv_min_value), 0); 
      end if; 
      if lv_max_value > power(10, 26) then 
        a_lin := wri(a_lin, ' nomaxvalue', 0); 
      else 
        a_lin := wri(a_lin, ' maxvalue ' || 
        to_char(lv_max_value), 0); 
      end if; 
    else 
      if lv_min_value < -1 * POWER(10,25) then 
        a_lin := wri(a_lin, ' nominvalue', 0); 
      else 
        a_lin := wri(a_lin, ' minvalue ' || 
        to_char(lv_min_value), 0); 
      end if; 
      if lv_max_value = -1 then 
        a_lin := wri(a_lin, ' nomaxvalue', 0); 
      else 
        a_lin := wri(a_lin, ' maxvalue ' || 
        to_char(lv_max_value), 0); 
      end if; 
    end if; 
    if lv_cycle_flag = 'Y' then 
      a_lin := wri(a_lin, ' cycle', 0); 
    else 
      a_lin := wri(a_lin, ' nocycle', 0); 
    end if; 
    a_lin := wri(a_lin, ' cache ' || to_char(lv_cache_size), 0); 
    if lv_order_flag = 'Y' then 
      a_lin := wri(a_lin, ' order', 0); 
    else 
      a_lin := wri(a_lin, ' noorder', 0); 
    end if; 
    a_lin := wri(a_lin, ';', 1); 
  end loop; 
  close seq_cursor; 
end; 
