SELECT 'Role' lvl, t.owner, t.table_name, t.grantee, t.privilege 
FROM   dba_tab_privs t 
WHERE  t.grantee IN 
       (SELECT role 
        FROM   dba_roles 
        WHERE  role = t.grantee) 
UNION 
SELECT 'User' lvl, t.owner, t.table_name, t.grantee, t.privilege 
FROM   dba_tab_privs t 
WHERE  t.grantee IN 
       (SELECT username 
        FROM   dba_users 
        WHERE  username = t.grantee) 
UNION 
SELECT 'Pub' lvl, t.owner, t.table_name, t.grantee, t.privilege 
FROM   dba_tab_privs t 
WHERE  t.grantee = 'PUBLIC' 
ORDER BY 1, 2, 3 
