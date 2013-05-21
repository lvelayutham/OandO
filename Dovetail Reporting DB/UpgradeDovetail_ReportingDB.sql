
------------------------------------------------------------------------------
USE [Dovetail_Reporting]
go

/****** Object:  StoredProcedure [dbo].[spRunFolderScripts]    Script Date: 06/05/2012 13:57:20 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spRunFolderScripts]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spRunFolderScripts]
GO

CREATE PROCEDURE spRunFolderScripts
	@ScriptPath VARCHAR(1000),
	@FolderName VARCHAR(255)
AS
BEGIN
  DECLARE @vFileName            VARCHAR(200),
		  @vSQLStmt             VARCHAR(4000),
		  @instancename			nvarchar(256),
		  @FolderPath			VARCHAR(2048),
		  @err_msg				VARCHAR(2048)

  set nocount on

  CREATE TABLE #SQLFiles1 ( SQLFileName VARCHAR(2000))
  CREATE TABLE #SQLOutput ( script varchar(1200),  msg VARCHAR(max))

  SET @FolderPath = 'dir /b "' + @ScriptPath + @FolderName + '\*.sql"'

  INSERT INTO #SQLFiles1
  EXECUTE master.dbo.xp_cmdshell @FolderPath

  DECLARE cFiles1 CURSOR LOCAL FOR
    SELECT DISTINCT [SQLFileName]
    FROM #SQLFiles1
    WHERE [SQLFileName] IS NOT NULL AND
          [SQLFileName] != 'NULL'
    ORDER BY [SQLFileName]

  select @instancename = cast(serverproperty('servername') as nvarchar(256))
  print @instancename

  OPEN cFiles1
  FETCH NEXT FROM cFiles1 INTO @vFileName
  WHILE @@FETCH_STATUS = 0
  BEGIN
    SET @vSQLStmt = 'master.dbo.xp_cmdshell ''sqlcmd -S ' + @instancename + ' -d Dovetail_Reporting -i "' + @ScriptPath + @FolderName + '\' + @vFileName + '"'''
    
    insert #SQLOutput (script, msg)
	SELECT @ScriptPath + @FolderName + '\' + @vFileName,'--> Running  ' + @vSQLStmt

    insert #SQLOutput (msg)
    EXECUTE (@vSQLStmt)

    update #SQLOutput
    set		script = isnull(script, @ScriptPath + @FolderName + '\' + @vFileName)

    FETCH NEXT FROM cFiles1 INTO @vFileName
  END

  CLOSE cFiles1
  DEALLOCATE cFiles1

  select [output] = msg from #SQLOutput where msg is not null and msg not like '(% rows affected)'

  DECLARE cOutput CURSOR LOCAL FOR
    SELECT DISTINCT script
    FROM #SQLOutput
    WHERE msg like '%msg%level%state%'

  OPEN cOutput
  FETCH NEXT FROM cOutput INTO @FolderPath
  WHILE @@FETCH_STATUS = 0
  BEGIN

    select @err_msg = 'Error running: ' + @FolderPath

    RAISERROR (@err_msg, 16, 1);

    FETCH NEXT FROM cOutput INTO @FolderPath
  END

  CLOSE cOutput
  DEALLOCATE cOutput

END
GO

------------------------------------------------------------------------------
USE [Dovetail_Reporting]
go

DECLARE @ScriptPath VARCHAR(1024) -- Drive letter, full path, and trailing slash
SET @ScriptPath = 'C:\Development\Dovetail Reporting DB\UpgradeScripts\'

EXEC spRunFolderScripts @ScriptPath, '3.3.1'


