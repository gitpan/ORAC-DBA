select distinct grantee from dba_tab_privs 
where grantee in (select role from dba_roles) 
union 
select distinct grantee from dba_sys_privs 
where grantee in (select role from dba_roles) 
union 
select distinct grantee from dba_role_privs 
where grantee in (select role from dba_roles) 
union 
select distinct grantee from dba_col_privs 
where grantee in (select role from dba_roles) 
order by 1 
