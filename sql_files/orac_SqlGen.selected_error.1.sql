select type, sequence, line, position, text 
from   dba_errors 
where  owner = 'orac_insert_owner' and 
       name  = 'orac_insert_object' 
order by type, sequence, line 
