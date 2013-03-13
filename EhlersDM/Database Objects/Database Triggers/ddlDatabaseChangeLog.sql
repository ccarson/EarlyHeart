CREATE TRIGGER  ddlDatabaseChangeLog
            ON  DATABASE
           FOR  DDL_DATABASE_LEVEL_EVENTS
AS
/*
************************************************************************************************************************************

    Trigger:    ddlDatabaseTriggerLog
     Author:    Microsoft ( AdventureWorks )
    Purpose:    captures DDL changes on permanent database record


    Revision History:

    revisor     date            description
    --------    ----------      ----------------------------------
    ccarson     ###DATE###      adapted for Ehlers

    Notes:
    This trigger must be built with QUOTED_IDENTIFIER set to ON, otherwise XML processing functions will not work

************************************************************************************************************************************
*/
BEGIN

    SET NOCOUNT ON ;

    DECLARE @EventDate      AS  DATETIME2(7)
          , @Event          AS  SYSNAME
          , @TSQL           AS  NVARCHAR(MAX)
          , @EventXML       AS  XML
          , @DatabaseName   AS  SYSNAME
          , @SchemaName     AS  SYSNAME
          , @Object         AS  SYSNAME
          , @Host           AS  SYSNAME
          , @ipAddress      AS  VARCHAR(48)
          , @Program        AS  SYSNAME
          , @NTUserName     AS  SYSNAME ;

    SELECT  @EventXML = EVENTDATA() ; 
          
    SELECT  @EventDate    = @EventXML.value('(/EVENT_INSTANCE/PostTime)[1]', 'DATETIME2')
          , @Event        = @EventXML.value('(/EVENT_INSTANCE/EventType)[1]', 'SYSNAME')
          , @TSQL         = @EventXML.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(MAX)')
          , @DatabaseName = DB_NAME()
          , @SchemaName   = @EventXML.value('(/EVENT_INSTANCE/SchemaName)[1]', 'SYSNAME')
          , @Object       = @EventXML.value('(/EVENT_INSTANCE/ObjectName)[1]', 'SYSNAME') ;

    SELECT  @Host       = s.host_name
          , @ipAddress  = c.client_net_address
          , @Program    = s.program_name
          , @NTUserName = s.nt_user_name
      FROM  sys.dm_exec_connections AS c
INNER JOIN  sys.dm_exec_sessions    AS s
        ON  s.session_id = c.session_id
     WHERE  s.session_id = @@SPID ;

    INSERT  Meta.DatabaseChangeLog
    SELECT  EventDate    = @EventDate
          , Event        = @Event
          , TSQL         = @TSQL
          , EventXML     = @EventXML
          , DatabaseName = @DatabaseName
          , SchemaName   = @SchemaName
          , Object       = @Object
          , Host         = @Host
          , IPAddress    = @ipAddress
          , Program      = @Program
          , NTUserName   = @NTUserName ;

END
GO
