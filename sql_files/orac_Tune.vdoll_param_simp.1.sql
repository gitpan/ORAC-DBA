select NAME, nvl(VALUE, '<NULL>') 
from v$parameter 
order by name 
