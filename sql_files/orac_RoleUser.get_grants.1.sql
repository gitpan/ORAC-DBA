SELECT 'Column' lvl, c.privilege, 
       c.grantable, c.owner, c.table_name, 
       c.column_name 
FROM   dba_col_privs c 
WHERE  c.grantee = UPPER('orac_insert_user_role')  
AND    c.owner != 'SYS' 
UNION 
SELECT 'Role' Gr_Type, r.granted_role obj, 
       r.admin_option a, NULL, NULL, NULL 
FROM   dba_role_privs r 
WHERE  r.grantee = UPPER('orac_insert_user_role') 
UNION 
SELECT 'Sys Priv', s.privilege, s.admin_option, NULL, NULL, NULL 
FROM   dba_sys_privs s 
WHERE  s.grantee = UPPER('orac_insert_user_role') 
UNION 
SELECT 'Table', t.privilege, t.grantable, 
       t.owner, t.table_name, NULL 
FROM   dba_tab_privs t 
WHERE  t.grantee = UPPER('orac_insert_user_role')  
AND    t.privilege != 'EXECUTE' AND 
       t.owner != 'SYS' 
UNION 
SELECT 'Program', e.privilege, e.grantable, 
       e.owner, e.table_name, NULL 
FROM   dba_tab_privs e 
WHERE  e.grantee = UPPER('orac_insert_user_role')  
AND    e.privilege = 'EXECUTE' AND 
       e.owner != 'SYS' 
ORDER BY 1, 2, 3, 4, 5, 6 
