select * 
from   sys.link$ 
where  UPPER(name) like UPPER('orac_insert_small_db_link%') 
