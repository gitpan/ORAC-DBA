declare 
cursor user_cursor is select username, password, default_tablespace, temporary_tablespace, profile 
from sys.dba_users 
where username = 'orac_insert_user' 
order by username; 
cursor quo_cursor (c_user varchar2) is select tablespace_name, max_bytes 
from sys.dba_ts_quotas 
where username = c_user; 
lv_username sys.dba_users.username%TYPE; 
lv_password sys.dba_users.password%TYPE; 
lv_default_tbl sys.dba_users.default_tablespace%TYPE; 
lv_temp_tbl sys.dba_users.temporary_tablespace%TYPE; 
lv_profile sys.dba_users.profile%TYPE; 
lv_tablespace_name sys.dba_ts_quotas.tablespace_name%TYPE; 
lv_max_bytes sys.dba_ts_quotas.max_bytes%TYPE; 
lv_string varchar2(80); 
lv_lineno number; 
procedure write_out is 
begin 
  lv_lineno := lv_lineno + 1; 
  dbms_output.put_line(lv_string); 
end; 
begin 
  lv_lineno := 0; 
  open user_cursor; 
  loop 
    fetch user_cursor into 
    lv_username, 
    lv_password, 
    lv_default_tbl, 
    lv_temp_tbl, 
    lv_profile; 
    exit when user_cursor%NOTFOUND; 
    lv_string := 'CREATE USER '||lv_username||' identified by values '||chr(39)||lv_password||chr(39); 
    write_out; 
    lv_string := '    default tablespace '||lv_default_tbl; 
    write_out; 
    lv_string := '    temporary tablespace '||lv_temp_tbl; 
    write_out; 
    open quo_cursor(lv_username); 
    loop 
      fetch quo_cursor into lv_tablespace_name, lv_max_bytes; 
      exit when quo_cursor%NOTFOUND; 
      if lv_max_bytes = -1 then 
        lv_string := '    quota unlimited on '|| lv_tablespace_name; 
      elsif mod(lv_max_bytes, 1048576) = 0 then 
        lv_string := '    quota '|| lv_max_bytes/1048576|| 'M on '||lv_tablespace_name; 
      elsif mod(lv_max_bytes, 1024) = 0 then 
        lv_string := '    quota '||lv_max_bytes/1024|| 'K on '||lv_tablespace_name; 
      else 
        lv_string := '    quota '||lv_max_bytes|| ' on '||lv_tablespace_name; 
      end if; 
      write_out; 
    end loop; 
    close quo_cursor; 
    lv_string := '    profile '||lv_profile||';'; 
    write_out; 
  end loop; 
  close user_cursor; 
end; 
