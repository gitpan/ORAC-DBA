SELECT DISTINCT t.owner, t.table_name, t.privilege, r.granted_role, 
       decode(r.admin_option, 'Y', 'Y', ' ') adm 
FROM   dba_tab_privs t, dba_role_privs r 
WHERE  t.grantee IN 
       (SELECT granted_role FROM dba_role_privs  
        WHERE  grantee = UPPER('orac_insert_user_role') 
        UNION 
        SELECT granted_role 
        FROM   dba_role_privs 
        WHERE  grantee = 'PUBLIC' 
        UNION 
        SELECT granted_role 
        FROM   dba_role_privs 
        WHERE  grantee IN 
               (SELECT granted_role 
                FROM   dba_role_privs  
                WHERE  grantee = UPPER('orac_insert_user_role'))) 
AND    t.grantee = r.granted_role 
AND    t.owner NOT IN ('SYSTEM', 'SYS') 
UNION 
SELECT owner, table_name, privilege, 'Direct to User', 
       decode(grantable, 'YES', 'Y', ' ') 
FROM   dba_tab_privs 
WHERE  grantee = UPPER('orac_insert_user_role')  
AND    owner NOT IN ('SYSTEM', 'SYS') 
UNION 
SELECT owner, table_name, privilege, 'Public', 
       decode(grantable, 'YES', 'Y', ' ') 
FROM   dba_tab_privs 
WHERE  grantee = 'PUBLIC' AND owner NOT IN ('SYSTEM', 'SYS') 
UNION 
SELECT owner, table_name, privilege, 'Column Security', 
       decode(grantable, 'YES', 'Y', ' ') 
FROM   dba_col_privs 
WHERE  grantee = UPPER('orac_insert_user_role') 
UNION 
SELECT DISTINCT c.owner, c.table_name, '(Column)', r.granted_role, 
       decode(r.admin_option, 'Y', 'Y', ' ') 
FROM   dba_col_privs c, dba_role_privs r 
WHERE  c.grantee IN 
       (SELECT granted_role 
        FROM dba_role_privs  
        WHERE grantee = UPPER('orac_insert_user_role') 
        UNION 
        SELECT granted_role 
        FROM   dba_role_privs 
        WHERE  grantee = 'PUBLIC' 
        UNION 
        SELECT granted_role 
        FROM   dba_role_privs 
        WHERE  grantee IN 
               (SELECT granted_role 
                FROM dba_role_privs  
                WHERE grantee = UPPER('orac_insert_user_role'))) 
AND    c.grantee = r.granted_role 
AND    c.owner NOT IN ('SYSTEM', 'SYS') 
UNION 
SELECT DISTINCT owner, table_name, '(Column)', '(Public)', 
       decode(grantable, 'YES', 'Y', ' ') 
FROM   dba_col_privs 
WHERE  grantee = 'PUBLIC'  
ORDER BY 2, 1, 3 
