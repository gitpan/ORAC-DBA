SELECT 'Column' lvl, c.privilege, c.grantable, c.owner, c.table_name 
FROM   dba_col_privs c 
UNION 
SELECT 'Role' Gr_Type, r.granted_role obj, r.admin_option a, NULL, NULL 
FROM   dba_role_privs r 
UNION 
SELECT 'Sys Priv', s.privilege, s.admin_option, NULL, NULL 
FROM   dba_sys_privs s 
UNION 
SELECT 'Table', t.privilege, t.grantable, t.owner, t.table_name 
FROM   dba_tab_privs t 
ORDER BY 1, 2, 3, 4, 5 
