 select 'create role '|| role || 
 decode(password_required,'N',' not identified ;', ' identified externally ;') 
 from sys.dba_roles 
