select floor((orac_insert_blk_size - 113 - 
(23 * orac_insert_initrans)) * (1-(orac_insert_pct_free/100))) ads 
from dual 
