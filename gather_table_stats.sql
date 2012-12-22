begin
  dbms_stats.gather_table_stats(
     '&owner','&table_name',
     degree => 7,
     method_opt       => '&method_opt'
   );
end;
/
