declare 
  cursor obj_cursor is 
    select grantee,owner,table_name,privilege,decode(grantable,'YES',' WITH GRANT OPTION;',';') 
    from sys.dba_tab_privs 
    where grantee = 'orac_insert_grantee' 
    order by 2,3,1,4; 
cursor col_cursor is 
    select grantee,owner,table_name,column_name,privilege,decode(grantable,'YES',' WITH GRANT OPTION;',';') 
    from sys.dba_col_privs 
    where grantee = 'orac_insert_grantee' 
    order by 2,3,4,5,1; 
cursor sys_cursor is 
    select grantee,privilege,decode(admin_option,'YES',' WITH ADMIN OPTION;',';') 
    from sys.dba_sys_privs 
    where grantee = 'orac_insert_grantee' 
    order by 1,2; 
cursor role_cursor is 
    select grantee,granted_role,decode(admin_option,'YES',' WITH ADMIN OPTION;',';') 
    from sys.dba_role_privs 
    where grantee = 'orac_insert_grantee' 
    order by 1,2; 
cursor pwd_cursor (c_user varchar2) is 
    select password from sys.dba_users where username = c_user; 
  lv_grantee sys.dba_tab_privs.grantee%TYPE; 
  lv_owner sys.dba_tab_privs.owner%TYPE; 
  lv_table_name sys.dba_tab_privs.table_name%TYPE; 
  lv_column_name sys.dba_col_privs.column_name%TYPE; 
  lv_privilege sys.dba_tab_privs.privilege%TYPE; 
  lv_granted_role sys.dba_role_privs.granted_role%TYPE; 
  lv_grantable varchar2(19); 
  lv_string varchar2(80); 
  lv_lineno number; 
  a_lin varchar2(80); 
  prev_grantee sys.dba_tab_privs.grantee%TYPE; 
  prev_own sys.dba_tab_privs.owner%TYPE; 
  alter_user sys.dba_tab_privs.owner%TYPE; 
  prev_owner sys.dba_tab_privs.owner%TYPE; 
  prev_table_name sys.dba_tab_privs.table_name%TYPE; 
  prev_column_name sys.dba_col_privs.column_name%TYPE; 
  prev_grantable varchar2(19); 
  privs varchar2(100); 
  user_password sys.dba_users.password%TYPE; 
  connect_pwd varchar2(10); 
function wri(x_lin in varchar2,x_str in varchar2,x_force in number) return varchar2 is 
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
  prev_grantee := '@'; 
  prev_own := '@'; 
  prev_owner := ''; 
  prev_table_name := ''; 
  prev_grantable := ''; 
  privs := ''; 
  a_lin := wri(a_lin,'rem *** Object Privileges ***',1); 
  a_lin := ''; 
  open obj_cursor; 
  loop 
    fetch obj_cursor into lv_grantee,lv_owner,lv_table_name,lv_privilege,lv_grantable; 
    exit when obj_cursor%NOTFOUND; 
    if prev_grantee = lv_grantee and prev_owner = lv_owner and 
       prev_table_name = lv_table_name and 
       prev_grantable = lv_grantable then 
      if instr(privs,lv_privilege) = 0 then 
        a_lin := wri(a_lin,','||lv_privilege,0); 
        privs := privs||lv_privilege; 
      end if; 
    else 
      if prev_grantee != '@' then 
        a_lin := wri(a_lin,' ON',0); 
        a_lin := wri(a_lin,' '||prev_owner||'.'||prev_table_name,0); 
        a_lin := wri(a_lin,' TO',0); 
        a_lin := wri(a_lin,' '||prev_grantee,0); 
        a_lin := wri(a_lin,prev_grantable,1); 
      end if; 
      if lv_owner != prev_own then 
        if prev_own != '@' then 
          a_lin := wri(a_lin,'rem connect system/xyzzy',1); 
          if user_password != '<password>' then 
            a_lin := wri(a_lin,'alter user '||lower(prev_own)||' identified by'||' values '||chr(39)||user_password||chr(39)||';',1); 
          else 
            a_lin := wri(a_lin,'alter user '||lower(prev_own)||' identified by'||' <password>;',1); 
          end if; 
        end if; 
        open pwd_cursor(lv_owner); 
        fetch pwd_cursor into user_password; 
        if pwd_cursor%NOTFOUND then 
          user_password := '<password>'; 
          dbms_output.put_line( '*****> Warning:  Username '||lv_owner||' not found in DBA_USERS!!'); 
        end if; 
        close pwd_cursor; 
        a_lin := wri(a_lin,' ',1); 
        a_lin := wri(a_lin,'rem ----------------------------',1); 
        a_lin := wri(a_lin,' ',1); 
        alter_user := lower(lv_owner); 
        if user_password = '<password>' then 
          connect_pwd := user_password; 
          a_lin := wri(a_lin,'alter user '||alter_user||' identified by <password>;',1); 
        else 
          connect_pwd := 'xyzzy'; 
          a_lin := wri(a_lin,'alter user '||alter_user||' identified by xyzzy;',1); 
        end if; 
        a_lin := wri(a_lin,'connect '||alter_user||'/'||connect_pwd,1); 
        prev_own := lv_owner; 
      end if; 
      a_lin := wri(a_lin,'GRANT ',0); 
      a_lin := wri(a_lin,lv_privilege,0); 
      prev_grantee := lv_grantee; 
      prev_owner := lv_owner; 
      prev_table_name := lv_table_name; 
      prev_grantable := lv_grantable; 
      privs := lv_privilege; 
    end if; 
  end loop; 
  close obj_cursor; 
  if prev_grantee != '@' then 
    a_lin := wri(a_lin,' ON',0); 
    a_lin := wri(a_lin,' '||prev_owner||'.'||prev_table_name,0); 
    a_lin := wri(a_lin,' TO',0); 
    a_lin := wri(a_lin,' '||prev_grantee,0); 
    a_lin := wri(a_lin,prev_grantable,1); 
  end if; 
  if prev_own != '@' then 
    a_lin := wri(a_lin,'connect system/xyzzy',1); 
    if user_password != '<password>' then 
      a_lin := wri(a_lin,'alter user '||lower(prev_own)||' identified by values '||chr(39)||user_password||chr(39)||';',1); 
    else 
      a_lin := wri(a_lin,'alter user '||lower(prev_own)||' identified by <password>;',1); 
    end if; 
  end if; 
  a_lin := wri(a_lin,'rem *** Column Privileges ***',1); 
  a_lin := ''; 
  prev_grantee := '@'; 
  prev_own := '@'; 
  prev_owner := ''; 
  prev_table_name := ''; 
  prev_column_name := ''; 
  prev_grantable := ''; 
  privs := ''; 
  open col_cursor; 
  loop 
    fetch col_cursor into lv_grantee,lv_owner,lv_table_name,lv_column_name,lv_privilege,lv_grantable; 
    exit when col_cursor%NOTFOUND; 
    if prev_grantee = lv_grantee and prev_owner = lv_owner and 
       prev_table_name = lv_table_name and 
       prev_column_name = lv_column_name and 
       prev_grantable = lv_grantable then 
      if instr(privs,lv_privilege) = 0 then 
        a_lin := wri(a_lin,', '||lv_privilege,0); 
        privs := privs||lv_privilege; 
      end if; 
    else 
      if prev_grantee != '@' then 
        a_lin := wri(a_lin,' ON',0); 
        a_lin := wri(a_lin,' '||prev_owner||'.'||prev_table_name,0); 
        a_lin := wri(a_lin,' TO',0); 
        a_lin := wri(a_lin,' '||prev_grantee,0); 
        a_lin := wri(a_lin,prev_grantable,1); 
      end if; 
      if lv_owner != prev_own then 
        if prev_own != '@' then 
          a_lin := wri(a_lin,'connect system/xyzzy',1); 
          if user_password != '<password>' then 
            a_lin := wri(a_lin,'alter user '||lower(prev_own)||' identified by'||' values '||chr(39)||user_password||chr(39)||';',1); 
          else 
            a_lin := wri(a_lin,'alter user '||lower(prev_own)||' identified by'||' <password>;',1); 
          end if; 
        end if; 
        open pwd_cursor(lv_owner); 
        fetch pwd_cursor into user_password; 
        if pwd_cursor%NOTFOUND then 
          user_password := '<password>'; 
          dbms_output.put_line( '*****> Warning:  Username '||lv_owner||' not found in DBA_USERS!!'); 
        end if; 
        close pwd_cursor; 
        a_lin := wri(a_lin,' ',1); 
        a_lin := wri(a_lin,'rem ----------------------------',1); 
        a_lin := wri(a_lin,' ',1); 
        alter_user := lower(lv_owner); 
        if user_password = '<password>' then 
          connect_pwd := user_password; 
          a_lin := wri(a_lin,'alter user '||alter_user||' identified by <password>;',1); 
        else 
          connect_pwd := 'xyzzy'; 
          a_lin := wri(a_lin,'alter user '||alter_user||' identified by xyzzy;',1); 
          end if; 
        a_lin := wri(a_lin,'connect '||alter_user||'/'||connect_pwd,1); 
        prev_own := lv_owner; 
      end if; 
      a_lin := wri(a_lin,'GRANT ',0); 
      a_lin := wri(a_lin,lv_privilege,0); 
      a_lin := wri(a_lin,' ('||lv_column_name||')',0); 
      prev_grantee := lv_grantee; 
      prev_owner := lv_owner; 
      prev_table_name := lv_table_name; 
      prev_column_name := lv_column_name; 
      prev_grantable := lv_grantable; 
      privs := lv_privilege; 
    end if; 
  end loop; 
  close col_cursor; 
  if prev_grantee != '@' then 
    a_lin := wri(a_lin,' ON',0); 
    a_lin := wri(a_lin,' '||prev_owner||'.'||prev_table_name,0); 
    a_lin := wri(a_lin,' TO',0); 
    a_lin := wri(a_lin,' '||prev_grantee,0); 
    a_lin := wri(a_lin,prev_grantable,1); 
  end if; 
  if prev_own != '@' then 
    a_lin := wri(a_lin,'connect system/xyzzy',1); 
    if user_password != '<password>' then 
      a_lin := wri(a_lin,'alter user '||lower(prev_own)||' identified by values '||chr(39)||user_password||chr(39)||';',1); 
    else 
      a_lin := wri(a_lin,'alter user '||lower(prev_own)||' identified by <password>;',1); 
    end if; 
  end if; 
  a_lin := wri(a_lin,'rem *** System Privileges ***',1); 
  a_lin := ''; 
  a_lin := wri(a_lin,'connect system/xyzzy',1); 
  prev_grantee := '@'; 
  prev_grantable := ''; 
  open sys_cursor; 
  loop 
    fetch sys_cursor into lv_grantee,lv_privilege,lv_grantable; 
    exit when sys_cursor%NOTFOUND; 
    if prev_grantee = lv_grantee and prev_grantable = lv_grantable then 
      a_lin := wri(a_lin,', '||lv_privilege,0); 
    else 
      if prev_grantee != '@' then 
        a_lin := wri(a_lin,' TO',0); 
        a_lin := wri(a_lin,' '||prev_grantee,0); 
        a_lin := wri(a_lin,prev_grantable,1); 
      end if; 
      a_lin := wri(a_lin,'GRANT ',0); 
      a_lin := wri(a_lin,lv_privilege,0); 
      prev_grantee := lv_grantee; 
      prev_grantable := lv_grantable; 
    end if; 
  end loop; 
  close sys_cursor; 
  if prev_grantee != '@' then 
    a_lin := wri(a_lin,' TO',0); 
    a_lin := wri(a_lin,' '||prev_grantee,0); 
    a_lin := wri(a_lin,prev_grantable,1); 
  end if; 
  a_lin := wri(a_lin,'rem *** Role Privileges ***',1); 
  a_lin := ''; 
  prev_grantee := '@'; 
  prev_grantable := ''; 
  open role_cursor; 
  loop 
    fetch role_cursor into lv_grantee,lv_granted_role,lv_grantable; 
    exit when role_cursor%NOTFOUND; 
    if prev_grantee = lv_grantee and prev_grantable = lv_grantable then 
      a_lin := wri(a_lin,', '||lv_granted_role,0); 
    else 
      if prev_grantee != '@' then 
        a_lin := wri(a_lin,' TO',0); 
        a_lin := wri(a_lin,' '||prev_grantee,0); 
        a_lin := wri(a_lin,prev_grantable,1); 
      end if; 
      a_lin := wri(a_lin,'GRANT ',0); 
      a_lin := wri(a_lin,lv_granted_role,0); 
      prev_grantee := lv_grantee; 
      prev_grantable := lv_grantable; 
    end if; 
  end loop; 
  close role_cursor; 
  if prev_grantee != '@' then 
    a_lin := wri(a_lin,' TO',0); 
    a_lin := wri(a_lin,' '||prev_grantee,0); 
    a_lin := wri(a_lin,prev_grantable,1); 
  end if; 
end; 
