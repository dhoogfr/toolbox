set sqlblanklines on
set feedback off
accept owner -
 prompt 'Enter Value for owner: ' -
 default 'KSO'
accept table_name -
 prompt 'Enter Value for table_name: ' -
 default 'SKEW'
accept comp_type -
 prompt 'Enter Value for compression_type (OLTP): ' -
 default 'OLTP'

DECLARE

   l_blkcnt_cmp     BINARY_INTEGER;
   l_blkcnt_uncmp   BINARY_INTEGER;
   l_row_cmp         BINARY_INTEGER;
   l_row_uncmp      BINARY_INTEGER;
   l_cmp_ratio       NUMBER;
   l_comptype_str   VARCHAR2 (200);
   l_comptype    number;
BEGIN

case '&&comp_type'
            when 'OLTP' then l_comptype := DBMS_COMPRESSION.comp_for_oltp;
            when 'QUERY' then l_comptype := DBMS_COMPRESSION.comp_for_query_low;
            when 'QUERY_LOW' then l_comptype := DBMS_COMPRESSION.comp_for_query_low;
            when 'QUERY_HIGH' then l_comptype := DBMS_COMPRESSION.comp_for_query_high;
            when 'ARCHIVE' then l_comptype := DBMS_COMPRESSION.comp_for_archive_low;
            when 'ARCHIVE_LOW' then l_comptype := DBMS_COMPRESSION.comp_for_archive_low;
            when 'ARCHIVE_HIGH' then l_comptype := DBMS_COMPRESSION.comp_for_archive_high;
          END CASE;

   DBMS_COMPRESSION.get_compression_ratio (
      scratchtbsname   => 'USERS',
      ownname           => '&owner',
      tabname            => '&table_name',
      partname           => NULL,
      comptype           => l_comptype,
--      comptype           => DBMS_COMPRESSION.comp_for_oltp,
--      comptype           => DBMS_COMPRESSION.comp_for_query_low,
--      comptype           => DBMS_COMPRESSION.comp_for_query_high,
--      comptype           => DBMS_COMPRESSION.comp_for_archive_low,
--      comptype           => DBMS_COMPRESSION.comp_for_archive_high,
      blkcnt_cmp        => l_blkcnt_cmp,
      blkcnt_uncmp     => l_blkcnt_uncmp,
      row_cmp            => l_row_cmp,
      row_uncmp        => l_row_uncmp,
      cmp_ratio          => l_cmp_ratio,
      comptype_str      => l_comptype_str
   );
/*
   DBMS_OUTPUT.put_line ('DBMS_COMPRESSION.comp_for_oltp=' || DBMS_COMPRESSION.comp_for_oltp);
   DBMS_OUTPUT.put_line ('l_blkcnt_cmp=' || l_blkcnt_cmp);
   DBMS_OUTPUT.put_line ('l_blkcnt_uncmp=' || l_blkcnt_uncmp);
   DBMS_OUTPUT.put_line ('l_row_cmp=' || l_row_cmp);
   DBMS_OUTPUT.put_line ('l_row_uncmp=' || l_row_uncmp);
   DBMS_OUTPUT.put_line ('l_comptype_str=' || l_comptype_str);
*/
dbms_output.put_line(' ');
   DBMS_OUTPUT.put_line ('Estimated Compression Ratio using '||l_comptype_str||': '|| round(l_cmp_ratio,3));
dbms_output.put_line(' ');

END;
/
undef owner
undef table_name
undef comp_type
set feedback on
