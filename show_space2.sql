create or replace type show_space_type                                         
as object                                                                      
( owner                 varchar2(30),                                          
  segment_name          varchar2(30),                                          
  partition_name        varchar2(30),                                          
  segment_type          varchar2(30),                                          
  free_blocks           number,                                                
  total_blocks          number,                                                
  unused_blocks         number,                                                
  last_used_ext_fileid  number,                                                
  last_used_ext_blockid number,                                                
  last_used_block       number                                                 
)                                                                              
/                                                                              
create or replace type show_space_table_type                                   
as table of show_space_type                                                    
/                                                                              
                                                                               
                                                                               
And then the function:                                                         
                                                                               
create or replace                                                              
function show_space_for                                                        
( p_segname   in varchar2,                                                     
  p_owner     in varchar2 default user,                                        
  p_type      in varchar2 default 'TABLE',                                     
  p_partition in varchar2 default NULL )                                       
return show_space_table_type                                                   
authid CURRENT_USER                                                            
as                                                                             
    pragma autonomous_transaction;                                             
    type rc is ref cursor;                                                     
    l_cursor rc;                                                               
                                                                               
    l_free_blks                 number;                                        
    l_total_blocks              number;                                        
    l_total_bytes               number;                                        
    l_unused_blocks             number;                                        
    l_unused_bytes              number;                                        
    l_LastUsedExtFileId         number;                                        
    l_LastUsedExtBlockId        number;                                        
    l_last_used_block           number;                                        
    l_sql                       long;                                          
    l_conj                      varchar2(7) default ' where ';                 
    l_data                      show_space_table_type :=                       
show_space_table_type();                                                       
    l_owner varchar2(30);                                                      
    l_segment_name varchar2(30);                                               
    l_segment_type varchar2(30);                                               
    l_partition_name varchar2(30);                                             
                                                                               
    procedure add_predicate( p_name in varchar2, p_value in varchar2 )         
    as                                                                         
    begin                                                                      
        if ( instr( p_value, '%' ) > 0 )                                       
        then                                                                   
            l_sql := l_sql || l_conj || p_name ||                              
                            ' like ''' || upper(p_value) || '''';              
            l_conj := ' and ';                                                 
        elsif ( p_value is not null )                                          
        then                                                                   
            l_sql := l_sql || l_conj || p_name ||                              
                            ' = ''' || upper(p_value) || '''';                 
            l_conj := ' and ';                                                 
        end if;                                                                
    end;                                                                       
begin                                                                          
    l_sql := 'select owner, segment_name, segment_type, partition_name         
                from dba_segments ';                                           
                                                                               
    add_predicate( 'segment_name', p_segname );                                
    add_predicate( 'owner', p_owner );                                         
    add_predicate( 'segment_type', p_type );                                   
    add_predicate( 'partition', p_partition );                                 
                                                                               
    execute immediate 'alter session set cursor_sharing=force';                
    open l_cursor for l_sql;                                                   
    execute immediate 'alter session set cursor_sharing=exact';                
                                                                               
    loop                                                                       
        fetch l_cursor into l_owner, l_segment_name, l_segment_type,           
l_partition_name;                                                              
        exit when l_cursor%notfound;                                           
        begin                                                                  
        dbms_space.free_blocks                                                 
        ( segment_owner     => l_owner,                                        
          segment_name      => l_segment_name,                                 
          segment_type      => l_segment_type,                                 
          partition_name    => l_partition_name,                               
          freelist_group_id => 0,                                              
          free_blks         => l_free_blks );                                  
                                                                               
        dbms_space.unused_space                                                
        ( segment_owner     => l_owner,                                        
          segment_name      => l_segment_name,                                 
          segment_type      => l_segment_type,                                 
          partition_name    => l_partition_name,                               
          total_blocks      => l_total_blocks,                                 
          total_bytes       => l_total_bytes,                                  
          unused_blocks     => l_unused_blocks,                                
          unused_bytes      => l_unused_bytes,                                 
          LAST_USED_EXTENT_FILE_ID => l_LastUsedExtFileId,                     
          LAST_USED_EXTENT_BLOCK_ID => l_LastUsedExtBlockId,                   
          LAST_USED_BLOCK => l_LAST_USED_BLOCK );                              
                                                                               
        l_data.extend;                                                         
        l_data(l_data.count) :=                                                
               show_space_type( l_owner, l_segment_name, l_partition_name,     
                  l_segment_type, l_free_blks, l_total_blocks, l_unused_blocks,
                  l_lastUsedExtFileId, l_LastUsedExtBlockId, l_last_used_block 
);                                                                             
        exception                                                              
            when others then null;                                             
        end;                                                                   
    end loop;                                                                  
    close l_cursor;                                                            
                                                                               
    return l_data;                                                             
end;                                                                           
/                                                                              
                                                                               
                                                                               
                                                                               