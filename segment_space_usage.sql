set serveroutput on
set verify off

DECLARE

    l_segment_owner                varchar2(30);
    l_segment_name                 varchar2(30);
    l_partition_name               varchar2(30);
    l_segment_type                 varchar2(30);
    l_unformatted_blocks           number;
    l_unformatted_bytes            number;
    l_fs1_blocks                   number; -- Number of blocks that has at least 0 to 25% free space
    l_fs1_bytes                    number; -- Number of bytes that has at least 0 to 25% free space
    l_fs2_blocks                   number; -- Number of blocks that has at least 25 to 50% free space
    l_fs2_bytes                    number; -- Number of bytes that has at least 25 to 50% free space
    l_fs3_blocks                   number; -- Number of blocks that has at least 50 to 75% free space
    l_fs3_bytes                    number; -- Number of bytes that has at least 50 to 75% free space
    l_fs4_blocks                   number; -- Number of blocks that has at least 75 to 100% free space
    l_fs4_bytes                    number; -- Number of bytes that has at least 75 to 100% free space
    l_full_blocks                  number; -- Total number of blocks that are full in the segment
    l_full_bytes                   number; -- Total number of bytes that are full in the segment
    l_total_blocks                 number;
    l_total_bytes                  number;
    l_unused_blocks                number;
    l_unused_bytes                 number;
    l_last_used_extent_file_id     number;
    l_last_used_extent_block_id    number;
    l_last_used_block              number;
    l_free_blks                    number;
    l_segment_space_management     varchar2(30);

BEGIN

    select ts.segment_space_management
    into l_segment_space_management
    from dba_segments seg, dba_tablespaces ts
    where seg.owner = '&&segment_owner'
          and seg.segment_name = '&&segment_name'
          and ( '&&partition_name' is null 
                or seg.partition_name = '&&partition_name'
              ) 
          and seg.tablespace_name = ts.tablespace_name;

    if l_segment_space_management = 'AUTO'
    then

        dbms_space.space_usage
          ( segment_owner        => '&&segment_owner',
            segment_name         => '&&segment_name',
            segment_type         => '&&segment_type',
            partition_name       => '&&partition_name',
            unformatted_blocks   => l_unformatted_blocks,
            unformatted_bytes    => l_unformatted_bytes,
            fs1_blocks           => l_fs1_blocks,
            fs1_bytes            => l_fs1_bytes,
            fs2_blocks           => l_fs2_blocks,
            fs2_bytes            => l_fs2_bytes,
            fs3_blocks           => l_fs3_blocks,
            fs3_bytes            => l_fs3_bytes,
            fs4_blocks           => l_fs4_blocks,
            fs4_bytes            => l_fs4_bytes,
            full_blocks          => l_full_blocks,
            full_bytes           => l_full_bytes
          );

        dbms_output.put_line('blocks');
        dbms_output.put_line('   unformatted           : ' || to_char(l_unformatted_blocks, '9G999G999G999G999G999'));
        dbms_output.put_line('    0 to  25% free space : ' || to_char(l_fs1_blocks, '9G999G999G999G999G999'));
        dbms_output.put_line('   25 to  50% free space : ' || to_char(l_fs2_blocks, '9G999G999G999G999G999'));
        dbms_output.put_line('   50 to  75% free space : ' || to_char(l_fs3_blocks, '9G999G999G999G999G999'));
        dbms_output.put_line('   75 to 100% free space : ' || to_char(l_fs4_blocks, '9G999G999G999G999G999'));
        dbms_output.put_line('   full                  : ' || to_char(l_full_blocks, '9G999G999G999G999G999'));
        dbms_output.new_line;
        dbms_output.put_line('bytes');    
        dbms_output.put_line('   unformatted           : ' || to_char(l_unformatted_bytes, '9G999G999G999G999G999'));
        dbms_output.put_line('    0 to  25% free space : ' || to_char(l_fs1_bytes, '9G999G999G999G999G999'));
        dbms_output.put_line('   25 to  50% free space : ' || to_char(l_fs2_bytes, '9G999G999G999G999G999'));
        dbms_output.put_line('   50 to  75% free space : ' || to_char(l_fs3_bytes, '9G999G999G999G999G999'));
        dbms_output.put_line('   75 to 100% free space : ' || to_char(l_fs4_bytes, '9G999G999G999G999G999'));
        dbms_output.put_line('   full                  : ' || to_char(l_full_bytes, '9G999G999G999G999G999'));

    else

        dbms_space.free_blocks
          ( segment_owner     => '&&segment_owner',
            segment_name      => '&&segment_name',
            segment_type      => '&&segment_type',
            freelist_group_id => 0,
            free_blks         => l_free_blks
          );
 
        dbms_output.put_line('free blocks              : ' || to_char(l_free_blks, '9G999G999G999G999G999'));

    end if;

    dbms_space.unused_space
      ( segment_owner             => '&&segment_owner',
        segment_name              => '&&segment_name',
        segment_type              => '&&segment_type',
        partition_name            => '&&partition_name',
        total_blocks              => l_total_blocks,
        total_bytes               => l_total_bytes,
        unused_blocks             => l_unused_blocks,
        unused_bytes              => l_unused_bytes,
        last_used_extent_file_id  => l_last_used_extent_file_id,
        last_used_extent_block_id => l_last_used_extent_block_id,
        last_used_block           => l_last_used_block
      );

    dbms_output.put_line('blocks');
    dbms_output.put_line('   total                 : ' || to_char(l_total_blocks, '9G999G999G999G999G999'));
    dbms_output.put_line('   unused                : ' || to_char(l_unused_blocks, '9G999G999G999G999G999'));
    dbms_output.new_line;
    dbms_output.put_line('bytes');    
    dbms_output.put_line('   total                 : ' || to_char(l_total_bytes, '9G999G999G999G999G999'));
    dbms_output.put_line('   unused                : ' || to_char(l_unused_bytes, '9G999G999G999G999G999'));    
    dbms_output.new_line;
    dbms_output.put_line('last used extent');
    dbms_output.put_line('   file id               : ' || to_char(l_last_used_extent_file_id, '9G999G999G999G999G999'));
    dbms_output.put_line('   starting block id     : ' || to_char(l_last_used_extent_block_id, '9G999G999G999G999G999'));
    dbms_output.put_line('   last block            : ' || to_char(l_last_used_block, '9G999G999G999G999G999'));
       
END;
/

undefine segment_owner
undefine segment_name
undefine segment_type
undefine partition_name

