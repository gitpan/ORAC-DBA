select substr(t.rowid,1,8)||'-'||substr(t.rowid,15,4) block, 
       count(*) 
from   orac_insert_owner.orac_insert_table t 
where  rownum < 2000 
group by substr(t.rowid,1,8)||'-'||substr(t.rowid,15,4) 
