select nvl(s.osuser,s.type) os_usercode, 
s.username Oracle_Usercode, 
s.serial# Ora_Serial, 
s.sid Oracle_Sid, 
s.process F_ground, 
P.spid B_Ground 
from v$session s, v$process P 
where s.paddr = p.addr 
order by s.sid 
