select 'alter role '||profile||' limit '|| resource_name||' '||limit||';' 
from   sys.dba_profiles 
where  limit != 'DEFAULT' 
and    ( profile != 'DEFAULT' or limit != 'UNLIMITED') 
