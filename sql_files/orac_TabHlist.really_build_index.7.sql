select floor(orac_insert_avail_data_space / orac_insert_avg_entry_size) * 
       orac_insert_avg_entry_size spa 
from dual 
