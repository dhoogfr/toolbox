create table object_storage_space(  obj_owner varchar2(30),
 obj_name varchar2(30),
 obj_type varchar2(20),
 total_bytes number(30),
 unused_bytes number(30),
 used_bytes number(30));

Create or Replace Procedure Object_Space_Check(obj_owner in
varchar2,obj_type in varchar2)
is

   total_blocks number;
   total_bytes number;
   unused_blocks number;
   unused_bytes number;
   last_used_extent_File_id number;
   last_used_extentblock_id number;
   last_used_block number;
   Trun_Cur Number;
   Out_value Number;
   Cursor Space_Chk_Cur is select object_name from dba_objects
where object_type = obj_type and
        owner = obj_owner;
   
Begin
        
Trun_Cur := DBMS_SQL.OPEN_CURSOR;
DBMS_SQL.PARSE(Trun_Cur,'Truncate Table
Object_Storage_Space',DBMS_SQL.V7);
Out_Value := DBMS_SQL.Execute(Trun_Cur);
DBMS_SQL.CLOSE_CURSOR(Trun_Cur);

For Space_Chk_Rec in Space_Chk_Cur Loop
                
sys.dbms_space.unused_space(obj_owner,Space_Chk_Rec.object_name,
 obj_type,total_blocks,
 total_bytes,
 unused_blocks,
 unused_bytes,
 last_used_extent_File_id,
 last_used_extentblock_id,
 last_used_block,               
 NULL);
 
Insert into object_storage_space 
values (obj_owner,
        Space_Chk_Rec.object_name,
        obj_type,
        total_bytes,
        unused_bytes,
        total_bytes-unused_bytes);
        commit;
      End Loop;
End;                      
