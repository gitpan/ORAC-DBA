select decode(x.online$,1,x.name, 
       substr(rpad(x.name,14),1,14)||' OFF') T_Space, 
       replace(replace (A.file_name,'/databases/',''),'.dbf','') Fname, 
       round((f.blocks * orac_insert_Block_Size )/(1024*1024), 2) Total, 
       round(sum(s.length * orac_insert_Block_Size )/(1024*1024),2) Used_Mg, 
       round(((f.blocks * orac_insert_Block_Size )/(1024*1024)) - 
       nvl(sum (s.length * orac_insert_Block_Size )/(1024*1024),0), 2) Free_Mg, 
       round( sum(s.length * orac_insert_Block_Size )/(1024*1024) /
       ((f.blocks * orac_insert_Block_Size )/(1024*1024)) * 100, 2) Use_Pct 
from   sys.dba_data_files A, sys.uet$ s, sys.file$ f, sys.ts$ X 
where  x.ts#      = f.ts# 
and    x.online$ in (1,2) 
and    f.status$  = 2 
and    f.ts# = s.ts# (+) 
and    f.file# = s.file# (+) 
and    f.file# = a.file_id 
group by x.name, x.online$, f.blocks, A.file_name 
order by T_Space, Fname 
