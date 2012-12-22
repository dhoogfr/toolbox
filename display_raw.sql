create or replace function display_raw (rawval raw, type varchar2)
return varchar2
is
   cn     number;
   cv     varchar2(32);
   cd     date;
   cnv    nvarchar2(32);
   cr     rowid;
   cc     char(32);
begin
   if (type = 'NUMBER') then
      dbms_stats.convert_raw_value(rawval, cn);
      return to_char(cn);
   elsif (type = 'VARCHAR2') then
      dbms_stats.convert_raw_value(rawval, cv);
      return to_char(cv);
   elsif (type = 'DATE') then
      dbms_stats.convert_raw_value(rawval, cd);
      return to_char(cd);
   elsif (type = 'NVARCHAR2') then
      dbms_stats.convert_raw_value(rawval, cnv);
      return to_char(cnv);
   elsif (type = 'ROWID') then
      dbms_stats.convert_raw_value(rawval, cr);
      return to_char(cnv);
   elsif (type = 'CHAR') then
      dbms_stats.convert_raw_value(rawval, cc);
      return to_char(cc);
   else
      return 'UNKNOWN DATATYPE';
   end if;
end;
/

