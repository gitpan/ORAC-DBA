declare 
  cursor link_cursor is 
    select u.name, l.name, l.userid, l.password, l.host 
    from sys.link$ l, sys.user$ u 
    where l.name = 'orac_insert_link' 
    and l.owner# = u.user# 
    and u.name = 'orac_insert_owner' 
    order by u.name, l.name; 
  cursor pwd_cursor (c_user varchar2) is 
    select password from sys.dba_users where username = c_user; 
  alter_user sys.user$.name%TYPE; 
  prev_owner sys.user$.name%TYPE; 
  lv_owner sys.user$.name%TYPE; 
  lv_db_link sys.link$.name%TYPE; 
  lv_username sys.link$.userid%TYPE; 
  lv_password sys.link$.password%TYPE; 
  lv_host sys.link$.host%TYPE; 
  user_password sys.dba_users.password%TYPE; 
  connect_pwd varchar2(10); 
  a_lin varchar2(80); 
  lv_lineno number; 
function wri(x_lin in varchar2, x_str in varchar2, x_force in number) return varchar2 is 
begin 
  if length(x_lin) + length(x_str) > 80 then 
    lv_lineno := lv_lineno + 1; 
    dbms_output.put_line( x_lin); 
    if x_force = 0 then 
      return '    '||x_str; 
    else 
      lv_lineno := lv_lineno + 1; 
      if substr(x_lin,1,2) = '  ' then 
        dbms_output.put_line( x_str); 
      else 
        dbms_output.put_line( '    '||x_str); 
      end if; 
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
  lv_lineno := 0; 
  a_lin := ''; 
  prev_owner := '@'; 
  open link_cursor; 
  loop 
    fetch link_cursor into lv_owner, lv_db_link, lv_username, lv_password, lv_host; 
    exit when link_cursor%NOTFOUND; 
    if lv_owner != prev_owner then 
      if prev_owner != '@' then 
        a_lin := wri(a_lin, ' ', 1); 
        if user_password != '<password>' then 
          a_lin := wri(a_lin, 'alter user '|| lower(prev_owner)|| ' identified by values '||chr(39)|| user_password||chr(39)||';', 1); 
        else 
          a_lin := wri(a_lin, 'alter user '|| lower(prev_owner)|| ' identified by <password>;', 1); 
        end if; 
      end if; 
      if lv_owner = 'PUBLIC' then 
        open pwd_cursor('SYSTEM'); 
        fetch pwd_cursor into user_password; 
        if pwd_cursor%NOTFOUND then 
          user_password := '<password>'; 
          dbms_output.put_line( '*****> Warning:  Username '|| 'SYSTEM'|| ' not found in DBA_USERS!!'); 
        end if; 
      else 
        open pwd_cursor(lv_owner); 
        fetch pwd_cursor into user_password; 
        if pwd_cursor%NOTFOUND then 
          user_password := '<password>'; 
          dbms_output.put_line( '*****> Warning:  Username '|| lv_owner|| ' not found in DBA_USERS!!'); 
        end if; 
      end if; 
      close pwd_cursor; 
      a_lin := wri(a_lin, ' ', 1); 
      a_lin := wri(a_lin, 'rem ----- Please Protect this Output !!! -----', 1); 
      a_lin := wri(a_lin, ' ', 1); 
      if lv_owner = 'PUBLIC' then 
        alter_user := 'system'; 
      else 
        alter_user := lower(lv_owner); 
      end if; 
      if user_password = '<password>' then 
        connect_pwd := user_password; 
        a_lin := wri(a_lin, 'alter user '||alter_user|| ' identified by <password>;', 1); 
      else 
        connect_pwd := 'xyzzy'; 
        a_lin := wri(a_lin, 'alter user '||alter_user|| ' identified by xyzzy;', 1); 
      end if; 
      a_lin := wri(a_lin, 'connect '||alter_user||'/'|| connect_pwd, 1); 
      if lv_owner = 'PUBLIC' then 
        prev_owner := 'system'; 
      else 
        prev_owner := lv_owner; 
      end if; 
    end if; 
    if lv_owner = 'PUBLIC' then 
      a_lin := wri(a_lin, 'CREATE PUBLIC DATABASE LINK '|| lv_db_link, 1); 
    else 
      a_lin := wri(a_lin, 'CREATE DATABASE LINK '|| lv_db_link, 1); 
    end if; 
    a_lin := wri(a_lin, '    ', 0); 
    if lv_username != ' ' then 
      a_lin := wri(a_lin, ' connect to '||lv_username ||' identified by '||lv_password, 0); 
    end if; 
    if lv_host != ' ' then 
      a_lin := wri(a_lin, ' using '||chr(39)||lv_host||chr(39), 0); 
    end if; 
    a_lin := wri(a_lin, ';', 1); 
  end loop; 
  close link_cursor; 
  if prev_owner != '@' then 
    a_lin := wri(a_lin, ' ', 1); 
    if user_password != '<password>' then 
      a_lin := wri(a_lin, 'alter user '||lower(prev_owner)|| ' identified by values '||chr(39)||user_password|| chr(39)||';', 1); 
    else 
      a_lin := wri(a_lin, 'alter user '||lower(prev_owner)|| 
      ' identified by <password>;', 1); 
    end if; 
  end if; 
  a_lin := wri(a_lin, 'exit', 1); 
end; 
