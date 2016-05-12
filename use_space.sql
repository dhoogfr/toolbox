DECLARE
   total_blocks number;
   total_bytes number;
   unused_blocks number;
   unused_bytes number;
   last_used_extent_File_id number;
   last_used_extentblock_id number;
   last_used_block number;
   Trun_Cur Number;
   Out_value Number;
   l_owner varchar2(30) := 'FULFILLMENT';

BEGIN

    For Space_Chk_Rec in (select
                            object_name,
                            object_type
                          from
                            dba_objects
                          where
                            object_type in ('TABLE', 'INDEX', 'LOB')
                            and owner = l_owner
                            and temporary = 'N'
                          order by
                            object_type,
                            object_name
                         ) loop
    
--        dbms_output.put_line(Space_Chk_Rec.object_name || ' ' || Space_Chk_Rec.object_type);
        sys.dbms_space.unused_space( l_owner,
                                     Space_Chk_Rec.object_name,
                                     Space_Chk_Rec.object_type,
                                     total_blocks,
                                     total_bytes,
                                     unused_blocks,
                                     unused_bytes,
                                     last_used_extent_File_id,
                                     last_used_extentblock_id,
                                     last_used_block,
                                     NULL
                                   );

        dbms_output.put_line('object_owner: ' || l_owner);
        dbms_output.put_line('object_name: ' || Space_Chk_Rec.object_name);
        dbms_output.put_line('object_type: ' || Space_Chk_Rec.object_type);
        dbms_output.put_line('total_bytes: ' || total_bytes || ' bytes');
        dbms_output.put_line('unused_bytes: ' || unused_bytes || ' bytes');
        dbms_output.put_line('used_bytes: ' || (total_bytes - unused_bytes) || ' bytes');
        dbms_output.put_line('---------------------------------------------------------------------------');
        dbms_output.put_line(' ');
        
    End Loop;

END;
