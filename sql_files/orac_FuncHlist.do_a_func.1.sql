declare
  cursor src_cursor is 
    select owner,name,text
    from sys.dba_source
    where type = 'FUNCTION'
    and owner = 'orac_insert_owner'
    and name = 'orac_insert_func'
    order by owner,name,line;
  lv_owner sys.dba_source.owner%TYPE;
  lv_name sys.dba_source.name%TYPE;
  lv_text sys.dba_source.text%TYPE;
  lv_lineno number;
  text_length number;
  startp number;
  xchar number;
  first_break number;
  dash_pos number;
  break_pos number;
  lf_pos number;
  semi_pos number;
  backwords number;
  new_line number;
  offset number;
  out_start number;
  out_len number;
  l number;
  bef_chars varchar2(2000);
  out_line varchar2(2000);
  a_lin varchar2(120);
  prev_owner sys.dba_source.owner%TYPE;
  prev_name sys.dba_source.name%TYPE;
  delete_object number;
  delete_name number;
function wri(x_lin in varchar2,x_str in varchar2,x_force in number) return varchar2 is
begin
  if length(x_lin) + length(x_str) > 120 then
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
  prev_owner := '@';
  prev_name := '';
  open src_cursor;
  loop
    <<fetchnext>>
    fetch src_cursor into lv_owner,lv_name,lv_text;
    exit when src_cursor%NOTFOUND;
    if prev_owner != lv_owner or prev_name != lv_name then
      if prev_owner != '@' then
        a_lin := wri(a_lin,chr(10)||'/',1);
        a_lin := wri(a_lin,
        'rem -------------------------',1);
      end if;
      a_lin := wri(a_lin,'create or replace function ',0);
      a_lin := wri(a_lin,lv_owner||'.'||lv_name,1);
      prev_owner := lv_owner;
      prev_name := lv_name;
      delete_object := 1;
      delete_name := 1;
    end if;
    if delete_object = 1 then
      break_pos := instr(upper(lv_text),'FUNCTION');
      if break_pos != 0 then
        delete_object := 0;
        if length(lv_text) < break_pos + 9 then
          goto fetchnext;
        end if;
        lv_text := substr(lv_text,break_pos + 8);
      end if;
    end if;
    if delete_name = 1 then
      break_pos := instr(upper(lv_text),upper(lv_name));
      if break_pos != 0 then
        delete_name := 0;
        if length(lv_text) < break_pos + length(lv_name) + 1 then
          goto fetchnext;
        end if;
        lv_text := substr(lv_text,break_pos + length(lv_name));
      end if;
    end if;
    break_pos := instr(lv_text,'0'||chr(2));
    if break_pos != 0 then
      lv_text := substr(lv_text,1,break_pos - 1);
    end if;
    text_length := nvl(length(lv_text),0);
    startp := 1;
    while startp <= text_length loop
      break_pos := instr(lv_text,' '||chr(9),startp);
      lf_pos := instr(lv_text,chr(10),startp);
      dash_pos := instr(lv_text,'-- ',startp);
      semi_pos := instr(lv_text,';',startp);
      if break_pos > 0 then
        bef_chars := ltrim(substr(lv_text,startp,break_pos - startp + 1));
        if bef_chars is null then
          break_pos := 0;
        end if;
      end if;
      backwords := 0; 
      new_line := 1;  
      first_break := 9999; 
      if lf_pos != 0 and lf_pos < first_break then
        first_break := lf_pos;
        offset := 1; 
      end if;
      if semi_pos != 0 and semi_pos < first_break then
        first_break := semi_pos + 1;
        offset := 0;
      end if;
      if break_pos != 0 and break_pos < first_break then
        if first_break != semi_pos + 1 or first_break - startp > 119 then
          first_break := break_pos + 1;
          offset := 1;
        end if;
      end if;
      if dash_pos != 0 and dash_pos < first_break then
        if text_length - startp > 119 then
          first_break := dash_pos;
          offset := 0;
          if dash_pos = startp then
            first_break := 9999;
          end if;
        end if;
      end if;
      if dash_pos != 0 and semi_pos != 0 and text_length - startp < 120 and first_break = semi_pos + 1 then
        first_break := 9999;
      end if;
      if first_break = 9999 then
        first_break := startp + 120;
        if break_pos > text_length then
          break_pos := text_length + 1;
        end if;
        backwords := 1;
        new_line := 0;
      end if;
      break_pos := first_break;
      if break_pos - startp > 120 then
        break_pos := startp + 119;
        if break_pos > text_length then
          break_pos := text_length + 1;
        end if;
        backwords := 1;
      end if;
      while backwords = 1 loop
        if break_pos > text_length then
          backwords := 0;
          exit;
        end if;
        if break_pos <= startp then
          break_pos := startp + 119;
          if break_pos > text_length then
            break_pos := text_length + 1;
          end if;
          backwords := 0;
          exit;
        end if;
        if substr(lv_text,break_pos,1) = ' ' then
          backwords := 0;
          exit;
        end if;
        break_pos := break_pos - 1;
      end loop;
      xchar := break_pos - startp;
      if xchar = 0 then
        if offset = 0 then
          goto fetchnext;
        end if;
      else
        out_line := replace(substr(lv_text,startp,xchar),chr(9),'   ');
        out_start := 1;
        l := length(out_line);
        if l is null then
          goto fetchnext;
        end if;
        while out_start <= l loop
          if l >= out_start + 119 then
            out_len := 120;
          else
            out_len := l - out_start + 1;
          end if;
          a_lin := wri(a_lin,substr(out_line,out_start,out_len),new_line);
          out_start := out_start + out_len;
        end loop;
      end if;
      startp := startp + xchar + offset;
    end loop;
  end loop;
  close src_cursor;
  if prev_owner != '@' then
    a_lin := wri(a_lin,chr(10)||'/',1);
  end if;
end;
