-- get the size, used, expired and unexpired blocks/bytes for a given securefile lob segment
-- type can be LOB, LOB PARTITION or LOB SUBPARTITION

set serveroutput on
set verify off

accept segment_owner char prompt "Owner: ";
accept segment_name char prompt "Name: ";
accept segment_type char prompt "Type: ";
accept partition_name char prompt "Partition Name: ";

DECLARE

  l_segment_size_blocks   number;
  l_segment_size_bytes    number;
  l_used_blocks           number;
  l_used_bytes            number;
  l_expired_blocks        number;
  l_expired_bytes         number;
  l_unexpired_blocks      number;
  l_unexpired_bytes       number;

BEGIN

  dbms_space.space_usage
    ( segment_owner           =>  '&segment_owner',
      segment_name            =>  '&segment_name',
      segment_type            =>  '&segment_type',
      segment_size_blocks     =>  l_segment_size_blocks,
      segment_size_bytes      =>  l_segment_size_bytes,
      used_blocks             =>  l_used_blocks,
      used_bytes              =>  l_used_bytes,
      expired_blocks          =>  l_expired_blocks,
      expired_bytes           =>  l_expired_bytes,
      unexpired_blocks        =>  l_unexpired_blocks,
      unexpired_bytes         =>  l_unexpired_bytes,
      partition_name          =>  '&partition_name'
    );

  dbms_output.new_line;
  dbms_output.put_line('size (blocks):      ' || l_segment_size_blocks);
  dbms_output.put_line('size (bytes):       ' || l_segment_size_bytes);
  dbms_output.put_line('used (blocks):      ' || l_used_blocks);
  dbms_output.put_line('used (bytes):       ' || l_used_bytes);
  dbms_output.put_line('expired (blocks):   ' || l_expired_blocks);
  dbms_output.put_line('expired (bytes):    ' || l_expired_bytes);
  dbms_output.put_line('unexpired (blocks): ' || l_unexpired_blocks);
  dbms_output.put_line('unexpired (bytes):  ' || l_unexpired_bytes);

END;
/

undefine segment_owner
undefine segment_name
undefine segment_type
undefine partition_name
