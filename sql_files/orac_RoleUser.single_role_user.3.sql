SELECT granted_role 
FROM dba_role_privs 
WHERE grantee = 'PUBLIC' and 
      UPPER('orac_insert_user_role') <> 'PUBLIC' 
ORDER BY 1 
