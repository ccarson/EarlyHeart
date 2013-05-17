CREATE PROCEDURE Conversion.buildErrorReportingAgentJob ( @productionServer AS SYSNAME
                                                        , @jobOwner         AS SYSNAME )
AS
/*
************************************************************************************************************************************

  Procedure:    Conversion.buildErrorReportingAgentJob
     Author:    Chris Carson
    Purpose:    adds Ehlers Error Reporting Job on server

    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

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

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;


    DECLARE @jobID              AS BINARY(16) = NULL
          , @jobName            AS SYSNAME
          , @rc                 AS INT = 0 ;


--  1)  Set job name based on databaseName ( non-production servers only )
    IF  ( @@SERVERNAME = @productionServer )
        SELECT @jobName = 'Ehlers Error Reporting' ;
    ELSE
        SELECT @jobName = 'Ehlers Error Reporting - ' + DB_NAME() ;


--  2)  Drop existing job
    IF  EXISTS ( SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = @jobName )
    BEGIN
        SELECT  @jobID = job_id FROM msdb.dbo.sysjobs_view WHERE name = @jobName ;
        EXECUTE msdb.dbo.sp_delete_job @job_id = @jobID, @delete_unused_schedule = 0 ;
        SELECT  @jobID = NULL ;         
    END


--  3)  Execute logic to create new job on server, with job steps
    BEGIN TRANSACTION
        IF NOT EXISTS ( SELECT name FROM msdb.dbo.syscategories WHERE NAME = N'EhlersDataConversion' AND category_class = 1 )
        BEGIN
            EXECUTE @rc = msdb.dbo.sp_add_category @class = N'JOB'
                                                 , @type  = N'LOCAL'
                                                 , @name  = N'EhlersDataConversion' ;
            IF ( @@ERROR <> 0 OR @rc <> 0 ) GOTO QuitWithRollback ;
        END


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
        IF ( @@ERROR <> 0 OR @rc <> 0 ) GOTO QuitWithRollback ;


        EXECUTE @rc = msdb.dbo.sp_add_jobstep @job_id               = @jobId
                                            , @step_name            = N'Execute reportLocalAttorneyErrors'
                                            , @cmdexec_success_code = 0
                                            , @on_success_action    = 3
                                            , @on_success_step_id   = 0
                                            , @subsystem            = N'CmdExec'
                                            , @command              = N'sqlcmd -E -d $(DatabaseName) -Q "EXECUTE Conversion.reportLocalAttorneyErrors ;" -b'
                                            , @flags                = 32 ;
        IF ( @@ERROR <> 0 OR @rc <> 0 ) GOTO QuitWithRollback ;


        EXECUTE @rc = msdb.dbo.sp_add_jobstep @job_id               = @jobId
                                            , @step_name            = N'Execute reportClientCPAErrors'
                                            , @cmdexec_success_code = 0
                                            , @on_success_action    = 3
                                            , @on_success_step_id   = 0
                                            , @subsystem            = N'CmdExec'
                                            , @command              = N'sqlcmd -E -d $(DatabaseName) -Q "EXECUTE Conversion.reportClientCPAErrors ;" -b'
                                            , @flags                = 32 ;
        IF ( @@ERROR <> 0 OR @rc <> 0 ) GOTO QuitWithRollback ;


        EXECUTE @rc = msdb.dbo.sp_add_jobstep @job_id               = @jobId
                                            , @step_name            = N'Execute reportIssuesErrors'
                                            , @cmdexec_success_code = 0
                                            , @on_success_action    = 3
                                            , @on_success_step_id   = 0
                                            , @subsystem            = N'CmdExec'
                                            , @command              = N'sqlcmd -E -d $(DatabaseName) -Q "EXECUTE Conversion.reportIssuesErrors ;" -b'
                                            , @flags                = 32 ;
        IF ( @@ERROR <> 0 OR @rc <> 0 ) GOTO QuitWithRollback ;


        EXECUTE @rc = msdb.dbo.sp_add_jobstep @job_id               = @jobId
                                            , @step_name            = N'Execute reportBondAttorneyErrors'
                                            , @cmdexec_success_code = 0
                                            , @on_success_action    = 1
                                            , @on_success_step_id   = 0
                                            , @subsystem            = N'CmdExec'
                                            , @command              = N'sqlcmd -E -d $(DatabaseName) -Q "EXECUTE Conversion.reportBondAttorneyErrors ;" -b'
                                            , @flags                = 32 ;
        IF ( @@ERROR <> 0 OR @rc <> 0 ) GOTO QuitWithRollback ;


--  4)  Add job schedule -- job should execute every two hours daily between 8:00AM and 5:00PM
        IF EXISTS ( SELECT 1 FROM msdb.dbo.sysschedules WHERE name = 'Ehlers Error Reporting Schedule' )
            EXECUTE @rc = msdb.dbo.sp_attach_schedule @job_id=@jobID, @schedule_name='Ehlers Error Reporting Schedule' ;
        ELSE
            EXECUTE @rc = msdb.dbo.sp_add_jobschedule @job_id                 = @jobID
                                                    , @name                   = N'Ehlers Error Reporting Schedule'
                                                    , @enabled                = 1
                                                    , @freq_type              = 8
                                                    , @freq_interval          = 62
                                                    , @freq_subday_type       = 1
                                                    , @freq_subday_interval   = 2
                                                    , @freq_relative_interval = 0
                                                    , @freq_recurrence_factor = 1
                                                    , @active_start_date      = 20121221
                                                    , @active_end_date        = 99991231
                                                    , @active_start_time      = 080000
                                                    , @active_end_time        = 170000 ;

        IF ( @@ERROR <> 0 OR @rc <> 0 ) GOTO QuitWithRollback ;


--  5)  Set starting job step and add job to server
        EXECUTE @rc = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1 ;
                IF ( @@ERROR <> 0 OR @rc <> 0 ) GOTO QuitWithRollback ;

        EXECUTE @rc = msdb.dbo.sp_add_jobserver @job_id = @jobID, @server_name = N'(local)' ;
                IF ( @@ERROR <> 0 OR @rc <> 0 ) GOTO QuitWithRollback ;


    COMMIT TRANSACTION

    GOTO endOfproc ;

QuitWithRollback:
    IF  ( @@TRANCOUNT > 0 )
    BEGIN
        ROLLBACK ;
        SELECT @rc = 16 ;
    END

endOfproc:

    RETURN @rc ;
END

