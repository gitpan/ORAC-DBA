select 'rem ----- Please protect this output carefully!!!-----' || chr(10) || 
       'alter USER ' || username || ' identified by values ''' || 
       password || ''';' 
from   sys.dba_users 
where  username not in ('SYSTEM','SYS','_NEXT_USER','PUBLIC') 
and    password != 'EXTERNAL' 
