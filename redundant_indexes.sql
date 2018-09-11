set linesize 165
set pagesize 54
set feedback off
set trimspool on
spool RedundantIndex.lst

COLUMN table_owner      FORMAT a10               HEADING  'Table|Owner'
COLUMN table_name       FORMAT a30 word_wrapped  HEADING  'Table Name'
COLUMN index_name       FORMAT a30 word_wrapped  HEADING  'Index Name'
COLUMN index_cols       FORMAT a30 word_wrapped  HEADING  'Index Columns'
column redun_index      FORMAT a30 word_wrapped  HEADING  'Redundant Index'
COLUMN redun_cols       FORMAT a30 word_wrapped  HEADING  'Redundant Columns'

clear breaks

break on owner           skip 0

TTITLE -
       center 'Redundant Index Analysis'  skip 1 -
       center '~~~~~~~~~~~~~~~~~~~~~~~~'  skip 2

SELECT ai.table_owner  table_owner,
       ai.table_name   table_name,
       ai.index_name   index_name,
       ai.columns      index_cols,
       bi.index_name   redun_index,
       bi.columns      redun_cols
FROM 
( SELECT a.table_owner,
         a.table_name, 
         a.index_name, 
             MAX(DECODE(column_position, 1,
SUBSTR(column_name,1,30),NULL)) || 
             MAX(DECODE(column_position, 2,',
'||SUBSTR(column_name,1,30),NULL)) || 
             MAX(DECODE(column_position, 3,',
'||SUBSTR(column_name,1,30),NULL)) || 
             MAX(DECODE(column_position, 4,',
'||SUBSTR(column_name,1,30),NULL)) || 
             MAX(DECODE(column_position, 5,',
'||SUBSTR(column_name,1,30),NULL)) || 
             MAX(DECODE(column_position, 6,',
'||SUBSTR(column_name,1,30),NULL)) || 
             MAX(DECODE(column_position, 7,',
'||SUBSTR(column_name,1,30),NULL)) || 
             MAX(DECODE(column_position, 8,',
'||SUBSTR(column_name,1,30),NULL)) || 
             MAX(DECODE(column_position, 9,',
'||SUBSTR(column_name,1,30),NULL)) || 
             MAX(DECODE(column_position,10,',
'||SUBSTR(column_name,1,30),NULL)) || 
             MAX(DECODE(column_position,11,',
'||SUBSTR(column_name,1,30),NULL)) || 
             MAX(DECODE(column_position,12,',
'||SUBSTR(column_name,1,30),NULL)) || 
             MAX(DECODE(column_position,13,',
'||SUBSTR(column_name,1,30),NULL)) || 
             MAX(DECODE(column_position,14,',
'||SUBSTR(column_name,1,30),NULL)) || 
             MAX(DECODE(column_position,15,',
'||SUBSTR(column_name,1,30),NULL)) || 
             MAX(DECODE(column_position,16,',
'||SUBSTR(column_name,1,30),NULL)) columns
    FROM dba_ind_columns a
   WHERE a.index_owner not in ('SYS','SYSTEM')
   GROUP BY a.table_owner,
            a.table_name,
            a.index_owner,
            a.index_name) ai, 
( SELECT b.table_owner,
         b.table_name,
         b.index_name, 
             MAX(DECODE(column_position, 1,
SUBSTR(column_name,1,30),NULL)) || 
             MAX(DECODE(column_position, 2,',
'||SUBSTR(column_name,1,30),NULL)) || 
             MAX(DECODE(column_position, 3,',
'||SUBSTR(column_name,1,30),NULL)) || 
             MAX(DECODE(column_position, 4,',
'||SUBSTR(column_name,1,30),NULL)) || 
             MAX(DECODE(column_position, 5,',
'||SUBSTR(column_name,1,30),NULL)) || 
             MAX(DECODE(column_position, 6,',
'||SUBSTR(column_name,1,30),NULL)) || 
             MAX(DECODE(column_position, 7,',
'||SUBSTR(column_name,1,30),NULL)) || 
             MAX(DECODE(column_position, 8,',
'||SUBSTR(column_name,1,30),NULL)) || 
             MAX(DECODE(column_position, 9,',
'||SUBSTR(column_name,1,30),NULL)) || 
             MAX(DECODE(column_position,10,',
'||SUBSTR(column_name,1,30),NULL)) || 
             MAX(DECODE(column_position,11,',
'||SUBSTR(column_name,1,30),NULL)) || 
             MAX(DECODE(column_position,12,',
'||SUBSTR(column_name,1,30),NULL)) || 
             MAX(DECODE(column_position,13,',
'||SUBSTR(column_name,1,30),NULL)) || 
             MAX(DECODE(column_position,14,',
'||SUBSTR(column_name,1,30),NULL)) || 
             MAX(DECODE(column_position,15,',
'||SUBSTR(column_name,1,30),NULL)) || 
             MAX(DECODE(column_position,16,',
'||SUBSTR(column_name,1,30),NULL)) columns
    FROM dba_ind_columns b
   GROUP BY b.table_owner,
            b.table_name,
            b.index_owner,
            b.index_name ) bi
WHERE ai.table_owner     = bi.table_owner
  AND ai.table_name      = bi.table_name
  AND ai.columns        LIKE bi.columns || ',%'
  AND ai.columns        <> bi.columns
ORDER BY ai.table_owner,
         ai.table_name,
         bi.index_name
/
spool off
ttitle off
clear breaks
clear columns
set linesize 96
set pagesize 60
set feedback on
