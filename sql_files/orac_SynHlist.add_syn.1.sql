select synonym_name 
from   dba_synonyms 
where  UPPER(owner) = UPPER('orac_insert_owner') 
order by synonym_name 
