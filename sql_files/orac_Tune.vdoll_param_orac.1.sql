select NUM, TYPE, 
decode(ISDEFAULT,'TRUE','T','FALSE','F')||':'|| 
decode(ISSES_MODIFIABLE,'TRUE','T','FALSE', 'F')||':'|| 
decode(ISSYS_MODIFIABLE,'TRUE','T', 'FALSE','F','DEFERRED',
                                                  'D','IMMEDIATE','I')||':'|| 
decode(ISMODIFIED,'TRUE','T','FALSE','F')||':'|| 
decode(ISADJUSTED,'TRUE','T','FALSE','F') param_flags, 
NAME, DESCRIPTION, VALUE 
from v$parameter 
order by NAME 
