select T.name, Tot_Blocks, Tot_Free, Smallest, Average, Biggest, 
       max(S.extsize * ( orac_insert_Block_Size )) Max_Ext, 
       decode(T.name,'RBS','', decode(sum(greatest(sign( 
       nvl((S.extsize * ( orac_insert_Block_Size )),0)-Biggest),0)), 0, 
       decode(sum(greatest(sign( 
       nvl((S.extsize*2 * ( orac_insert_Block_Size )),0)-Biggest),0)), 0, '', 
       'WARN  (x' || 
       to_char(sum(
           greatest(sign(nvl((S.extsize*2 * ( orac_insert_Block_Size )),0) 
       -Biggest),0) ) ) || ')' ) , 'PANIC (x' || 
       to_char(sum(greatest(sign( 
       nvl((S.extsize * 
           ( orac_insert_Block_Size )),0)-Biggest),0)))||')')) Panic 
from   sys.seg$ S, sys.ts$ T, 
             ( select ts#, 
                      max(F.LENGTH) *  orac_insert_Block_Size Biggest, 
                      min(F.LENGTH) *  orac_insert_Block_Size Smallest, 
                      round(avg(F.LENGTH) *  orac_insert_Block_Size,2) Average, 
                      count(F.LENGTH) Tot_Blocks, 
                      sum(F.LENGTH) *  orac_insert_Block_Size Tot_Free 
                      from   sys.fet$ F 
                      group by  ts# 
             ) F 
where  F.ts# = S.ts# (+) 
and    F.ts# = T.ts# 
group by  T.name, Biggest, Smallest,Average,Tot_Blocks,Tot_Free 
order by  Panic, T.name 
