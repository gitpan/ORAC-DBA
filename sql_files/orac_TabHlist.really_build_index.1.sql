declare
  type t_id_this_build is table of varchar2(50) index by binary_integer;
  v_this_build t_id_this_build;
  v_this_counter number;
  total_size   number;
  cursor c2 (coln in char) is
  select data_type, data_length
  from dba_tab_columns
  where owner = 'orac_insert_ind_owner' and
  table_name = 'orac_insert_ind_table' and
  column_name = coln;
begin
  total_size := 2 + 6;

