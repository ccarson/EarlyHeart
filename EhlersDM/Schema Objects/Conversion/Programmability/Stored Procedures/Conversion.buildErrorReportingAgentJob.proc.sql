CREATE PROCEDURE Conversion.buildErrorReportingAgentJob ( @productionServer AS SYSNAME
                                                        , @jobOwner         AS SYSNAME )
AS
/*
************************************************************************************************************************************

  Procedure:    Conversion.buildDataConversionAgentJob
     Author:    Chris Carson
    Purpose:    adds Ehlers Data Conversion Job on server

    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created
    ccarson         ###DATE###          revised error reporting


    Logic Summary:
    1)  Set job name based on databaseName ( non-production servers only )
    2)  Drop existing job
    3)  Check for changes, skip to next process if none
    4)  load records where IssueCallID == 0, these are INSERTs
    5)  load records where IssueCallID != 0, these are UPDATEDs
    6)  Throw error if no records are loaded
    7)  MERGE #processCallsData with dbo.IssueCall
    8)  Reset CONTEXT_INFO to re-enable converted table triggers
    9)  Print control totals

    Notes:
    @codeBlockNum 02  -- Any proc that deletes and rebuilds a SQL Agent job MUST set the @jobID to NULL after deleting
                         the existing job.  If the @jobID is not reset to NULL, job will throw the following:
                         Error 14274 : "Cannot add, update, or delete a job that originated from an MSX server."

************************************************************************************************************************************
*/
BEGIN
BEGIN TRY
    SET NOCOUNT     ON ;
    SET XACT_ABORT  ON ;

    DECLARE @localTransaction   AS BIT ;

    IF  @@TRANCOUNT = 0
    BEGIN
        SET @localTransaction = 1 ;
        BEGIN TRANSACTION localTransaction ;
    END

    DECLARE @codeBlockNum       AS INT
          , @codeBlockDesc      AS SYSNAME
          , @codeBlockDesc01    AS SYSNAME  = 'SELECT job name based on databaseName ( non-production servers only )'
          , @codeBlockDesc02    AS SYSNAME  = 'Drop existing conversion job'
          , @codeBlockDesc03    AS SYSNAME  = 'EXECUTE msdb.dbo.sp_add_category'
          , @codeBlockDesc04    AS SYSNAME  = 'EXECUTE msdb.dbo.sp_add_job for Data Conversion'
          , @codeBlockDesc05    AS SYSNAME  = 'INSERT job steps data into temp storage'
          , @codeBlockDesc06    AS SYSNAME  = 'SELECT current job step data from temp storage'
          , @codeBlockDesc07    AS SYSNAME  = 'EXECUTE msdb.dbo.sp_add_jobstep using temp storage'
          , @codeBlockDesc08    AS SYSNAME  = 'DELETE current job step data from temp storage'
          , @codeBlockDesc09    AS SYSNAME  = 'Add job schedule every two minutes daily between 8:00AM and 7:00PM'
          , @codeBlockDesc10    AS SYSNAME  = 'Set starting job step'
          , @codeBlockDesc11    AS SYSNAME  = 'Add job to server' ;



    DECLARE @jobID              AS BINARY (16)  = NULL
          , @jobName            AS SYSNAME
          , @stepName           AS SYSNAME
          , @command            AS NVARCHAR (MAX)
          , @commandParam       AS NVARCHAR (MAX)
          , @rc                 AS INT = 0 ;

    DECLARE @jobSteps           AS TABLE ( StepName     SYSNAME
                                         , CommandText  NVARCHAR (MAX) ) ;



/**/SELECT  @codeBlockNum = 01, @codeBlockDesc = @codeBlockDesc01 ; -- SELECT job name based on databaseName ( non-production servers only )
    IF  @@SERVERNAME = @productionServer
        SELECT @jobName = 'Ehlers Error Reporting' ;
    ELSE
        SELECT @jobName = 'Ehlers Error Reporting - ' + DB_NAME() ;



/**/SELECT  @codeBlockNum = 02, @codeBlockDesc = @codeBlockDesc02 ; -- Drop existing conversion job
    SELECT  @jobID = job_id FROM msdb.dbo.sysjobs_view WHERE name = @jobName ;

    IF  @jobID IS NOT NULL
    BEGIN
        EXECUTE msdb.dbo.sp_delete_job @job_id = @jobID, @delete_unused_schedule = 0 ;
        SELECT  @jobID = NULL ;
    END



/**/SELECT  @codeBlockNum = 03, @codeBlockDesc = @codeBlockDesc03 ; -- EXECUTE msdb.dbo.sp_add_category
    IF NOT EXISTS ( SELECT name FROM msdb.dbo.syscategories WHERE name = N'EhlersDataConversion' AND category_class = 1 )
    BEGIN
        EXECUTE @rc = msdb.dbo.sp_add_category @class = N'JOB'
                                             , @type  = N'LOCAL'
                                             , @name  = N'EhlersDataConversion' ;
    END



/**/SELECT  @codeBlockNum = 04, @codeBlockDesc = @codeBlockDesc04 ; -- EXECUTE msdb.dbo.sp_add_job for Data Conversion
    EXECUTE @rc = msdb.dbo.sp_add_job @job_name              = @jobName
                                    , @enabled               = 1
                                    , @notify_level_eventlog = 0
                                    , @notify_level_email    = 0
                                    , @notify_level_netsend  = 0
                                    , @notify_level_page     = 0
                                    , @delete_level          = 0
                                    , @description           = N'Create exception reports for invalid legacy data.'
                                    , @category_name         = N'EhlersDataConversion'
                                    , @owner_login_name      = @jobOwner
                                    , @job_id                = @jobID OUTPUT ;



/**/SELECT  @codeBlockNum = 05, @codeBlockDesc = @codeBlockDesc05 ; -- INSERT job steps data into temp storage
    INSERT  @jobSteps( StepName, CommandText )
    VALUES  ( N'Execute reportLocalAttorneyErrors'  , N'Conversion.reportLocalAttorneyErrors' )
          , ( N'Execute reportClientCPAErrors'      , N'Conversion.reportClientCPAErrors' )
          , ( N'Execute reportIssuesErrors'         , N'Conversion.reportIssuesErrors' )
          , ( N'Execute reportBondAttorneyErrors'   , N'Conversion.reportBondAttorneyErrors' ) ;



/**/SELECT  @codeBlockNum = 06, @codeBlockDesc = @codeBlockDesc06 ; -- SELECT current job step data from temp storage
    WHILE EXISTS ( SELECT 1 FROM @jobSteps )
    BEGIN
        SELECT  TOP 1
                @stepname = StepName
              , @command   = N'sqlcmd -E -d $(DatabaseName) -Q "EXECUTE ' + CommandText + N' ;" -b'
          FROM  @jobSteps ;



/**/SELECT  @codeBlockNum = 07, @codeBlockDesc = @codeBlockDesc07 ; -- EXECUTE msdb.dbo.sp_add_jobstep using temp storage
        EXECUTE msdb.dbo.sp_add_jobstep @job_id = @jobId
                                      , @step_name            = @stepName
                                      , @cmdexec_success_code = 0
                                      , @on_success_action    = 3
                                      , @on_success_step_id   = 0
                                      , @subsystem            = N'CmdExec'
                                      , @command              = @command
                                      , @flags                = 32 ;



/**/SELECT  @codeBlockNum = 08, @codeBlockDesc = @codeBlockDesc08 ; -- DELETE current job step data from temp storage
        DELETE  @jobSteps WHERE StepName = @stepName ;

    END



/**/SELECT  @codeBlockNum = 09, @codeBlockDesc = @codeBlockDesc09 ; -- Add job schedule -- job should execute every five hours daily between 7:00AM and 5:00PM
        IF EXISTS ( SELECT 1 FROM msdb.dbo.sysschedules WHERE name = 'Ehlers Error Reporting Schedule' )
            EXECUTE @rc = msdb.dbo.sp_attach_schedule @job_id=@jobID, @schedule_name='Ehlers Error Reporting Schedule' ;
        ELSE
            EXECUTE @rc = msdb.dbo.sp_add_jobschedule @job_id                 = @jobID
                                                    , @name                   = N'Ehlers Error Reporting Schedule'
                                                    , @enabled                = 1
                                                    , @freq_type              = 8
                                                    , @freq_interval          = 62
                                                    , @freq_subday_type       = 1
                                                    , @freq_subday_interval   = 5
                                                    , @freq_relative_interval = 0
                                                    , @freq_recurrence_factor = 1
                                                    , @active_start_date      = 20121221
                                                    , @active_end_date        = 99991231
                                                    , @active_start_time      = 080000
                                                    , @active_end_time        = 170000 ;



/**/SELECT  @codeBlockNum = 10, @codeBlockDesc = @codeBlockDesc10 ; -- Set starting job step
    EXECUTE msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1 ;



/**/SELECT  @codeBlockNum = 11, @codeBlockDesc = @codeBlockDesc11 ; -- Add job to server
    EXECUTE msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = '(local)' ;


    IF  @localTransaction = 1 AND XACT_STATE() = 1
        COMMIT TRANSACTION localTransaction ;

    RETURN 0 ;

END TRY
BEGIN CATCH

    DECLARE @errorTypeID            AS INT              = 1
          , @errorSeverity          AS INT              = ERROR_SEVERITY()
          , @errorState             AS INT              = ERROR_STATE()
          , @errorNumber            AS INT              = ERROR_NUMBER()
          , @errorLine              AS INT              = ERROR_LINE()
          , @errorProcedure         AS SYSNAME          = ERROR_PROCEDURE()
          , @errorMessage           AS VARCHAR (MAX)
          , @formattedErrorMessage  AS VARCHAR (MAX)    = NULL
          , @errorData              AS VARCHAR (MAX)    = NULL ;


    IF  @@TRANCOUNT > 0 ROLLBACK TRANSACTION ;

    IF  @errorMessage IS NULL
    BEGIN
        SELECT  @errorMessage = ERROR_MESSAGE() ;

        SELECT  @errorData = ISNULL( @errorData, '' )
              + '<b>temp storage contents</b></br></br>'
              + '<table border="1">'
              + '<tr><th>stepName</th><th>sqlCmdText</th></tr>'
              + CAST ( ( SELECT  td = StepName      , ''
                               , td = CommandText   , ''
                           FROM  @jobSteps
                            FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
              + '</table></br></br>'
         WHERE  EXISTS ( SELECT 1 FROM @jobSteps ) ;

        EXECUTE dbo.processEhlersError  @errorTypeID
                                      , @codeBlockNum
                                      , @codeBlockDesc
                                      , @errorNumber
                                      , @errorSeverity
                                      , @errorState
                                      , @errorProcedure
                                      , @errorLine
                                      , @errorMessage
                                      , @errorData ;

        SELECT  @formattedErrorMessage = N'Error occurred in Code Block %d, %s ' + CHAR(13)
                                       + N'Error %d, Level %d, State %d, Procedure %s, Line %d, Message: %s ' ;

        RAISERROR( @formattedErrorMessage, @errorSeverity, @codeBlockNum
                 , @codeBlockNum
                 , @codeBlockDesc
                 , @errorNumber
                 , @errorSeverity
                 , @errorState
                 , @errorProcedure
                 , @errorLine
                 , @errorMessage ) ;

    END
        ELSE
    BEGIN
        SELECT  @errorMessage   = ERROR_MESSAGE()
              , @errorSeverity  = ERROR_SEVERITY()
              , @errorState     = ERROR_STATE()

        RAISERROR( @errorMessage, @errorSeverity, @errorState ) ;

    END

    RETURN 16 ;

END CATCH
END
