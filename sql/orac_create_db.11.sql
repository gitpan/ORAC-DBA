select '   CHARACTER SET  '||value from nls_database_parameters where parameter = 'NLS_CHARACTERSET'
union
select '   MAXLOGFILES    '||max(group#)*max(members)*4 from sys.v_$log
union
select '   MAXLOGMEMBERS  '||max(members) * 2 from sys.v_$log
