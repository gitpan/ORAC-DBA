declare 
  cursor syn_cursor is 
    select owner, synonym_name, table_owner, table_name, db_link 
    from sys.dba_synonyms 
    where owner = 'orac_insert_owner' 
    and synonym_name = 'orac_insert_syn' 
    order by owner, synonym_name; 
  lv_owner sys.dba_synonyms.owner%TYPE; 
  lv_synonym_name sys.dba_synonyms.synonym_name%TYPE; 
  lv_table_owner sys.dba_synonyms.table_owner%TYPE; 
  lv_table_name sys.dba_synonyms.table_name%TYPE; 
  lv_db_link sys.dba_synonyms.db_link%TYPE; 
  lv_lineno number; 
  a_lin varchar2(80); 
function wri(x_lin in varchar2, x_str in varchar2, x_force in number) return varchar2 is 
begin 
  if length(x_lin) + length(x_str) > 80 then 
    lv_lineno := lv_lineno + 1; 
    dbms_output.put_line(x_lin); 
    if x_force = 0 then 
      return '    '||x_str; 
    else 
      lv_lineno := lv_lineno + 1; 
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
      lv_lineno := lv_lineno + 1; 
      dbms_output.put_line(x_lin||x_str); 
      return ''; 
    end if; 
  end if; 
end wri; 
begin 
  a_lin := ''; 
  lv_lineno := 0; 
  open syn_cursor; 
  loop 
    fetch syn_cursor into lv_owner, lv_synonym_name, lv_table_owner, lv_table_name, lv_db_link; 
    exit when syn_cursor%NOTFOUND; 
    if lv_owner = 'PUBLIC' then 
      a_lin := wri(a_lin, 'CREATE PUBLIC SYNONYM ', 0); 
    else 
      a_lin := wri(a_lin, 'CREATE SYNONYM '|| lv_owner || '.', 0); 
    end if; 
    a_lin := wri(a_lin, lv_synonym_name, 0); 
    a_lin := wri(a_lin, ' for ', 0); 
    if lv_db_link != ' ' then 
      a_lin := wri(a_lin, lv_table_owner || '.' || lv_table_name || '@' || lv_db_link, 0); 
    else 
      a_lin := wri(a_lin, lv_table_owner || '.' || lv_table_name, 0); 
    end if; 
    a_lin := wri(a_lin, ';', 1); 
  end loop; 
  close syn_cursor; 
  a_lin := wri(a_lin, '', 1); 
end; 
