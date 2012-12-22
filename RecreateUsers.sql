set lines 180 trimspool on verify off
CREATE OR REPLACE PACKAGE gdp$uptime_migration
AS
 -- Author: Geert De Paep - Uptime Technologies

 procedure SetDebug(DebugA in boolean default true);
 Procedure VerifyTargetDatabase(DbNameA in varchar2,
                                HostNameA in varchar2 default null,
                                InstanceNameA in varchar2 default null,
                                VersionLikeA in varchar2 default null);
 procedure SetScriptOptions(GenSqlA in boolean default true,
                            LogFileNameA in varchar2 default null,
                            WheneverSqlErrorA in boolean default false,
                            AddInfoA in boolean default true,
                            CheckRoleExistanceA in boolean default false,
                            NrPausesA in number default 0,
                            DocFormatA in varchar2 default 'TXT',
                            IncDropUsersA in boolean default false,
                            IncDropUsersCascadeA in boolean default false,
                            LineSizeA in number default 200
                            );
 procedure SetDatafileOptions(SrcSeparatorA in varchar2 default null,
                              DstSeparatorA in varchar2 default null,
                              FilesizeInitialPctA in number default 100,
                              FilesizeAutomaxPctA in number default 100,
                              ForceAutoextendA in boolean default true,
                              DefaultDirectoryA in varchar2 default null,
                              ConvertFilenamesToLowerA in boolean default false,
                              IncDropPermanentTablespacesA in boolean default false,
                              IncIncludeDropTSContentsA in boolean default false,
                              IncDropTemporaryTablespacesA in boolean default false
                              );
 PROCEDURE ExcludeTablespace(TablespaceA IN VARCHAR2);
 PROCEDURE IncludeTablespace(TablespaceA IN VARCHAR2);
 PROCEDURE ExcludeSysPriv(PrivilegeA IN VARCHAR2);
 PROCEDURE ExcludeRole(RoleA IN VARCHAR2);
 PROCEDURE AddDatafileDirectory(IfLikeA IN VARCHAR2, DirA IN VARCHAR2);
 PROCEDURE SetUserList(UserListA in varchar2);
 procedure SetCreateOptions(CreateUsers in boolean,
                            SysPrivsUsers in boolean,
                            ObjPrivsUsers in boolean,
                            DependentTS in boolean,
                            PublicSynonyms in boolean,
                            SetQuotas in boolean,
                            CreateRoles in boolean,
                            SysPrivsRoles in boolean,
                            ObjPrivsRoles in boolean,
                            GrantRoles in boolean,
                            Contexts in boolean);
 procedure SetCreateOptions(PrePostImportA in varchar2);
 procedure Run(BigBannerA in varchar2 default null);
 procedure Reset;
 procedure CORP;
 procedure MDB;
 procedure MDBW;
 procedure BORP;
 procedure CORPSTAT;
 procedure ZINT;
END gdp$uptime_migration;
/

CREATE OR REPLACE PACKAGE BODY gdp$uptime_migration
AS

 -- Minimum extent size for tablespaces

 -- Create-options:
 OptCreateUsers boolean;
 OptSysPrivsUsers boolean;
 OptObjPrivsUsers boolean;
 OptDependentTS boolean;
 OptPublicSynonyms boolean;
 OptSetQuotas boolean;
 OptCreateRoles boolean;
 OptSysPrivsRoles boolean;
 OptObjPrivsRoles boolean;
 OptGrantRoles boolean;
 OptContexts boolean;

 -- Script-options:
 DEBUG BOOLEAN := false;
 GenSql boolean := true;      -- If true, generate SQL stmts, if false, only tell what will be done
 LogFileName varchar2(256);   -- If specified, generate "spool <LogFileName>" in the output
 IncludeWheneverSqlError BOOLEAN;     -- Enclose CREATE statements by "whenever sqlerror"
 NrPauses NUMBER;             -- Ask this number of times for confirmation
 DocFormat VARCHAR2(3);       -- Output format
 AddInfo BOOLEAN;             -- Add extra informational messages
 IncDropUsers BOOLEAN;        -- Generates 'DROP USER' statements
 IncDropUsersCascade BOOLEAN; -- Adds CASCADE to DROP USER statements
 CheckRoleExistance BOOLEAN;  -- Skip role creation if it already exists
 LineSize number;

 -- Datafile-options:
 SourceDirectorySeparator CHAR(1);       -- Typically / on UNIX and \ on Windows
 DestinationDirectorySeparator CHAR(1);  -- Typically / on UNIX and \ on Windows
 DefaultDatafileDirectory VARCHAR2(256); -- If specified, use this dir for all datafile names. If null, keep original directory
 ConvertFilenamesToLower BOOLEAN;        -- Convert all datafile-names to lower
 IncDropPermanentTablespaces BOOLEAN;    -- Generate DROP statements for permanent tablespaces
 IncIncludeDropTSContents BOOLEAN;       -- Adds 'including contents and datafiles' to drop tablespace
 IncDropTemporaryTablespaces BOOLEAN;    -- Generate DROP statements for temporary tablespaces
 ForceAutoextend BOOLEAN;                -- Create all datafiles with autoextend option
 FilesizeInitialPct NUMBER;              -- Create datafiles initially as FilesizeInitialPct percent from current size
 FilesizeAutomaxPct NUMBER;              -- Create datafiles maxsize as FilesizeAutomaxPct percent from current maxsize
 FilesizeAutomaxMaxKb number;            -- Create datafiles maxsize never bigger than FilesizeAutomaxMaxKb k
 ForceAutoallocate BOOLEAN;

 -- Internal Variables:
 OptVerifyDbName varchar2(64);       -- If specified, the output will contain a check on database name
 OptVerifyHostName varchar2(128);
 OptVerifyInstanceName varchar2(64);
 OptVerifyVersionLike varchar2(32);


 TYPE V256Tbl IS TABLE OF VARCHAR2(256) INDEX BY BINARY_INTEGER;
 TYPE V30Tbl IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
 TYPE V61Tbl IS TABLE OF VARCHAR2(61) INDEX BY BINARY_INTEGER;
 DatafileLikeTable V256Tbl;
 DatafileDirectoryTable V256Tbl;
 CreatedTablespaces V30Tbl;
 IncludedTablespaces V30Tbl;
 ExcludedSysPrivs V30Tbl;
 ExcludedRoles V30Tbl;
 CreatedRoles V30Tbl;         -- List of roles for which CREATE ROLE is already done
 GrantedSysPrivsRoles V30Tbl; -- List of roles that have received sysprivs
 GrantedObjPrivsRoles V30Tbl; -- List of roles that have received objprivs
 GrantedRoles V61Tbl;         -- List of roles that have been granted to user or other role
 PausesPrinted NUMBER;
 DbBlockSize NUMBER;
 DbVersion varchar2(32);
 DbName VARCHAR2(32);
 QueuedLevel number;
 QueuedMessage varchar2(4000);
 UserTab Dbms_Utility.uncl_array;


 ------------------------------------------------------------------------------
 ------------------------------------------------------------------------------
 ------------------------------------------------------------------------------
 ------------------------------------------------------------------------------
 FUNCTION AddPostIfNotNull(MsgA IN VARCHAR2, PostFixA IN varchar2) RETURN VARCHAR2
 IS
   -- Help function to append a postfix to a value, only when that value is not null
 BEGIN
  IF (MsgA IS NULL) THEN RETURN NULL;
  ELSE RETURN MsgA||PostFixA;
  END IF;
 END;
 ------------------------------------------------------------------------------
 FUNCTION AddPreIfNotNull(MsgA IN VARCHAR2, PreFixA IN varchar2) RETURN VARCHAR2
 IS
   -- Help function to prepend a prefix to a value, only when that value is not null
 BEGIN
  IF (MsgA IS NULL) THEN RETURN NULL;
  ELSE RETURN PreFixA||MsgA;
  END IF;
 END;
 -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 procedure PutLineSplit(PrefixA in varchar2, MsgA in varchar2,
                        WidthA in number, SplitOnA in varchar2 default ' ',
                        AllowSplitA in boolean default true)
 is
   -- Put a line in the output. Take the global variable "linesize" into account for wrapping.
   -- If the line is longer than linesize and wraps, the PrefixA will
   -- be repeated on the next line.
   -- Lines will only be wrapped after a character listed in SplitOnA
   -- If AllowSpliA is false and line is longer than linesize, an error will be raised
   SpacePos number;
   Msg varchar2(20000);
   Cntr number := 0; -- To avoid infinite loop
 begin
  if (LineSize < length(PrefixA)+10) then
    Raise_Application_Error(-20999,'Error in PutLineSplit: Linesize too small for prefix '||PrefixA);
  end if;
  if (SplitOnA is null) then
    Raise_Application_Error(-20999,'Error in PutLineSplit: SplitOnA may not be null');
  end if;
  if (MsgA is null) then
    if (DocFormat = 'HTP') then
      htp.p('<BR>');
    else
      dbms_output.put_line(MsgA);
    end if;
  else
   Msg := MsgA;
   while (Length(PrefixA||Msg) > WidthA and Cntr < 1000) loop
    for i in 1 .. length(SplitOnA) loop
      SpacePos := instr(PrefixA||Msg,substr(SplitOnA,i,1),-(length(PrefixA||Msg)-WidthA+1));
      if (SpacePos <> 0) then exit; end if;
    end loop;
    if (SpacePos = 0 and NOT AllowSplitA) then -- No character found to split on
      Raise_Application_Error(-20999,'Error in PutLineSplit: Linesize too small, unable to wrap data. You must increase linesize.');
    elsif (SpacePos = 0) then -- No character found to split on
      if (DocFormat = 'HTP') then
        htp.p(substr(PrefixA||Msg,1,WidthA)||'<BR>');
      elsif (DocFormat = 'HTM') then
        dbms_output.put_line(substr(PrefixA||Msg,1,WidthA)||'<BR>');
      else
        dbms_output.put_line(substr(PrefixA||Msg,1,WidthA));
      end if;
      Msg := substr(PrefixA||Msg,WidthA+1);
    else
      if (DocFormat = 'HTP') then
        htp.p(substr(PrefixA||Msg,1,SpacePos)||'<BR>');
      elsif (DocFormat = 'HTM') then
        dbms_output.put_line(substr(PrefixA||Msg,1,SpacePos)||'<BR>');
      else
        dbms_output.put_line(substr(PrefixA||Msg,1,SpacePos));
      end if;
      Msg := substr(PrefixA||Msg,SpacePos+1);
    end if;
    Cntr := Cntr + 1;
   end loop;
   if (DocFormat = 'HTP') then
     htp.p(PrefixA||Msg);
   elsif (DocFormat = 'HTM') then
     dbms_output.put_line(PrefixA||Msg);
   else
     dbms_output.put_line(PrefixA||Msg);
   end if;
  end if;
 exception
  when OTHERS then
    raise_application_error(-20000,'Error in PutLineSplit',true);
 end;
 ------------------------------------------------------------------------------
 PROCEDURE PrintDebug(MsgA IN VARCHAR2)
 IS
 BEGIN
  IF (DEBUG) THEN
    PutLineSplit('--DEBUG ',MsgA,200);
  END IF;
 END;

 ------------------------------------------------------------------------------
 PROCEDURE PrintInfo(LevelA IN number, MsgA IN VARCHAR2,
                     ConditionalA in boolean default false)
   -- This procedure prints an informational line in the output.
   -- I.e. it will generate: prompt <MsgA>
   -- It will alos take into account the pauses, so at the beginning of the
   --  output, it will generate a number of: pause <MsgA>
   -- If ConditionalA = true, the MsgA will only be printed if it is followed
   --  by a PrintMessage(...) statement, and not if it is followed by another PrintInfo(...)
 IS
 BEGIN
  if (ConditionalA) then
    PrintDebug('Entering PrintInfo with Msg '||substr(MsgA,1,10)||'... and ConditionalA=true');
    -- We don't know if this message really needs to be printed. It depends on
    --  whether there will still be printed more data
    QueuedLevel := LevelA;
    QueuedMessage := MsgA;
  else
    PrintDebug('Entering PrintInfo with Msg '||substr(MsgA,1,10)||'... and ConditionalA=false');
    IF (PausesPrinted < NrPauses AND GenSql) THEN
      PutLineSplit('pause ',MsgA||' ... <RET>',LineSize);
      PausesPrinted := PausesPrinted + 1;
      IF (PausesPrinted = NrPauses AND NrPauses > 0) THEN
        PutLineSplit('pause ','The rest of this script will run automatically (no more pauses) ...<RET>', LineSize);
      END IF;
    ELSE
      IF (AddInfo) THEN
        PutLineSplit('prompt ',MsgA, LineSize);
        IF (LevelA <= 2) THEN
          -- Print an additional horizontal line if level <= 2
          PutLineSplit(null, LPad('-',Length('prompt '||MsgA),'-'), LineSize);
        END IF;
        IF (LevelA = 1) THEN
          -- Print an additional blank line if level = 1
          PutLineSplit(null, '', LineSize);
        END IF;
      END IF;
    END IF;
    QueuedMessage := null;
  end if;
 END;

 ------------------------------------------------------------------------------
 PROCEDURE PrintMessage(MsgA IN VARCHAR2)
 IS
  -- This procedure puts the MsgA into the output
  -- It will first print the Queued message, if there is any
 BEGIN
  if (QueuedMessage is not null) then
    PrintDebug('Entering PrintMessage, BUT first need to print previously queued message');
    PrintInfo(QueuedLevel, QueuedMessage, false);
  end if;
  PutLineSplit(null,MsgA,LineSize, AllowSplitA => false);
 END;

 ------------------------------------------------------------------------------
 PROCEDURE StartWheneverSqlError
 IS
 BEGIN
  IF (IncludeWheneverSqlError) then
   PrintMessage('whenever sqlerror exit sql.sqlcode');
  END IF;
 END;

 ------------------------------------------------------------------------------
 PROCEDURE StopWheneverSqlError
 IS
 BEGIN
  IF (IncludeWheneverSqlError) then
   PrintMessage('whenever sqlerror continue');
  END IF;
 END;

 ------------------------------------------------------------------------------
 Procedure VerifyTargetDatabase(DbNameA in varchar2,
                                HostNameA in varchar2 default null,
                                InstanceNameA in varchar2 default null,
                                VersionLikeA in varchar2 default null)
 is
 begin
   OptVerifyDbName := DbNameA;
   OptVerifyHostName := HostNameA;
   OptVerifyInstanceName := InstanceNameA;
   OptVerifyVersionLike := VersionLikeA;
 end;

 ------------------------------------------------------------------------------
 Procedure DoVerifyTargetDatabase
 is
 begin
   if (OptVerifyDbName is not null) then
    PrintMessage('prompt Checking if we are in the correct database...');
    PrintMessage('whenever sqlerror exit');
    PrintMessage('set serveroutput on format wrapped');
    PrintMessage('declare');
    PrintMessage(' DbName varchar2(30);');
    PrintMessage(' HostName varchar2(30);');
    PrintMessage(' InstanceName varchar2(30);');
    PrintMessage(' Version varchar2(30);');
    PrintMessage('begin');
    PrintMessage(' select instance_name, host_name, version, d.name');
    PrintMessage('  into InstanceName, HostName, Version, DbName');
    PrintMessage('  from v$instance, v$database d;');
    PrintMessage(' dbms_output.put_line(''Checking if we are in the requested database:'');');
    PrintMessage(' if (upper(DbName) = upper('''||OptVerifyDbName||''')) then');
    PrintMessage('   dbms_output.put_line(''Database name:  ''||DbName);');
    PrintMessage(' else');
    PrintMessage('   raise_application_error(-20000,''WRONG DATABASE!!! Databasename (''||DbName||'') not correct'');');
    PrintMessage(' end if;');
    if (OptVerifyInstanceName is not null) then
      PrintMessage(' if (upper(InstanceName) = upper('''||OptVerifyInstanceName||''')) then');
      PrintMessage('   dbms_output.put_line(''Instance name:  ''||InstanceName);');
      PrintMessage(' else');
      PrintMessage('   raise_application_error(-20000,''WRONG DATABASE!!! Instancename (''||InstanceName||'') not correct'');');
      PrintMessage(' end if;');
    end if;
    if (OptVerifyHostName is not null) then
      PrintMessage(' if (upper(HostName) = upper('''||OptVerifyHostName||''')) then');
      PrintMessage('   dbms_output.put_line(''Host name:      ''||HostName);');
      PrintMessage(' else');
      PrintMessage('   raise_application_error(-20000,''WRONG DATABASE!!! HostName (''||HostName||'') not correct'');');
      PrintMessage(' end if;');
    end if;
    if (OptVerifyVersionLike is not null) then
      PrintMessage(' if (Version like '''||OptVerifyVersionLike||''') then');
      PrintMessage('   dbms_output.put_line(''Version  :      ''||Version);');
      PrintMessage(' else');
      PrintMessage('   raise_application_error(-20000,''WRONG DATABASE!!! Version (''||Version||'') not correct'');');
      PrintMessage(' end if;');
    end if;
    PrintMessage(' dbms_output.put_line(''This is the correct database!'');');

    PrintMessage('end;');
    PrintMessage('/');
    PrintMessage('whenever sqlerror continue');
    PrintMessage('');
   end if;
 end;

 ------------------------------------------------------------------------------
 FUNCTION FetchViewText(OwnerA IN VARCHAR2, ViewA IN VARCHAR2) RETURN varchar2
 IS
  Cur NUMBER;
  Dummy NUMBER;
  BufSize NUMBER := 20000;
  Offset NUMBER := 0;
  OutData VARCHAR2(20000);
  OutSize NUMBER;
 BEGIN
  Cur := Dbms_Sql.open_cursor();
  Dbms_Sql.parse(Cur,'select text from dba_views where owner = :owner and view_name = :view_name', Dbms_Sql.native);
  Dbms_Sql.bind_variable(Cur, 'owner', Upper(OwnerA));
  Dbms_Sql.bind_variable(Cur, 'view_name', Upper(ViewA));
  Dbms_Sql.define_column_long(Cur, 1);
  Dummy := Dbms_Sql.EXECUTE(Cur);
  Dummy := Dbms_Sql.fetch_rows(Cur);
  IF (Dummy = 0) THEN
   RETURN '[View '||OwnerA||'.'||ViewA||' does not exist]';
  END IF;
  Dbms_Sql.column_value_long(Cur, 1, BufSize, Offset, OutData, OutSize);
  Dbms_Sql.close_cursor(Cur);
  OutData := replace(OutData,Chr(10));
  RETURN OutData;
 END;

 ------------------------------------------------------------------------------
 FUNCTION FetchViewCollist(OwnerA IN VARCHAR2, ViewA IN VARCHAR2) RETURN varchar2
 IS
  Collist VARCHAR2(20000);
 BEGIN
  FOR c_rec IN (SELECT column_name FROM dba_tab_columns
                 WHERE owner = OwnerA
                 AND   table_name = ViewA
                 ORDER BY column_id) LOOP
    collist := collist || ','||c_rec.column_name;
  END LOOP;
  RETURN SubStr(collist,2);
 END;

 ------------------------------------------------------------------------------
 function RoleCreated(RoleA in varchar2) return boolean
 IS
   -- Function returns tue if the 'CREATE ROLE' statement has already been
   --  generated during the current run of this procedure.
 begin
   FOR i IN 1 .. CreatedRoles.Count LOOP
    IF (RoleA = CreatedRoles(i)) THEN
     RETURN true;
    END IF;
   END LOOP;
   return false;
 end;
 ------------------------------------------------------------------------------
 procedure MarkRoleAsCreated(RoleA in varchar2)
 IS
   -- Internally register that the 'CREATE ROLE' has been generated
 begin
  CreatedRoles(CreatedRoles.count+1) := RoleA;
 end;
 ------------------------------------------------------------------------------
 function GrantedSysPrivsToRole(RoleA in varchar2) return boolean
 is
 begin
   FOR i IN 1 .. GrantedSysPrivsRoles.Count LOOP
    IF (RoleA = GrantedSysPrivsRoles(i)) THEN
     RETURN true;
    END IF;
   END LOOP;
   return false;
 end;
 ------------------------------------------------------------------------------
 procedure MarkGrantedSysPrivsToRole(RoleA in varchar2)
 is
 begin
  GrantedSysPrivsRoles(GrantedSysPrivsRoles.count+1) := RoleA;
 end;
 ------------------------------------------------------------------------------
 function GrantedObjPrivsToRole(RoleA in varchar2) return boolean
 is
 begin
   FOR i IN 1 .. GrantedObjPrivsRoles.Count LOOP
    IF (RoleA = GrantedObjPrivsRoles(i)) THEN
     RETURN true;
    END IF;
   END LOOP;
   return false;
 end;
 ------------------------------------------------------------------------------
 procedure MarkGrantedObjPrivsToRole(RoleA in varchar2)
 is
 begin
  GrantedObjPrivsRoles(GrantedObjPrivsRoles.count+1) := RoleA;
 end;
 ------------------------------------------------------------------------------
 function RoleGranted(RoleA in VARCHAR2, ToA IN varchar2) return boolean
 is
 begin
   FOR i IN 1 .. GrantedRoles.Count LOOP
    IF (Upper(RoleA||'.'||ToA) = GrantedRoles(i)) THEN
     RETURN true;
    END IF;
   END LOOP;
   return false;
 end;
 ------------------------------------------------------------------------------
 procedure MarkRoleAsGranted(RoleA in varchar2, ToA IN varchar2)
 is
 begin
  GrantedRoles(GrantedRoles.count+1) := Upper(RoleA||'.'||ToA);
 end;

 ------------------------------------------------------------------------------
 PROCEDURE RecreateTablespace(TablespaceA IN VARCHAR2, ReasonA in varchar2)
 IS
  t_rec dba_tablespaces%ROWTYPE;
  NrFiles NUMBER := 0;
  NewFilename VARCHAR2(512);
  Prefix VARCHAR2(16);
  DirectoryToUse VARCHAR2(256);
  FilenameToUse VARCHAR2(256);
  UNEXISTANT_TS exception;
  Assm varchar2(32);
 BEGIN
   -- Exclude SYSTEM tablespace
   IF (TablespaceA = 'SYSTEM') THEN RETURN; END IF;

   -- Check if this tablespace was already created before
   FOR i IN 1 .. CreatedTablespaces.Count LOOP
    IF (TablespaceA = CreatedTablespaces(i)) THEN
     RETURN;
    END IF;
   END LOOP;

  begin
    SELECT * INTO t_rec FROM dba_tablespaces WHERE tablespace_name = Upper(TablespaceA);
  exception
    when NO_DATA_FOUND then
     raise UNEXISTANT_TS;
  end;

  if (NOT GenSql) then
    PrintMessage('Tablespace '||t_rec.tablespace_name||' will be created because '||ReasonA);
  else
    -- Drop the tablespace first if requested to do so
    IF (IncDropPermanentTablespaces AND t_rec.CONTENTS = 'PERMANENT') THEN
      PrintInfo(3,'Dropping tablespace '||t_rec.tablespace_name);
      IF (IncIncludeDropTSContents) then
        PrintMessage('drop tablespace '||t_rec.tablespace_name||' including contents and datafiles;');
      ELSE
        PrintMessage('drop tablespace '||t_rec.tablespace_name||';');
      END IF;
    ELSIF (IncDropTemporaryTablespaces AND t_rec.CONTENTS = 'TEMPORARY') THEN
      PrintInfo(3,'Dropping tablespace '||t_rec.tablespace_name);
      PrintMessage('drop tablespace '||t_rec.tablespace_name||';');
    END IF;


    -- Write the first part of the CREATE statement (no datafiles yet)
    PrintInfo(3,'Creating tablespace '||t_rec.tablespace_name||' because '||ReasonA);
    StartWheneverSqlError;
    IF (t_rec.CONTENTS = 'PERMANENT') then
      PrintMessage('CREATE TABLESPACE '||t_rec.tablespace_name);
    ELSIF (t_rec.CONTENTS = 'TEMPORARY') THEN
      PrintMessage('CREATE TEMPORARY TABLESPACE '||t_rec.tablespace_name);
    ELSIF (t_rec.CONTENTS = 'UNDO') THEN
      PrintMessage('CREATE UNDO TABLESPACE '||t_rec.tablespace_name);
    ELSE
      PrintMessage('-- ERROR: this tablespace type is not supported '||t_rec.CONTENTS);
    END IF;

    -- Add all datafiles
    FOR d_rec IN (SELECT * FROM dba_data_files
                    WHERE tablespace_name = Upper(TablespaceA)
                    ORDER BY file_id) LOOP
      IF (NrFiles = 0 AND t_rec.CONTENTS in ('PERMANENT','UNDO')) THEN Prefix := ' DATAFILE ';
      ELSIF (NrFiles = 0 AND t_rec.CONTENTS = 'TEMPORARY') THEN Prefix := ' TEMPFILE ';
      ELSE Prefix := '        , ';
      END IF;

      PrintDebug('Adding file '||d_rec.file_name||' '||Ceil(d_rec.bytes/1024/1024)||'M --> '||Ceil(d_rec.maxbytes/1024/1024)||'M');

      DirectoryToUse := NULL;
      -- Search if a special mapping is defined for this datafile:
      FOR i IN 1 .. DatafileLikeTable.Count LOOP
        IF (d_rec.file_name LIKE DatafileLikeTable(i)) THEN
          DirectoryToUse := DatafileDirectoryTable(i);
          EXIT;
        END IF;
      END LOOP;
      IF (DirectoryToUse IS NULL) THEN
        DirectoryToUse := DefaultDatafileDirectory;
      END IF;

      IF (ConvertFilenamesToLower) then
        FilenameToUse := Lower(d_rec.file_name);
      ELSE
        FilenameToUse := d_rec.file_name;
      END IF;

      IF (DirectoryToUse IS NULL) THEN
      NewFilename := FilenameToUse;
      ELSE
      NewFileName := RTrim(DirectoryToUse,DestinationDirectorySeparator)||DestinationDirectorySeparator||
                      SubStr(FilenameToUse,InStr(d_rec.file_name,SourceDirectorySeparator,-1)+1);
      end if;
      PrintMessage(Prefix||''''||NewFilename||''' size '||ceil((d_rec.bytes*FilesizeInitialPct/100)/1024/1024)||'M');
      IF (d_rec.autoextensible = 'YES') THEN
      PrintMessage('          AUTOEXTEND on NEXT '||(d_rec.increment_by*DbBlockSize)/1024||'K MAXSIZE '||
                    Ceil(least(d_rec.maxbytes*FilesizeAutomaxPct/100/1024,FilesizeAutomaxMaxKb))||'K');
      ELSIF (ForceAutoextend) THEN
      PrintMessage('          AUTOEXTEND on NEXT '||Ceil((d_rec.bytes/20)/1024)||'K MAXSIZE '||
                    Ceil(least(d_rec.bytes*FilesizeAutomaxPct/100/1024,FilesizeAutomaxMaxKb))||'K');
      END IF;
      NrFiles := NrFiles + 1;
    END LOOP;

    -- Adding tempfiles
    FOR d_rec IN (SELECT * FROM dba_temp_files
                    WHERE tablespace_name = Upper(TablespaceA)
                    ORDER BY file_id) LOOP
      IF (NrFiles = 0) THEN Prefix := ' TEMPFILE ';
      ELSE Prefix := '        , ';
      END IF;

      DirectoryToUse := NULL;
      -- Search if a special mapping is defined for this datafile:
      FOR i IN 1 .. DatafileLikeTable.Count LOOP
        IF (d_rec.file_name LIKE DatafileLikeTable(i)) THEN
          DirectoryToUse := DatafileDirectoryTable(i);
          EXIT;
        END IF;
      END LOOP;
      IF (DirectoryToUse IS NULL) THEN
        DirectoryToUse := DefaultDatafileDirectory;
      END IF;

      IF (ConvertFilenamesToLower) then
        FilenameToUse := Lower(d_rec.file_name);
      ELSE
        FilenameToUse := d_rec.file_name;
      END IF;

      IF (DirectoryToUse IS NULL) THEN
      NewFilename := d_rec.file_name;
      ELSE
      NewFileName := RTrim(DirectoryToUse,DestinationDirectorySeparator)||DestinationDirectorySeparator||
                      SubStr(FilenameToUse,InStr(d_rec.file_name,SourceDirectorySeparator,-1)+1);
      end if;
      PrintMessage(Prefix||''''||NewFilename||''' size '||ceil((d_rec.bytes*FilesizeInitialPct/100)/1024/1024)||'M');
      IF (d_rec.autoextensible = 'YES') THEN
      PrintMessage('  AUTOEXTEND on NEXT '||(d_rec.increment_by*DbBlockSize)/1024||'K MAXSIZE '||
                    Ceil(least(d_rec.maxbytes*FilesizeAutomaxPct/100/1024,FilesizeAutomaxMaxKb))||'K');
      ELSIF (ForceAutoextend) THEN
      PrintMessage('  AUTOEXTEND on NEXT '||Ceil((d_rec.bytes/20)/1024)||'K MAXSIZE '||
                    Ceil(least(d_rec.bytes*FilesizeAutomaxPct/100/1024,FilesizeAutomaxMaxKb))||'K');
      END IF;
      NrFiles := NrFiles + 1;
    END LOOP;

    IF (t_rec.extent_management = 'LOCAL') THEN
      IF (t_rec.CONTENTS = 'TEMPORARY') THEN --TEMP TS must have UNIFORM size
        PrintMessage(' extent management LOCAL uniform size '||t_rec.next_extent);
      ELSIF (t_rec.allocation_type = 'SYSTEM' OR ForceAutoallocate) THEN
        PrintMessage(' extent management LOCAL autoallocate');
      ELSIF (t_rec.CONTENTS = 'UNDO') THEN -- UNDO TS must have autoallocate
        PrintMessage(' extent management LOCAL autoallocate');
      ELSIF (t_rec.allocation_type = 'UNIFORM') THEN
        PrintMessage(' extent management LOCAL uniform size '||t_rec.next_extent);
      ELSE
        Raise_application_error(-20000,'Error: Unsupported allocation type: '||t_rec.allocation_type);
      END IF;
      if (DbVersion not like '8.%') then
        execute immediate 'select segment_space_management from dba_tablespaces '||
                          ' where tablespace_name = '''||t_rec.tablespace_name||''''
                          into Assm;
        PrintMessage(' segment space management '||Assm);
      end if;
    END IF;
    IF (t_rec.CONTENTS NOT IN ('TEMPORARY','UNDO')) THEN
     PrintMessage(' '||t_rec.LOGGING);
    end if;
    PrintMessage(';');
    StopWheneverSqlError;
  end if;
  CreatedTablespaces(CreatedTablespaces.Count+1) := TablespaceA;
 EXCEPTION
  when UNEXISTANT_TS then
   PrintMessage('prompt !! WARNING Unexistant tablespace '||TablespaceA||' found, check def_ts and temp_ts in dba_users !!');
  WHEN OTHERS THEN
   Raise_application_error(-20000,'Error in RecreateTablespace for '||TablespaceA,true);
 END;

 ------------------------------------------------------------------------------
 function IsExcludedSysPriv(PrivilegeA in varchar2) return boolean
 is
 begin
  for i in 1 .. ExcludedSysPrivs.count loop
   if (upper(ExcludedSysPrivs(i)) = upper(PrivilegeA)) then
     return true;
   end if;
  end loop;
  return false;
 end;
 ------------------------------------------------------------------------------
 FUNCTION IsPredefinedRole(RoleA IN VARCHAR2) RETURN BOOLEAN
 IS
 BEGIN
  IF (RoleA IN ('CONNECT','RESOURCE','DBA','EXP_FULL_DATABASE','IMP_FULL_DATABASE',
                'SNMPAGENT','SELECT_CATALOG_ROLE','HS_ADMIN_ROLE','EXECUTE_CATALOG_ROLE',
                'DELETE_CATALOG_ROLE','GATHER_SYSTEM_STATISTICS','MONITOR_ROLE',
                'ORA_OWNER','ORA_OWNER_SESSION','ORA_OWNER_SPECIAL','OLAP_DBA','WM_ADMIN_ROLE',
                'AQ_ADMINISTRATOR_ROLE','AQ_USER_ROLE','JAVA_ADMIN','JAVA_DEPLOY',
                'JAVASYSPRIV','JAVAUSERPRIV','JAVAIDPRIV','JAVADEBUGPRIV',
                'OEM_MONITOR','RECOVERY_CATALOG_OWNER'
                )) THEN
    RETURN true;
  ELSE
    RETURN FALSE;
  END IF;
 END;
 ------------------------------------------------------------------------------
 function IsExcludedRole(RoleA in varchar2) return boolean
 is
 begin
  for i in 1 .. ExcludedRoles.count loop
   if (upper(ExcludedRoles(i)) = upper(RoleA)) then
     return true;
   end if;
  end loop;
  return false;
 end;

 ------------------------------------------------------------------------------
 function IsUser(UserA in varchar2) return boolean
 is
  x number;
 begin
  select 1 into x from dba_users where username = upper(UserA);
  return true;
 exception
  when no_data_found then return false;
 end;

 ------------------------------------------------------------------------------
 PROCEDURE CreateRole(RoleA IN VARCHAR2, ReasonA in varchar2)
 IS
 BEGIN
  IF (GenSql) then
    PrintInfo(3,'Creating role '||RoleA||' because '||ReasonA);
    StartWheneverSqlError;
    IF (CheckRoleExistance) then
      PrintMessage('declare');
      PrintMessage(' NrFound number;');
      PrintMessage('begin');
      PrintMessage(' select count(*) into NrFound from dba_roles where role = '''||RoleA||''';');
      PrintMessage(' if (NrFound = 0) then');
      PrintMessage('  execute immediate ''create role '||RoleA||''';');
      PrintMessage('  dbms_output.put_line(''Created role '||RoleA||''');' );
      PrintMessage(' else');
      PrintMessage('  dbms_output.put_line(''Role '||RoleA||' already exists'');' );
      PrintMessage(' end if;');
      PrintMessage('end;');
      PrintMessage('/');
    ELSE
      PrintMessage('create role '||RoleA||';');
    END IF;
    StopWheneverSqlError;
  ELSE
    PrintMessage('Role '||RoleA||' will be created because '||ReasonA);
  END IF;
 EXCEPTION
  WHEN OTHERS THEN
   Raise_application_error(-20000,'Error in CreateRoleWithSysPrivs for '||RoleA,true);
 END;

 ------------------------------------------------------------------------------
 PROCEDURE DoRolesGrantedToUser(GranteeA IN VARCHAR2, ActionA IN VARCHAR2,
                                LevelA IN NUMBER DEFAULT 0)
  -- Do action on the roles that are granted to this user + parent roles
 IS
  UserHasUnlimitedTS CHAR(1);
  NrRoles NUMBER;
  NrGrants number;
  Prefix VARCHAR2(25);
 BEGIN
  IF (ActionA NOT IN ('CREATE','ADDSYSPRIVS','ADDOBJPRIVS','GRANT')) THEN
   Raise_Application_Error(-20000,'Internal error: DoRolesGrantedToUser called with invalid action');
  END IF;
  IF (LevelA > 25) THEN Raise_Application_Error(-20000,'Nested level too deep for roles granted to other roles'); ELSE Prefix := LPad(' ',LevelA+1); END IF;
  PrintDebug(Prefix||'Entering DoRolesGrantedToUser for Grantee='||GranteeA||', Action='||ActionA||', Level '||LevelA);
--  IF (GenSql) THEN
    FOR r_rec IN (SELECT granted_role, Decode(admin_option,'YES',' with admin option','') AS admin_option
                    FROM dba_role_privs
                    WHERE grantee = GranteeA
                    order by granted_role) LOOP
      PrintDebug(Prefix||'Role '||r_rec.granted_role||' is granted to '||GranteeA||', processing...');
      IF (ActionA = 'CREATE' AND NOT IsPredefinedRole(r_rec.granted_role)
          and NOT IsExcludedRole(r_rec.granted_role)) then
        if (NOT RoleCreated(r_rec.granted_role) ) then
          CreateRole(r_rec.granted_role,'it was granted to '||GranteeA);
          MarkRoleAsCreated(r_rec.granted_role);
        end if;
      ELSIF (ActionA = 'GRANT' and NOT IsExcludedRole(r_rec.granted_role)) then
        if (    NOT RoleGranted(RoleA => r_rec.granted_role, ToA => GranteeA)) then
          IF (GenSql) then
            PrintInfo(3,'Granting '||r_rec.granted_role||' to '||GranteeA);
            StartWheneverSqlError;
            PrintMessage('grant '||r_rec.granted_role||' to '||GranteeA||r_rec.admin_option||';');
            -- Revoke unlimited tablespace for RESOURCE and DBA
            SELECT Decode(Count(*),0,'N','Y') INTO UserHasUnlimitedTS FROM dba_sys_privs WHERE grantee = GranteeA;
            IF (r_rec.granted_role IN ('RESOURCE','DBA') AND UserHasUnlimitedTS = 'N' and IsUser(GranteeA)) THEN
              PrintInfo(3,'Revoking UNLIMITED TABLESPACE from '||GranteeA);
              PrintMessage('revoke unlimited tablespace from '||GranteeA||';');
            END IF;
            StopWheneverSqlError;
          ELSE
            PrintMessage('Role '||r_rec.granted_role||' will be granted to '||GranteeA);
          END IF;
          MarkRoleAsGranted(RoleA => r_rec.granted_role, ToA => GranteeA);
        end if;
      ELSIF (ActionA = 'ADDSYSPRIVS' AND NOT IsPredefinedRole(r_rec.granted_role)
             and NOT IsExcludedRole(r_rec.granted_role)) THEN
        if (NOT GrantedSysPrivsToRole(r_rec.granted_role) ) then
          IF (GenSql) then
            PrintInfo(3,'Adding system privileges to role '||r_rec.granted_role, true);
            FOR p_rec IN (SELECT grantee, privilege, Decode(admin_option,'YES',' with admin option','') AS admin_option
                            FROM dba_sys_privs
                            WHERE grantee = r_rec.granted_role
                            order by grantee, privilege) LOOP
              if (NOT IsExcludedSysPriv(p_rec.privilege)) then
                PrintMessage('grant '||p_rec.privilege||' to '||r_rec.granted_role||p_rec.admin_option||';');
              end if;
            END LOOP;
            -- Grants on objects of SYS are not imported in user-import
            -- Should be given to roles in advance to avoid compilation errors due to insufficient privileges
            PrintInfo(3,'Adding object privileges of SYS objects to role '||r_rec.granted_role, true);
            FOR o_rec IN (SELECT owner, table_name, grantee, privilege, Decode(grantable,'YES',' with grant option','') AS grantable
                            FROM dba_tab_privs
                            WHERE grantee = r_rec.granted_role
                            and   owner = 'SYS'
                            ORDER BY grantor, table_name, privilege) LOOP
              PrintMessage('GRANT '||o_rec.privilege||' ON '||o_rec.owner||'.'||o_rec.table_name||
                          ' TO '||r_rec.granted_role||o_rec.grantable||';');
            END LOOP;
          ELSE
            SELECT Count(*) INTO NrGrants FROM dba_sys_privs
              WHERE grantee = r_rec.granted_role;
            IF (NrGrants > 0) then
              PrintMessage(NrGrants||' system privileges will be granted to role '||r_rec.granted_role);
            END IF;
            SELECT Count(*) INTO NrGrants FROM dba_tab_privs
              WHERE grantee = r_rec.granted_role
              and   owner = 'SYS';
            IF (NrGrants > 0) then
              PrintMessage(NrGrants||' object privileges on SYS objects will be granted to role '||r_rec.granted_role);
            END IF;
          END IF;
          MarkGrantedSysprivsToRole(r_rec.granted_role);
        end if;
      ELSIF (ActionA = 'ADDOBJPRIVS' AND NOT IsPredefinedRole(r_rec.granted_role)
             and NOT IsExcludedRole(r_rec.granted_role)) THEN
        if (NOT GrantedObjPrivsToRole(r_rec.granted_role)) then
          IF (GenSql) then
            PrintInfo(3,'Adding object privileges to role '||r_rec.granted_role, true);
            FOR o_rec IN (SELECT owner, table_name, grantee, privilege,
                                Decode(grantable,'YES',' with grant option','') AS grantable
                            FROM dba_tab_privs
                            WHERE grantee = r_rec.granted_role
                            ORDER BY grantor, table_name, privilege) LOOP
              PrintMessage('GRANT '||o_rec.privilege||' ON '||o_rec.owner||'.'||o_rec.table_name||
                          ' TO '||r_rec.granted_role||o_rec.grantable||';');
            END LOOP;
          ELSE
            SELECT Count(*) INTO NrGrants FROM dba_tab_privs
              WHERE grantee = r_rec.granted_role;
            IF (NrGrants > 0) then
              PrintMessage(NrGrants||' object privileges will be granted to role '||r_rec.granted_role);
            END IF;
          END IF;
          MarkGrantedObjprivsToRole(r_rec.granted_role);
        end if;
      elsif (IsExcludedRole(r_rec.granted_role)) then
        PrintDebug(Prefix||'Role '||r_rec.granted_role||' is in list of excluded roles, nothing done');
      ELSE
        PrintDebug(Prefix||'Nothing to do for role '||r_rec.granted_role);
      END IF;
      IF (NOT IsPredefinedRole(r_rec.granted_role) and NOT IsExcludedRole(r_rec.granted_role)) then
        PrintDebug(Prefix||'Now recursively checking '||r_rec.granted_role);
        DoRolesGrantedToUser(r_rec.granted_role, ActionA, LevelA + 1);
      END IF;
    END LOOP;
--  ELSE
--    IF (ActionA = 'CREATE') then
--      select count(distinct granted_role) into NrRoles
--        from dba_role_privs
--        connect by prior granted_role = grantee
--        start with grantee = upper(GranteeA);
--      if (NrRoles > 0) then
--        PrintMessage(NrRoles||' roles will be created for user '||GranteeA);
--      end if;
--    ELSIF (ActionA = 'GRANT') then
--      select count(*) into NrGrants
--        from dba_role_privs
--        connect by prior granted_role = grantee
--        start with grantee = upper(GranteeA);
--      if (NrRoles > 0) then
--        PrintMessage(NrGrants||' grants are needed for the roles of user '||GranteeA);
--      end if;
--    ELSIF (ActionA = 'ADDSYSPRIVS') THEN
--      PrintMessage('Todo...');
--    ELSIF (ActionA = 'ADDOBJPRIVS') THEN
--      PrintMessage('Todo...');
--    end if;
--  END IF;
  PrintDebug(Prefix||'Finished DoRolesGrantedToUser for Grantee='||GranteeA||', Action='||ActionA||', Level '||LevelA);
 EXCEPTION
  WHEN OTHERS THEN
   Raise_application_error(-20000,'Error in DoRolesGrantedToUser for '||GranteeA||' at level '||LevelA,true);
 END;

 ------------------------------------------------------------------------------
 PROCEDURE RolesToWhichObjPrivsAreGranted(GrantorA IN VARCHAR2)
 IS
  -- If the user has granted object privileges to a role, create that role as well
  NrRoles number;
 BEGIN
--  if (NOT GenSql) then
--   select count(distinct grantee) into NrRoles
--     FROM dba_tab_privs
--     WHERE grantor = GrantorA
--     AND   grantee IN (SELECT ROLE FROM dba_roles);
--   if (NrRoles > 0) then
--     PrintMessage('User '||GrantorA||' will grant object privileges to '||NrRoles||' different roles');
--   end if;
--  else
    FOR r_rec IN (SELECT DISTINCT grantee
                    FROM dba_tab_privs
                    WHERE grantor = GrantorA
                    AND   grantee IN (SELECT ROLE FROM dba_roles)
                  ) LOOP
      if (NOT RoleCreated(r_rec.grantee)) then
        CreateRole(r_rec.grantee,GrantorA||' gave obj privs to it');
        MarkRoleAsCreated(r_rec.grantee);
      end if;
    END LOOP;
--  end if;
 END;
 ------------------------------------------------------------------------------
 PROCEDURE CreatePublicSynonyms(UsernameA IN VARCHAR2)
 IS
   NrSyn number;
 BEGIN
  PrintDebug('Entering CreatePublicSynonyms for user '||UsernameA);
  if (NOT GenSql) then
    select count(*) into NrSyn FROM dba_synonyms WHERE owner = 'PUBLIC' AND table_owner = UsernameA;
    if (NrSyn > 0) then
      PrintMessage(NrSyn||' public synonyms refer to user '||UsernameA);
    end if;
  else
    StartWheneverSqlError;
    FOR s_rec IN (SELECT * FROM dba_synonyms WHERE owner = 'PUBLIC' AND table_owner = UsernameA) LOOP
      PrintInfo(3,'Creating public synonym '||UsernameA||'.'||s_rec.synonym_name);
      PrintMessage('CREATE or replace public synonym '||s_rec.synonym_name||' for '||s_rec.table_owner||'.'||s_rec.table_name||';');
    END LOOP;
    StopWheneverSqlError;
  end if;
 END;
 ------------------------------------------------------------------------------
 PROCEDURE CreateDependentTablespaces(UsernameA IN VARCHAR2)
 IS
  u_rec dba_users%ROWTYPE;
  USER_NOT_FOUND EXCEPTION;
 BEGIN
  PrintDebug('Entering CreateDependentTablespaces for user '||UsernameA);
  begin
    SELECT * INTO u_rec FROM dba_users WHERE username = Upper(UsernameA);
  EXCEPTION
    WHEN No_Data_Found THEN RAISE USER_NOT_FOUND;
  END;
  IF (GenSql) THEN PrintInfo(3,'Creating dependent tablespaces for user '||UsernameA, true); END IF;
  FOR t_rec IN (SELECT DISTINCT default_tablespace AS tablespace_name, 'is default TS for '||UsernameA as reason FROM dba_users WHERE username = Upper(UsernameA)
                UNION ALL
                SELECT DISTINCT temporary_tablespace AS tablespace_name, 'is temp TS for '||UsernameA FROM dba_users WHERE username = Upper(UsernameA)
                UNION ALL
                SELECT DISTINCT tablespace_name, 'user '||UsernameA||' has quota on it' FROM dba_ts_quotas WHERE username = Upper(UsernameA)
                UNION all
                SELECT DISTINCT tablespace_name, 'user '||UsernameA||' has data in it' FROM dba_segments WHERE owner = Upper(UsernameA)
               ) loop
   RecreateTablespace(t_rec.tablespace_name,t_rec.reason);
  END LOOP;
 EXCEPTION
  WHEN OTHERS THEN
   Raise_application_error(-20000,'Error in CreateDependentTS for '||UserNameA,true);
 END;
 ------------------------------------------------------------------------------
 procedure CreateContexts(UserNameA in varchar2)
 is
  Stmt varchar2(1024);
  CtxType varchar2(64);
 begin
  PrintDebug('Entering CreateContexts for '||UsernameA);
  IF (GenSql) THEN PrintInfo(3,'Creating contexts for user '||UsernameA, true); end if;
    for c_rec in (select * from dba_context where schema = upper(UsernameA)) loop
      Stmt := 'create context '||c_rec.namespace||' using '||c_rec.schema||'.'||c_rec.package;
      if (NOT DbVersion like '8.%') then
        -- Accessed globally was only introduced in Oracle 9i
        execute immediate 'select type from dba_context where namespace = '''||c_rec.namespace||'''' into CtxType;
        Stmt := Stmt || ' ' || CtxType;
      end if;
      if (GenSql) then
        PrintMessage(Stmt);
      else
        PrintMessage('Context '||c_rec.namespace||' will be created');
      end if;
    end loop;
 end;

 ------------------------------------------------------------------------------
 PROCEDURE CreateOneUser(UsernameA IN VARCHAR2)
 IS
  u_rec dba_users%ROWTYPE;
  USER_NOT_FOUND EXCEPTION;
  NrPrivs number;
 BEGIN
  PrintDebug('Entering CreateOneUser for '||UsernameA);
  begin
    SELECT * INTO u_rec FROM dba_users WHERE username = Upper(UsernameA);
  EXCEPTION
    WHEN No_Data_Found THEN
     PrintDebug('ERROR: User '||UsernameA||' not found in dba_users');
     RAISE USER_NOT_FOUND;
  END;

  if (OptCreateUsers) then
    if (OptDependentTS) THEN
      PrintDebug('Creating dependent TS before creating user '||UsernameA);
      CreateDependentTablespaces(UsernameA);
    end if;

    if (NOT GenSql) then
      PrintMessage('User '||u_rec.username||' will be created');
    else
      IF (IncDropUsers AND NOT IncDropUsersCascade) THEN
        PrintInfo(3,'Dropping user '||u_rec.username);
        PrintMessage('drop user '||u_rec.username||';');
      ELSIF (IncDropUsers AND IncDropUsersCascade) THEN
        PrintInfo(3,'Dropping user '||u_rec.username);
        PrintMessage('drop user '||u_rec.username||' cascade;');
      END IF;

      PrintInfo(3,'Creating user '||u_rec.username);
      StartWheneverSqlError;
      IF (u_rec.password <> 'EXTERNAL') then
        PrintMessage('CREATE USER '||u_rec.username||' identified by values '''||u_rec.password||'''');
      else
        PrintMessage('CREATE USER '||u_rec.username||' identified externally');
      END IF;
      PrintMessage(' default tablespace '||u_rec.default_tablespace);
      PrintMessage(' temporary tablespace '||u_rec.temporary_tablespace);
      PrintMessage(' profile '||u_rec.PROFILE||';');

    end if;
  end if;

  if (OptSetQuotas) then
    IF (GenSql) THEN PrintInfo(3,'Setting quotas for '||UsernameA, true); END IF;
    FOR q_rec IN (SELECT Decode(max_bytes,-1,'UNLIMITED',To_Char( ceil(max_bytes/1024/1024) )||'M' ) AS max_bytes, tablespace_name
                    FROM dba_ts_quotas
                    WHERE username = UsernameA) LOOP
      IF (GenSql) then
        PrintMessage('ALTER USER '||UsernameA||' quota '||q_rec.max_bytes||' on '||q_rec.tablespace_name||';');
      ELSE
        PrintMessage('User '||UsernameA||' will get quotas of '||q_rec.max_bytes||' on '||q_rec.tablespace_name);
      END IF;
    END LOOP;
  end if;

  if (OptSysPrivsUsers) THEN
    PrintDebug('SysPrivs=true, generating grants for system privileges granted to '||UsernameA);
    select count(*) into NrPrivs FROM dba_sys_privs
      WHERE grantee = upper(UsernameA);
    if (NrPrivs > 0 AND GenSql) then
      PrintInfo(3,'Granting '||NrPrivs||' system privileges to user '||UsernameA, true);
      FOR p_rec IN (SELECT grantee, privilege, Decode(admin_option,'YES',' with admin option','') AS admin_option
                      FROM dba_sys_privs
                      WHERE grantee = upper(UsernameA)) LOOP
        if (NOT IsExcludedSysPriv(p_rec.privilege)) then
          PrintMessage('grant '||p_rec.privilege||' to '||p_rec.grantee||p_rec.admin_option||';');
        end if;
      END LOOP;
    elsif (NrPrivs > 0) then
      PrintMessage('User '||UsernameA||' will receive '||NrPrivs||' system privileges directly');
    ELSE
      PrintDebug('No system privileges granted to '||UsernameA);
    end if;
  end if;

  if (OptObjPrivsUsers) then
    PrintDebug('ObjPrivs=true, generating grants for object privileges granted to '||UsernameA);
    select count(*) into NrPrivs FROM dba_tab_privs
      WHERE grantee = Upper(UsernameA);
    if (NrPrivs > 0 AND GenSql) then
      PrintInfo(3,'Granting '||NrPrivs||' object privileges to user '||UsernameA, true);
      FOR s_rec IN (SELECT owner, table_name, grantee, privilege, Decode(grantable,'YES',' with grant option','') AS grantable
                      FROM dba_tab_privs
                      WHERE grantee = Upper(UsernameA)
                      ORDER BY grantor, table_name, privilege) LOOP
        PrintMessage('GRANT '||s_rec.privilege||' ON '||s_rec.owner||'.'||s_rec.table_name||
                    ' TO '||s_rec.grantee||s_rec.grantable||';');
      END LOOP;
    ELSIF (NrPrivs > 0) then
      PrintMessage('User '||UsernameA||' will receive '||NrPrivs||' object privileges');
    ELSE
      PrintDebug('No object privileges granted to '||UsernameA);
    end if;
  end if;

  if (OptPublicSynonyms) THEN
    PrintDebug('PublicSynonyms=true, generating create synonyms for objects of '||UsernameA);
    CreatePublicSynonyms(UsernameA);
  end if;

  if (OptContexts) THEN
    PrintDebug('OptContexts=true, generating create context for packages of '||UsernameA);
    CreateContexts(UsernameA);
  end if;

  StopWheneverSqlError;
  PrintDebug('Finished CreateOneUser for '||UsernameA);
 EXCEPTION
  WHEN USER_NOT_FOUND THEN
   Raise_application_error(-20000,'Error in CreatOneUser: user does not exist: '||UserNameA,true);
  WHEN OTHERS THEN
   Raise_application_error(-20000,'Error in CreatOneUser for '||UserNameA,true);
 END;

 ------------------------------------------------------------------------------
 PROCEDURE RecreateTablespaces(TsListA IN VARCHAR2 DEFAULT null)
 IS
  TmpList VARCHAR2(2000);
  CommaPos NUMBER;
  Cntr NUMBER := 0;
 BEGIN
  IF (GenSql) THEN PrintInfo(2,'Creating tablespaces '||TsListA||' (null=all)'); END IF;
  IF (Trim(TsListA) IS NULL) THEN
   FOR t_rec IN (SELECT tablespace_name FROM dba_tablespaces WHERE tablespace_name NOT IN ('SYSTEM')) loop
    TmpList := TmpList||','||t_rec.tablespace_name;
   END LOOP;
   TmpList := SubStr(TmpList,2);
  ELSE
   TmpList := TsListA;
  END IF;
  WHILE (TmpList IS NOT NULL AND Cntr < 1000) LOOP
   CommaPos := InStr(TmpList,',');
   IF (CommaPos > 0) THEN
    RecreateTablespace( Trim(Upper(SubStr(TmpList,1,CommaPos-1))),'it is in list of requested TS' );
    TmpList := SubStr(TmpList,CommaPos+1);
   else
    RecreateTablespace( Trim(Upper(TmpList)),'it is in list of requested TS' );
    TmpList := NULL;
   END IF;
   Cntr := Cntr + 1;
  END LOOP;
 END;

 ------------------------------------------------------------------------------
 PROCEDURE ViewsOfUser(UserA IN VARCHAR2, GenSqlA IN boolean)
 IS
  NrViews NUMBER;
  ViewText VARCHAR2(20000);
  ViewCollist VARCHAR2(20000);
  NrDep NUMBER;
 BEGIN
  IF (NOT GenSqlA) THEN
    SELECT Count(*) INTO NrViews FROM dba_views WHERE owner = Upper(UserA);
    PrintMessage('User '||UserA||' has '||NrViews||' views');
    NrDep := 0;
    FOR s_rec IN (SELECT referenced_owner, referenced_link_name, Count(*) AS nr_dep
                    FROM dba_dependencies
                    WHERE owner = Upper(UserA)
                    AND   (referenced_owner <> Upper(UserA) OR referenced_owner IS NULL)
                    AND   TYPE = 'VIEW'
                    GROUP BY referenced_owner, referenced_link_name
                    ORDER BY referenced_link_name, referenced_owner) LOOP
      PrintMessage(s_rec.nr_dep||' views have dependencies to '||s_rec.referenced_owner||AddPreIfNotNull(s_rec.referenced_link_name,'@'));
      NrDep := NrDep + s_rec.nr_dep;
    END LOOP;
    IF (NrDep > 0) THEN
      PrintMessage('Note: remote dependencies over database links are not included');
      PrintMessage('');
    END IF;
  ELSE
    PrintInfo(2,'Views for user '||UserA);
    FOR v_rec IN (SELECT owner, view_name FROM dba_views
                    WHERE owner = Upper(UserA)) LOOP
      ViewText := FetchViewText(v_rec.owner, v_rec.view_name);
      ViewColList := FetchViewCollist(v_rec.owner, v_rec.view_name);
      --DbLinks := GetDbLinksFromSqlText(ViewText);
      PrintMessage('CREATE OR REPLACE FORCE VIEW '||v_rec.owner||'.'||v_rec.view_name||' '||
                   '('||ViewCollist||') AS '||ViewText||';');
      PrintMessage('');
    END LOOP;
  END IF;
 END;
 ------------------------------------------------------------------------------
 PROCEDURE SynonymsOwnedByUser(UserA IN VARCHAR2, GenSqlA IN boolean)
 IS
 BEGIN
  IF (NOT GenSqlA) then
    FOR s_rec IN (SELECT table_owner, db_link, Count(*) AS nr_syn
                    FROM dba_synonyms
                    WHERE owner = Upper(UserA)
                    AND   (table_owner <> Upper(UserA) OR table_owner IS NULL)
                    GROUP BY table_owner, db_link
                    ORDER BY db_link, table_owner) LOOP
      PrintMessage('User '||UserA||' has '||s_rec.nr_syn||' synonyms to '||Nvl(s_rec.table_owner,'<default user>')||AddPreIfNotNull(s_rec.db_link,'@'));
    END LOOP;
  ELSE
    PrintInfo(2,'Synonyms for user '||UserA);
    FOR s_rec IN (SELECT *
                    FROM dba_synonyms
                    WHERE owner = Upper(UserA)
                    AND   (table_owner <> Upper(UserA) OR table_owner IS NULL)
                    ORDER BY db_link, table_owner, table_name) LOOP
      PrintMessage('CREATE OR REPLACE SYNONYM '||UserA||'.'||s_rec.synonym_name||
                   ' FOR '||AddPostIfNotNull(s_rec.table_owner,'.')||s_rec.table_name||AddPreIfNotNull(s_rec.db_link,'@')||';');
    END LOOP;
    PrintMessage('');
  END IF;
 END;
 ------------------------------------------------------------------------------
 PROCEDURE Dependencies(UserListA IN VARCHAR2 DEFAULT NULL, GenSqlA IN boolean)
 IS
  UserTab Dbms_Utility.uncl_array;
  UserTabLen NUMBER;
 BEGIN
  dbms_application_info.set_action('Dependencies');
  Dbms_Utility.comma_to_table( UserListA, UserTabLen, UserTab);
  FOR i IN 1 .. UserTabLen LOOP
   PrintInfo(2,'Dependencies for user '||UserTab(i));
   SynonymsOwnedByUser(UserTab(i), GenSqlA => GenSqlA);
   ViewsOfUser(UserTab(i), GenSqlA => GenSqlA);
  END LOOP;
 END;

 ------------------------------------------------------------------------------
 PROCEDURE RecreateUsers
 IS
 BEGIN
  dbms_application_info.set_action('RecreateUsers');
  PrintDebug('Entering RecreateUsers, UserTab.count='||UserTab.count);
  for i in 1 .. UserTab.count LOOP
    CreateOneUser( UserTab(i) );
  END LOOP;
  PrintDebug('Finished RecreateUsers');
 END;

 ------------------------------------------------------------------------------
 PROCEDURE RecreateRoles(UserListA IN VARCHAR2 DEFAULT null)
 IS
 BEGIN
  dbms_application_info.set_action('RecreateRoles');
  PrintDebug('Entering RecreateRoles');
  for i in 1 .. UserTab.count LOOP
    if (OptCreateRoles) THEN
      PrintDebug('CreateRoles=true, processing CREATE for user '||UserTab(i));
      DoRolesGrantedToUser(UserTab(i),'CREATE');
      PrintDebug('CreateRoles=true, also processing RolesToWhichObjPrivsAreGranted for role '||UserTab(i));
      RolesToWhichObjPrivsAreGranted(UserTab(i));
    ELSE
      PrintDebug('CreateRoles=false, not creating roles of user '||UserTab(i));
    end if;
    if (OptSysPrivsRoles) then
      PrintDebug('SysPrivs=true, processing ADDSYSPRIVS for roles of user '||UserTab(i));
      DoRolesGrantedToUser(UserTab(i),'ADDSYSPRIVS');
    ELSE
      PrintDebug('SysPrivs=false, not grant system privs to roles of user '||UserTab(i));
    end if;
    if (OptObjPrivsRoles) then
      PrintDebug('ObjPrivs=true, processing ADDOBJPRIVS for roles of user '||UserTab(i));
      DoRolesGrantedToUser(UserTab(i),'ADDOBJPRIVS');
    ELSE
      PrintDebug('ObjPrivs=false, not grant object privs to roles of user '||UserTab(i));
    end if;
    if (OptGrantRoles) then
      PrintDebug('GrantRoles=true, processing GRANT for roles of user '||UserTab(i));
      DoRolesGrantedToUser(UserTab(i),'GRANT');
    ELSE
      PrintDebug('GrantRoles=false, not granting roles to user '||UserTab(i));
    end if;
  end loop;
  PrintDebug('Finished RecreateRoles');
 end;


 -------------------------------------------------------------------------------
 procedure SetDebug(DebugA in boolean default true)
 is
 begin
  Debug := DebugA;
  PrintDebug('Debug option is enabled');
 end;

 -------------------------------------------------------------------------------
 procedure SetScriptOptions(GenSqlA in boolean default true,
                            LogFileNameA in varchar2 default null,
                            WheneverSqlErrorA in boolean default false,
                            AddInfoA in boolean default true,
                            CheckRoleExistanceA in boolean default false,
                            NrPausesA in number default 0,
                            DocFormatA in varchar2 default 'TXT',
                            IncDropUsersA in boolean default false,
                            IncDropUsersCascadeA in boolean default false,
                            LineSizeA in number default 200
                            )
 is
 begin
  dbms_application_info.set_action('Setting Script Options');
   -- Indicate if a real migrate script should be generated (true) or just
   --  a text file with information about what the migrate script would do
   if (GenSqlA) then GenSql := true;
   else GenSql := false;
   end if;

   LogFileName := LogFileNameA;

   -- Indicate if CREATE statements should be enclosed by WHENEVER SQL commands
   if (WheneverSqlErrorA) then IncludeWheneverSqlError := True;
   else IncludeWheneverSqlError := false;
   end if;

   if (AddInfoA) then AddInfo := True;
   else AddInfo := false;
   end if;

   -- Indicate if the CREATE ROLE statements should be executed 'as is' or
   --  if result should only create roles if they don't exists yet in the target database
   if (CheckRoleExistanceA) then CheckRoleExistance := True;
   else CheckRoleExistance := false;
   end if;

   -- Specify how many pause statements should be included in the output before
   --  running the rest of the script automatically
   if (NrPausesA >= 0) then NrPauses := NrPausesA; else Raise_Application_Error(-20999,'Error in SetScriptOptions: NrPausesA should be >= 0'); end if;

   if (upper(DocFormatA) in ('TXT','HTM')) then DocFormat := upper(DocFormatA);
   else Raise_Application_Error(-20999,'Error in SetScriptOptions: DocFormatA should be TXT or HTM');
   end if;

   -- Generates 'DROP USER' statements before every CREATE USER
   IncDropUsers := IncDropUsersA;

   -- Adds CASCADE to each DROP USER statements
   IncDropUsersCascade := IncDropUsersCascade;

   if (LineSizeA > 0) then
     LineSize := LineSizeA;
   end if;
 end;

 -------------------------------------------------------------------------------
 procedure SetDatafileOptions(SrcSeparatorA in varchar2 default null,
                              DstSeparatorA in varchar2 default null,
                              FilesizeInitialPctA in number default 100,
                              FilesizeAutomaxPctA in number default 100,
                              ForceAutoextendA in boolean default true,
                              DefaultDirectoryA in varchar2 default null,
                              ConvertFilenamesToLowerA in boolean default false,
                              IncDropPermanentTablespacesA in boolean default false,
                              IncIncludeDropTSContentsA in boolean default false,
                              IncDropTemporaryTablespacesA in boolean default false
                              )
 is
 begin
  dbms_application_info.set_action('Setting datafile options');
  if (SrcSeparatorA in ('/','\')) then
    SourceDirectorySeparator := SrcSeparatorA;
  elsif (SrcSeparatorA is not null) then
    Raise_Application_Error(-20999,'Error in SetDatafileOptions: SrcSeparatorA should be / or \');
  end if;

  if (DstSeparatorA in ('/','\')) then
    DestinationDirectorySeparator := DstSeparatorA;
  elsif (DstSeparatorA is not null) then
    Raise_Application_Error(-20999,'Error in SetDatafileOptions: DstSeparatorA should be / or \');
  end if;

  -- Create new datafiles as small files (they will grow during import due to autoextend)
  if (FilesizeInitialPctA > 0) then
    FilesizeInitialPct := FilesizeInitialPctA;
  else
    Raise_Application_Error(-20999,'Error in SetDatafileOptions: FilesizeInitialPctA should be > 0');
  end if;

  -- Specify the generated value of autoextend maxsize as a percentage of the current file size
  if (FilesizeAutomaxPctA > 0) then
    FilesizeAutomaxPct := FilesizeAutomaxPctA;
  else
    Raise_Application_Error(-20999,'Error in SetDatafileOptions: FilesizeAutomaxPctA should be > 0');
  end if;

  -- Force all files to have the autoextend option enabled. If set to false, the
  --  same setting will be used as on the source database
  ForceAutoextend := ForceAutoextendA;

  ConvertFilenamesToLower := ConvertFilenamesToLowerA;

  -- Indicate the directory where all datafiles will be put on the target database
  --  Specify an empty string to keep datafiles in the same directory as the source database
  --  Note: an AddDatafileDirectory may override the target location of the datafile
  DefaultDatafileDirectory := rtrim(DefaultDirectoryA,'\/');

  -- Generate DROP statements for permanent tablespaces
  IncDropPermanentTablespaces := IncDropPermanentTablespacesA;

  -- Adds 'including contents and datafiles' to drop tablespace
  IncIncludeDropTSContents := IncIncludeDropTSContentsA;

  -- Generate DROP statements for temporary tablespaces
  IncDropTemporaryTablespaces := IncDropTemporaryTablespacesA;

 end;

 ------------------------------------------------------------------------------
 PROCEDURE ExcludeTablespace(TablespaceA IN VARCHAR2)
 IS
 begin
  -- Specify which tablespaces from the source database should be excluded for
  --  generating 'create tablespace' statements
  for i in 1 .. IncludedTablespaces.count loop
    if (IncludedTablespaces(i) = TablespaceA) then
      Raise_Application_Error(-20999,'Error: cannot exclude and include the same tablespace: '||TablespaceA);
    end if;
  end loop;
  CreatedTablespaces(CreatedTablespaces.Count+1) := TablespaceA;
 END;

 ------------------------------------------------------------------------------
 PROCEDURE IncludeTablespace(TablespaceA IN VARCHAR2)
 IS
 begin
  -- Specify which tablespaces from the source database should be included for
  --  generating 'create tablespace' statements, even if there are no
  --  dependencies with any user
  for i in 1 .. CreatedTablespaces.count loop
    if (CreatedTablespaces(i) = TablespaceA) then
      Raise_Application_Error(-20999,'Error: cannot exclude and include the same tablespace: '||TablespaceA);
    end if;
  end loop;
  IncludedTablespaces(IncludedTablespaces.Count+1) := TablespaceA;
 END;

 ------------------------------------------------------------------------------
 PROCEDURE ExcludeSysPriv(PrivilegeA IN VARCHAR2)
 IS
 begin
  -- Specify which system privileges from the source database should be excluded for
  --  generating 'grant <system_priv>' statements
  ExcludedSysPrivs(ExcludedSysPrivs.Count+1) := PrivilegeA;
 END;

 ------------------------------------------------------------------------------
 PROCEDURE ExcludeRole(RoleA IN VARCHAR2)
 IS
 begin
  -- Specify which tablespaces from the source database should be excluded for
  --  generating create and grant statements
  ExcludedRoles(ExcludedRoles.Count+1) := RoleA;
 END;

 ------------------------------------------------------------------------------
 PROCEDURE AddDatafileDirectory(IfLikeA IN VARCHAR2, DirA IN VARCHAR2)
 IS
 BEGIN
  -- Change directory path for certain files. Acts as a replace() on the filename:
  -- I.e.: (arg1,arg2) means: if source-datafile like arg1 then directory on the
  --       target database will be arg2 (arg2 should only specify a directory)
   IF (IfLikeA IS NOT NULL) THEN
     DatafileLikeTable(DatafileLikeTable.Count+1) := IfLikeA;
     DatafileDirectoryTable(DatafileDirectoryTable.Count+1) := DirA;
   ELSE
     Raise_Application_Error(-20000,'Cannot call AddDatafileDirectory with first argument NULL');
   END IF;
 EXCEPTION
  WHEN OTHERS THEN
   Raise_Application_Error(-20000,'Error in AddDatafileDirectory for '||IfLikeA||' and '||DirA,TRUE);
 END;

 -------------------------------------------------------------------------------
 PROCEDURE SetUserList(UserListA in varchar2)
 is
  UserTabLen number;
 BEGIN
  dbms_application_info.set_action('Setting userlist');
  PrintDebug('Entering SetUserList');
  UserTab.delete;
  IF (Trim(UserListA) IS NULL) THEN
   -- No users specified, take all users in the database
   FOR u_rec IN (SELECT username FROM dba_users WHERE username NOT IN ('SYS','SYSTEM','SYSMAN','SCHEDULER_ADMIN','MGMT_USER','MGMT_VIEW','DBSNMP','WMSYS')) loop
    UserTab(UserTab.count+1) := u_rec.username;
   END LOOP;
  ELSE
    Dbms_Utility.comma_to_table(UserListA, UserTabLen, UserTab);
    for i in 1 .. UserTab.count LOOP
     if (UserTab(i) is null) then UserTab.delete(i); end if;
    end loop;
  END IF;
  PrintDebug('Found '||UserTab.count||' users to be processed, leaving SetUserList');
 end;
 -------------------------------------------------------------------------------
 procedure SetCreateOptions(CreateUsers in boolean,
                            SysPrivsUsers in boolean,
                            ObjPrivsUsers in boolean,
                            DependentTS in boolean,
                            PublicSynonyms in boolean,
                            SetQuotas in boolean,
                            CreateRoles in boolean,
                            SysPrivsRoles in boolean,
                            ObjPrivsRoles in boolean,
                            GrantRoles in boolean,
                            Contexts in boolean)
 is
 begin
  dbms_application_info.set_action('Setting Create Options');
  OptCreateUsers := CreateUsers;
  OptSysPrivsUsers := SysPrivsUsers;
  OptObjPrivsUsers := ObjPrivsUsers;
  OptDependentTS := DependentTS;
  OptPublicSynonyms := PublicSynonyms;
  OptSetQuotas := SetQuotas;
  OptCreateRoles := CreateRoles;
  OptSysPrivsRoles := SysPrivsRoles;
  OptObjPrivsRoles := ObjPrivsRoles;
  OptGrantRoles := GrantRoles;
  OptContexts := Contexts;
 end;

 -------------------------------------------------------------------------------
 procedure SetCreateOptions(PrePostImportA in varchar2)
 is
 begin
  dbms_application_info.set_action('Setting Create Options');
  if (upper(PrePostImportA) = 'PRE') then
   --Post-import: create all the necessary sql to be executed before the import:
   SetCreateOptions(CreateUsers=>true, SysPrivsUsers=>true, ObjPrivsUsers=>false,
                    DependentTS=>true, PublicSynonyms=>false, SetQuotas=>true,
                    CreateRoles=>true, SysPrivsRoles=>true, ObjPrivsRoles=>false,
                    GrantRoles=>true, Contexts=>false);
  elsif (upper(PrePostImportA) = 'POST') then
   --Post-import: create all the necessary sql to be executed after the import:
   SetCreateOptions(CreateUsers=>false, SysPrivsUsers=>false, ObjPrivsUsers=>true,
                    DependentTS=>false, PublicSynonyms=>true, SetQuotas=>false,
                    CreateRoles=>false, SysPrivsRoles=>false, ObjPrivsRoles=>true,
                    GrantRoles=>false, Contexts=>true);
  else
    Raise_Application_Error(-20999,'Error in SetCreateOptions: PrePostImportA should be PRE or POST');
  end if;
 end;
 ------------------------------------------------------------------------------
 procedure BigBanner(MsgA in varchar2)
 is
 begin
  PrintMessage('--='||lpad('=',length(MsgA),'='));
  PrintMessage('-- '||MsgA);
  PrintMessage('--='||lpad('=',length(MsgA),'='));
 end;
 ------------------------------------------------------------------------------
 PROCEDURE Initialize
 IS
 BEGIN
  dbms_application_info.set_action('Initializing');
  Dbms_Output.ENABLE(1000000);
  PrintMessage('whenever oserror exit');
  SELECT NAME INTO DbName FROM v$database;
  PrintMessage('');
  PrintMessage('-- Script for database '||DbName||', generated at '||To_Char(SYSDATE,'DD-Mon-YYYY HH24:MI:SS'));
  PrintMessage('set feedback off linesize 1000 trimspool on');
  PrintMessage('set serveroutput on format wrapped');
  PrintMessage('');
  PrintMessage('-- This script can recreate users, roles, tablespaces, etc...');
  PrintMessage('-- It can be used before and after a user-export/import (exp owner=...)');
  PrintMessage('-- Please verify the script manually before running it');
  PrintMessage('-- Use of this script is at your own risk');
  PrintMessage('');
  if (LogFileName is not null) then
    PrintMessage('spool '||LogFileName);
  end if;
  SELECT Value INTO DbBlockSize FROM v$parameter WHERE NAME = 'db_block_size';
  select version into DbVersion from v$instance;
  CreatedRoles.DELETE;
  GrantedSysPrivsRoles.DELETE;
  GrantedObjPrivsRoles.DELETE;
  GrantedRoles.DELETE;
  PausesPrinted := 0;
  QueuedMessage := '';

  if (SourceDirectorySeparator is null) then
    DECLARE
      NrSlash NUMBER := 0;
      NrBack  NUMBER := 0;
    BEGIN
      FOR n_rec IN (SELECT NAME FROM v$datafile) LOOP
        FOR i IN 1 .. Length(n_rec.NAME) LOOP
          IF (SubStr(n_rec.NAME,i,1) = '/') THEN NrSlash := NrSlash + 1; END IF;
          IF (SubStr(n_rec.NAME,i,1) = '\') THEN NrBack  := NrBack  + 1; END IF;
        END LOOP;
      END LOOP;
      IF (NrSlash > 0) THEN
        SourceDirectorySeparator := '/';
        PrintDebug('Platform is Unix, SourceDirectorySeparator = /');
      ELSE
        SourceDirectorySeparator := '\';
        PrintDebug('Platform is Windows, SourceDirectorySeparator = \');
      END IF;
    END;
  end if;
  if (DestinationDirectorySeparator is null) then
    DestinationDirectorySeparator := SourceDirectorySeparator;
  end if;

 END;

 ------------------------------------------------------------------------------
 PROCEDURE Finalize
 IS
 BEGIN
  if (LogFileName is not null) then
    PrintMessage('spool off');
  end if;
  PrintMessage('set feedback on');
 end;

 -------------------------------------------------------------------------------
 procedure Run(BigBannerA in varchar2 default null)
 is
 begin
  if (BigBannerA is not null) then
    BigBanner('START OF '||BigBannerA);
  end if;
  Initialize;
  DoVerifyTargetDatabase;
  for i in 1 .. IncludedTablespaces.count loop
    RecreateTablespace(IncludedTablespaces(i),'it was explicitly included');
  end loop;
  RecreateUsers;
  RecreateRoles;
  Finalize;
  if (BigBannerA is not null) then
    BigBanner('END OF '||BigBannerA);
  end if;
  PrintMessage('');
  PrintMessage('');
  PrintMessage('');
  dbms_application_info.set_action('Finished Run');
 end;

 -------------------------------------------------------------------------------
 procedure Reset
 is
 begin
  -- SetDebug
  Debug := false;
  -- VerifyTargetDatabase
  OptVerifyDbName := null;
  OptVerifyHostName := null;
  OptVerifyInstanceName := null;
  OptVerifyVersionLike := null;
  -- SetScriptOptions
  GenSql := true;
  LogFileName := null;
  IncludeWheneverSqlError := true;
  NrPauses := 1;
  DocFormat := 'TXT';
  AddInfo := TRUE;
  IncDropUsers := FALSE;
  IncDropUsersCascade := FALSE;
  CheckRoleExistance := TRUE;
  LineSize := 200;
  -- SetDatafileOptions
  SourceDirectorySeparator := '';
  DestinationDirectorySeparator := '';
  DefaultDatafileDirectory := '';
  ConvertFilenamesToLower := TRUE;
  IncDropPermanentTablespaces := FALSE;
  IncIncludeDropTSContents := FALSE;
  IncDropTemporaryTablespaces := FALSE;
  ForceAutoextend := FALSE;
  FilesizeInitialPct := 100;
  FilesizeAutomaxPct := 100;
  FilesizeAutomaxMaxKb := 33554416;
  ForceAutoallocate := TRUE;
  -- SetCreateOptions
  OptCreateUsers := true;
  OptSysPrivsUsers := true;
  OptObjPrivsUsers := false;
  OptDependentTS := true;
  OptPublicSynonyms := false;
  OptSetQuotas := true;
  OptCreateRoles := true;
  OptSysPrivsRoles := true;
  OptObjPrivsRoles := false;
  OptGrantRoles := true;
  OptContexts := false;
  -- ExcludeTablespace
  CreatedTablespaces.delete;
  -- IncludeTablespace
  IncludedTablespaces.delete;
  -- ExcludeSysPriv
  ExcludedSysPrivs.delete;
  -- ExcludeRole
  ExcludedRoles.delete;
  -- AddDatafileDirectory
  DatafileLikeTable.delete;
  DatafileDirectoryTable.delete;
  -- SetUserList
  UserTab.delete;

  -- Internal
  CreatedRoles.delete;
  GrantedSysPrivsRoles.delete;
  GrantedObjPrivsRoles.delete;
  GrantedRoles.delete;
  PausesPrinted := 0;
  QueuedMessage := '';
 end;

 ------------------------------------------------------------------------------
 procedure CORP
 is
 begin
   SetDebug(false);

   VerifyTargetDatabase('CORP', InstanceNameA => 'CORP', HostNameA => 'ANTILOPE', VersionLikeA => '10.2.0.3%');
   SetScriptOptions(GenSqlA => true,
                    LogFileNameA => 'PreImportCORP.log',
                    WheneverSqlErrorA => false,
                    AddInfoA => true,
                    CheckRoleExistanceA => true,
                    NrPausesA => 0,
                    LineSizeA => 150);

   -- Indicate the file system type for the source and destination database:
   SetDatafileOptions(SrcSeparatorA => '\',
                      DstSeparatorA => '\',
                      FilesizeInitialPctA => 1,
                      FilesizeAutomaxPctA => 1000,
                      ForceAutoextendA => true,
                      DefaultDirectoryA => 'E:\Oracle\Oradata\CORP');

   ExcludeTablespace('TEMP');
   ExcludeTablespace('DRSYS');
   ExcludeTablespace('RBS');
   ExcludeTablespace('USERS');
   IncludeTablespace('CIM_DATA');
   ExcludeSysPriv('ADMINISTER RESOURCE MANAGER');  -- Does not exist in 10g
   ExcludeRole('SNMPAGENT');                       -- Does not exist in 10g

   AddDatafileDirectory('%INDEX%','F:\ORACLE\ORADATA\CORP');

   SetUserList('CIM,CORP');
   SetCreateOptions(PrePostImportA => 'PRE');
   Run('PRE-IMPORT STATEMENTS for CORP (40_PreImportCORP.sql)');

   SetCreateOptions(PrePostImportA => 'POST');
   SetScriptOptions(LogFileNameA => 'PostImportCORP.log');
   Run('POST-IMPORT STATEMENTS for CORP (60_PostImportCORP.sql)');
 end;

 ------------------------------------------------------------------------------
 procedure MDB
 is
 begin
   SetDebug(false);

   VerifyTargetDatabase('MDB', InstanceNameA => 'MDB', HostNameA => 'ANTILOPE', VersionLikeA => '10.2.0.3%');
   SetScriptOptions(GenSqlA => true,
                    LogFileNameA => 'PreImportMDB.log',
                    WheneverSqlErrorA => false,
                    AddInfoA => true,
                    CheckRoleExistanceA => true,
                    NrPausesA => 0,
                    LineSizeA => 150);

   -- Indicate the file system type for the source and destination database:
   SetDatafileOptions(SrcSeparatorA => '\',
                      DstSeparatorA => '\',
                      FilesizeInitialPctA => 1,
                      FilesizeAutomaxPctA => 120,
                      ForceAutoextendA => true,
                      DefaultDirectoryA => 'F:\Oracle\Oradata\MDB');

   ExcludeTablespace('TEMP');
   ExcludeTablespace('DRSYS');
   ExcludeTablespace('RBS');
   ExcludeTablespace('USERS');
   ExcludeSysPriv('ADMINISTER RESOURCE MANAGER');  -- Does not exist in 10g
   ExcludeRole('SNMPAGENT');                       -- Does not exist in 10g

   AddDatafileDirectory('%INDEX%','E:\ORACLE\ORADATA\MDB');

   SetUserList('BVDMDB_SET_MNGT,BVDMDBIMPORT,BVDMDB');
   SetCreateOptions(PrePostImportA => 'PRE');
   Run('PRE-IMPORT STATEMENTS for MDB (40_PreImportMDB.sql)');

   SetCreateOptions(PrePostImportA => 'POST');
   Run('POST-IMPORT STATEMENTS for MDB (60_PostImportMDB.sql)');
 end;

 ------------------------------------------------------------------------------
 procedure MDBW
 is
 begin
  SetDebug(false);

  VerifyTargetDatabase('MDBW', InstanceNameA => 'MDBW', HostNameA => 'ANTILOPE', VersionLikeA => '10.2.0.3%');
  SetScriptOptions(GenSqlA => true,
                    LogFileNameA => 'PreImportMDBW.log',
                    WheneverSqlErrorA => false,
                    AddInfoA => true,
                    CheckRoleExistanceA => true,
                    NrPausesA => 0,
                    LineSizeA => 150);

   -- Indicate the file system type for the source and destination database:
   SetDatafileOptions(SrcSeparatorA => '\',
                      DstSeparatorA => '\',
                      FilesizeInitialPctA => 1,
                      FilesizeAutomaxPctA => 120,
                      ForceAutoextendA => true,
                      DefaultDirectoryA => 'F:\Oracle\Oradata\MDBW');

   ExcludeTablespace('TEMP');
   ExcludeTablespace('DRSYS');
   ExcludeTablespace('RBS');
   ExcludeTablespace('USERS');
   ExcludeSysPriv('ADMINISTER RESOURCE MANAGER');  -- Does not exist in 10g
   ExcludeRole('SNMPAGENT');                       -- Does not exist in 10g
   ExcludeRole('JAVADEBUGPRIV');
   ExcludeRole('JAVAIDPRIV');
   ExcludeRole('JAVAUSERPRIV');
   ExcludeRole('JAVASYSPRIV');

   AddDatafileDirectory('%INDEX%','E:\ORACLE\ORADATA\MDBW');

   SetUserList('BVDMDB_SET_MNGT,BVDMDBIMPORT,BVDMDB');
   SetCreateOptions(PrePostImportA => 'PRE');
   Run('PRE-IMPORT STATEMENTS for MDBW (40_PreImportMDBW.sql)');

   SetCreateOptions(PrePostImportA => 'POST');
   Run('POST-IMPORT STATEMENTS for MDBW (60_PostImportMDBW.sql)');
 end;

 ------------------------------------------------------------------------------
 procedure BORP
 is
 begin
   SetDebug(false);

   VerifyTargetDatabase('BORP', InstanceNameA => 'BORP', HostNameA => 'ANTILOPE', VersionLikeA => '10.2.0.3%');
   SetScriptOptions(GenSqlA => true,
                    LogFileNameA => 'PreImportBORP.log',
                    WheneverSqlErrorA => false,
                    AddInfoA => true,
                    CheckRoleExistanceA => true,
                    NrPausesA => 0,
                    LineSizeA => 150);

   -- Indicate the file system type for the source and destination database:
   SetDatafileOptions(SrcSeparatorA => '\',
                      DstSeparatorA => '\',
                      FilesizeInitialPctA => 1,
                      FilesizeAutomaxPctA => 120,
                      ForceAutoextendA => true,
                      DefaultDirectoryA => 'E:\Oracle\Oradata\BORP');

   ExcludeTablespace('TEMP');
   ExcludeTablespace('DRSYS');
   ExcludeTablespace('RBS');
   ExcludeTablespace('USERS');
   ExcludeSysPriv('EXTENDS ANY TYPE');  -- Does not exist in 10g
   ExcludeRole('SNMPAGENT');                       -- Does not exist in 10g
--   ExcludeRole('JAVADEBUGPRIV');
--   ExcludeRole('JAVAIDPRIV');
--   ExcludeRole('JAVAUSERPRIV');
--   ExcludeRole('JAVASYSPRIV');

   AddDatafileDirectory('%INDEX%','F:\ORACLE\ORADATA\BORP');

   SetUserList('BORP,CACC,CADEV,CDEV,CPDEV,CPRD,CPRDEV,MACC,MDEV,MPRD,PRACC,PRDEV,PRPRD,QM,QMEUA,QM_1,QM_2,QM_BORP,RMB,SACC,SDEV,SPRD');
   SetCreateOptions(PrePostImportA => 'PRE');
   Run('PRE-IMPORT STATEMENTS for BORP (40_PreImportBORP.sql)');

   SetCreateOptions(PrePostImportA => 'POST');
   Run('POST-IMPORT STATEMENTS for BORP (60_PostImportBORP.sql)');
 end;

 ------------------------------------------------------------------------------
 procedure CORPSTAT
 is
 begin
   SetDebug(false);

   VerifyTargetDatabase('CORP', InstanceNameA => 'CORP', HostNameA => 'ANTILOPE', VersionLikeA => '10.2.0.3%');
   SetScriptOptions(GenSqlA => true,
                    LogFileNameA => 'PreImportCORPStat.log',
                    WheneverSqlErrorA => false,
                    AddInfoA => true,
                    CheckRoleExistanceA => true,
                    NrPausesA => 0,
                    LineSizeA => 150);

   -- Indicate the file system type for the source and destination database:
   SetDatafileOptions(SrcSeparatorA => '\',
                      DstSeparatorA => '\',
                      FilesizeInitialPctA => 1,
                      FilesizeAutomaxPctA => 1000,
                      ForceAutoextendA => true,
                      DefaultDirectoryA => 'E:\Oracle\Oradata\CORP');

   ExcludeTablespace('TEMP');
   ExcludeTablespace('DRSYS');
   ExcludeTablespace('RBS');
   ExcludeTablespace('USERS');
   ExcludeSysPriv('ADMINISTER RESOURCE MANAGER');  -- Does not exist in 10g
   ExcludeRole('SNMPAGENT');                       -- Does not exist in 10g

   AddDatafileDirectory('%INDEX%','F:\ORACLE\ORADATA\CORP');

   SetUserList('STAT');
   SetCreateOptions(PrePostImportA => 'PRE');
   Run('PRE-IMPORT STATEMENTS for CORP (XX_PreImportCORPStat.sql)');

   SetCreateOptions(PrePostImportA => 'POST');
   SetScriptOptions(LogFileNameA => 'PostImportCORPStat.log');
   Run('POST-IMPORT STATEMENTS for CORP (XX_PostImportCORPStat.sql)');
 end;

 ------------------------------------------------------------------------------
 procedure ZINT
 is
 begin
   SetDebug(false);

   VerifyTargetDatabase('TRUDBA', InstanceNameA => 'TRUDBA', HostNameA => 'trudba', VersionLikeA => '9.2.0%');
   SetScriptOptions(GenSqlA => true,
                    LogFileNameA => 'PreImportZINT.log',
                    WheneverSqlErrorA => false,
                    AddInfoA => true,
                    CheckRoleExistanceA => true,
                    NrPausesA => 0,
                    LineSizeA => 150);

   -- Indicate the file system type for the source and destination database:
   SetDatafileOptions(SrcSeparatorA => '/',
                      DstSeparatorA => '\',
                      FilesizeInitialPctA => 1,
                      FilesizeAutomaxPctA => 1000,
                      ForceAutoextendA => true,
                      DefaultDirectoryA => 'I:\Oracle\Oradata\ZINT');

   ExcludeTablespace('TEMP');
   ExcludeTablespace('RBS');
   ExcludeTablespace('USERS');

   SetUserList('ZINT');
   SetCreateOptions(PrePostImportA => 'PRE');
   Run('PRE-IMPORT STATEMENTS for ZINT (XX_PreImportCORPStat.sql)');

   SetCreateOptions(PrePostImportA => 'POST');
   SetScriptOptions(LogFileNameA => 'PostImportCORPStat.log');
   Run('POST-IMPORT STATEMENTS for ZINT (XX_PostImportCORPStat.sql)');
 end;

 ------------------------------------------------------------------------------
begin
 dbms_application_info.set_module('RecreateUsers','Initializing');
 Reset;
END gdp$uptime_migration;
/
