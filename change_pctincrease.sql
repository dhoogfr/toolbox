BEGIN

    for big_seg in 
        ( select owner, segment_name, segment_type
          from dba_segments
          where bytes > 100 *1024*1024
                and segment_type in ('INDEX', 'TABLE')
        )
    loop
    
        dbms_output.put_line( 'alter ' || big_seg.segment_type || ' ' ||
                          big_seg.owner || '.' || big_seg.segment_name ||
                          ' storage (pctincrease 0);');
    end loop;

END;