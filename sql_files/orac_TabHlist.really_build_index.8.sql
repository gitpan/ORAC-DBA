select ceil(1.05 * orac_insert_n_rows * orac_insert_avg_entry_size / 
         orac_insert_space) blk 
from dual 
