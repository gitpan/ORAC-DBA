select count(distinct(substr(rowid,15,4)||substr(rowid,1,8))) 
from orac_insert_owner.orac_insert_table 
