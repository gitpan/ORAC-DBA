select 'alter '||object_type||' '||owner||'.' ||
       object_name||' compile ;' the_stuff 
from   dba_objects 
where  status = 'INVALID' 
and    object_type not in ('PACKAGE BODY', 'PACKAGE') 
union 
select 'alter PACKAGE '||owner||'.' ||object_name||
       ' compile BODY ;' the_other_stuff 
from   dba_objects 
where  status = 'INVALID' 
and    object_type in ('PACKAGE BODY') 
order by 1 
