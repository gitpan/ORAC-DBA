declare 
  cursor role_cursor is 
    select name, password 
    from sys.user$ 
    where type# = 0 
    and name = 'orac_insert_role' 
    order by 1; 
  lv_name sys.user$.name%TYPE; 
  lv_password sys.user$.password%TYPE; 
  lv_lineno number; 
  a_lin varchar2(80); 
function wri(x_lin in varchar2, x_str in varchar2, x_force in number) return varchar2 is 
begin 
  if length(x_lin) + length(x_str) > 80 
    then 
    lv_lineno := lv_lineno + 1; 
    dbms_output.put_line( x_lin); 
    if x_force = 0 
      then 
      return '    '||x_str; 
    else 
      lv_lineno := lv_lineno + 1; 
      if substr(x_lin,1,2) = '  ' 
        then 
        dbms_output.put_line( x_str); 
      else 
        dbms_output.put_line( '    '||x_str); 
      end if; 
      return ''; 
    end if; 
  else 
    if x_force = 0 
      then 
      return x_lin||x_str; 
    else 
      lv_lineno := lv_lineno + 1; 
      dbms_output.put_line( x_lin||x_str); 
      return ''; 
    end if; 
  end if; 
end wri; 
begin 
  a_lin := ''; 
  open role_cursor; 
  loop 
    fetch role_cursor into lv_name, lv_password; 
    exit when role_cursor%NOTFOUND; 
    a_lin := wri(a_lin, 'CREATE ROLE ', 0); 
    a_lin := wri(a_lin, lv_name, 0); 
    if nvl(lv_password, 'NO') = 'NO' then 
      a_lin := wri(a_lin, ' not identified;', 1); 
    elsif lv_password = 'EXTERNAL' then 
      a_lin := wri(a_lin, ' identified externally;', 1); 
    else 
      a_lin := wri(a_lin, ' identified by values ', 0); 
      a_lin := wri(a_lin, chr(39) || lv_password || chr(39) || ';', 1); 
    end if; 
  end loop; 
  close role_cursor; 
end; 
