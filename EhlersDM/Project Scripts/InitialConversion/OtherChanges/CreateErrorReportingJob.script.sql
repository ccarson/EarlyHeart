/*
************************************************************************************************************************************

     Script:    CreateErrorReportingJob.script.sql
    Project:    Initial Conversion
     Author:    Chris Carson 
    Purpose:    Add Ehlers Error Reporting job on target server, schedule if required

************************************************************************************************************************************
*/
DECLARE @jobID          AS BINARY(16)
      , @jobName        AS SYSNAME
      , @databaseName   AS NVARCHAR(50) = '$(DatabaseName)'
      , @agentJobOwner  AS SYSNAME = '$(AgentJobOwner)'
      , @ReturnCode     AS INT = 0 ;

SELECT  @jobName = 'Ehlers Error Reporting - ' + @databaseName ;

BEGIN TRANSACTION
    EXECUTE @ReturnCode = msdb.dbo.sp_add_job @job_name              = @jobName
                                            , @enabled               = 1
                                            , @notify_level_eventlog = 0
                                            , @notify_level_email    = 0
                                            , @notify_level_netsend  = 0
                                            , @notify_level_page     = 0
                                            , @delete_level          = 0
                                            , @description           = N'Create exception reports for invalid legacy data.'
                                            , @category_name         = N'EhlersDataConversion'
                                            , @owner_login_name      = @agentJobOwner
                                            , @job_id                = @jobID OUTPUT ;
    IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback ;

    EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id               = @jobId
                                                , @step_name            = N'Execute reportLocalAttorneyErrors'
                                                , @cmdexec_success_code = 0
                                                , @on_success_action    = 3
                                                , @on_success_step_id   = 0
                                                , @subsystem            = N'CmdExec'
                                                , @command              = N'sqlcmd -E -d Ehlers -Q "EXECUTE Conversion.reportLocalAttorneyErrors ;" -b'
                                                , @flags                = 32 ;
    IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback ;

    EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id               = @jobId
                                                , @step_name            = N'Execute reportClientCPAErrors'
                                                , @cmdexec_success_code = 0
                                                , @on_success_action    = 3
                                                , @on_success_step_id   = 0
                                                , @subsystem            = N'CmdExec'
                                                , @command              = N'sqlcmd -E -d Ehlers -Q "EXECUTE Conversion.reportClientCPAErrors ;" -b'
                                                , @flags                = 32 ;
    IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback ;

    EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id               = @jobId
                                                , @step_name            = N'Execute reportIssuesErrors'
                                                , @cmdexec_success_code = 0
                                                , @on_success_action    = 3
                                                , @on_success_step_id   = 0
                                                , @subsystem            = N'CmdExec'
                                                , @command              = N'sqlcmd -E -d Ehlers -Q "EXECUTE Conversion.reportIssuesErrors ;" -b'
                                                , @flags                = 32 ;
    IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback ;
    
    EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id               = @jobId
                                                , @step_name            = N'Execute reportBondAttorneyErrors'
                                                , @cmdexec_success_code = 0
                                                , @on_success_action    = 1
                                                , @on_success_step_id   = 0
                                                , @subsystem            = N'CmdExec'
                                                , @command              = N'sqlcmd -E -d Ehlers -Q "EXECUTE Conversion.reportBondAttorneyErrors ;" -b'
                                                , @flags                = 32 ;
    IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback ;

    IF EXISTS ( SELECT 1 FROM msdb.dbo.sysschedules WHERE name = 'Ehlers Error Reporting Schedule' )
        EXECUTE @ReturnCode = msdb.dbo.sp_attach_schedule @job_id=@jobID, @schedule_name='Ehlers Error Reporting Schedule' ;
    ELSE
        EXECUTE @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id                 = @jobID
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
                                                        , @active_start_time      = 70000
                                                        , @active_end_time        = 210000 ;

    IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback ;

    EXECUTE @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1 ;
    IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback ;

    EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobID, @server_name = N'(local)' ;
    IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback

COMMIT TRANSACTION

GOTO EndSave

QuitWithRollback:
IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION ;

EndSave:
