SELECT granted_role 
FROM dba_role_privs 
WHERE grantee = UPPER('orac_insert_user_role') 
ORDER BY 1 
