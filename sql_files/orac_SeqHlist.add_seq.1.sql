select sequence_name 
from   dba_sequences 
where  UPPER(sequence_owner) = UPPER('orac_insert_owner') 
order by sequence_name 

