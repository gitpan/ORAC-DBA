select 'If # Shrink is low:'||chr(10)|| 
       '    If AvShr is low:'||chr(10)|| 
       '        If Avgsz Activ is much smaller than Opt Mb:'||chr(10)|| 
       '            Reduce OPTIMAL (since not many shrinks occur).'||chr(10)|| 
       '    If AvShr is high:'||chr(10)|| 
       '        Good value for OPTIMAL.'||chr(10)|| 
       'If # Shrink is high:'||chr(10)|| 
       '    If AvShr is low:'||chr(10)|| 
       '        Too many shrinks being performed, since OPTIMAL is'||chr(10)|| 
       '        somewhat (but not hugely) too small.'||chr(10)|| 
       '    If AvShr is high:'||chr(10)|| 
       '        Increase OPTIMAL until # of Shrnk decreases.  Periodic'||
       chr(10)|| 
       '        long transactions are probably causing this.'||chr(10)||
       chr(10)|| 
       'A high value in the #Ext column indicates dynamic extension, in'||
       chr(10)|| 
       'which case you should consider increasing your rollback segment'||
       chr(10)|| 
       'size.  (Also, increase it if you get a "Shapshot too old" error).'|| 
       chr(10)||chr(10)|| 
       'A high value in the # Extend and # Shrink columns indicate'||chr(10)|| 
       'allocation and deallocation of extents, due to rollback segments'|| 
       chr(10)||'with a smaller optimal size.  It also may be due to a batch'||
       chr(10) ||
       'processing transaction assigned to a smaller rollback segment.'||
       chr(10) ||
       'Consider increasing OPTIMAL.' 
from dual 
