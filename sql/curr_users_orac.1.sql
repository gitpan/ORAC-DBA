/* From Oracle Scripts, O Reilly and Associates, Inc. */
/* Copyright 1998 by Brian Lomasky, DBA Solutions, Inc., */
/* lomasky@earthlink.net */

select s.username,osuser,sid,
decode(status,'ACTIVE','Act','INACTIVE','Inact','KILLED','Kill',status) stat,
decode(type,'BACKGROUND','Back','USER','User',type) type,p.spid,
s.terminal,
decode(command,0,'',1,'Create Table',2,'Insert',3,'Select',4,'Create Clust',
5,'Alter Clustr',6,'Update',7,'
Delete',8,'Drop',9,'Create Index',
10,'Drop Index',11,'Alter Index',12,'Drop Table',15,'Alter Table',
17,'Grant',18,'Revoke',19,'Create Syn',20,'Drop Synonym',
21,'Create View',22,'Drop View',26,'Lock Table',27,'nop',28,'Rename',
29,'Comment',30,'Audit',31,'Noaudit',32,'Cre Ext Data',
33,'Drop Ext Dat',34,'Create Data',35,'Alter Data',36,'Cre Roll Seg',
37,'Alt Roll Seg',38,'Drp Roll Seg',39,'Cre Tablesp',40,'Alt Tablesp',
41,'Drop Tablesp',42,'Alt Session',43,'Alter User',44,'Commit',
45,'Rollback',46,'Save Point',47,'PL/SQL',to_char(command)) command,
decode(lockwait,'','','Y') lockwait
from   v$session s,v$process p
where  s.paddr = p.addr
order by type desc,username,osuser,sid
