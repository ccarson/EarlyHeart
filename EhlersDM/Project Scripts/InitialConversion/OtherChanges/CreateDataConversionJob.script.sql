/*
************************************************************************************************************************************

     Script:    CreateDataConversionJob.script.sql
    Project:    Initial Conversion
     Author:    Chris Carson 
    Purpose:    Add Ehlers Data Conversion job on target server, schedule if required

************************************************************************************************************************************
*/
DECLARE @jobID          AS BINARY(16)
      , @jobName        AS SYSNAME
      , @databaseName   AS NVARCHAR(50) = '$(DatabaseName)'
      , @agentJobOwner  AS SYSNAME = '$(AgentJobOwner)'
      , @ReturnCode     AS INT = 0 ;

SELECT  @jobName = 'Ehlers Data Conversion - ' + @databaseName ;

BEGIN TRANSACTION
    IF NOT EXISTS ( SELECT name FROM msdb.dbo.syscategories WHERE NAME = N'EhlersDataConversion' AND category_class = 1 )
    BEGIN
        EXECUTE @ReturnCode = msdb.dbo.sp_add_category @class = N'JOB'
                                                     , @type = N'LOCAL'
                                                     , @name = N'EhlersDataConversion' ;
        IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback ;
    END

    EXECUTE @ReturnCode = msdb.dbo.sp_add_job @job_name              = @jobName
                                            , @enabled               = 1
                                            , @notify_level_eventlog = 0
                                            , @notify_level_email    = 0
                                            , @notify_level_netsend  = 0
                                            , @notify_level_page     = 0
                                            , @delete_level          = 0
                                            , @description           = N'Execute sync processes that merges legacy data into new converted tables.'
                                            , @category_name         = N'EhlersDataConversion'
                                            , @owner_login_name      = @agentJobOwner
                                            , @job_id                = @jobID OUTPUT ;
    IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback ;

    EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id               = @jobId
                                                , @step_name            = N'Execute processFirms'
                                                , @cmdexec_success_code = 0
                                                , @on_success_action    = 3
                                                , @on_success_step_id   = 0
                                                , @subsystem            = N'CmdExec'
                                                , @command              = N'sqlcmd -E -d Ehlers -Q "EXECUTE Conversion.processFirms" -b'
                                                , @flags                = 32 ;
    IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback ;

    EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id               = @jobId
                                                , @step_name            = N'Execute processFirmCategories'
                                                , @cmdexec_success_code = 0
                                                , @on_success_action    = 3
                                                , @on_success_step_id   = 0
                                                , @subsystem            = N'CmdExec'
                                                , @command              = N'sqlcmd -E -d Ehlers -Q "EXECUTE Conversion.processFirmCategories ;" -b'
                                                , @flags                = 32 ;
    IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback ;

    EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id               = @jobId
                                                , @step_name            = N'Execute processClients'
                                                , @cmdexec_success_code = 0
                                                , @on_success_action    = 3
                                                , @on_success_step_id   = 0
                                                , @subsystem            = N'CmdExec'
                                                , @command              = N'sqlcmd -E -d Ehlers -Q "EXECUTE Conversion.processClients ;" -b'
                                                , @flags                = 32 ;
    IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback ;

    EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id               = @jobId
                                                , @step_name            = N'Execute processClientDisclosure'
                                                , @cmdexec_success_code = 0
                                                , @on_success_action    = 3
                                                , @on_success_step_id   = 0
                                                , @subsystem            = N'CmdExec'
                                                , @command              = N'sqlcmd -E -d Ehlers -Q "EXECUTE Conversion.processClientDisclosure ;" -b'
                                                , @flags                = 32 ;
    IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback ;    

    EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id               = @jobId
                                                , @step_name            = N'Execute processClientCounties'
                                                , @cmdexec_success_code = 0
                                                , @on_success_action    = 3
                                                , @on_success_step_id   = 0
                                                , @subsystem            = N'CmdExec'
                                                , @command              = N'sqlcmd -E -d Ehlers -Q "EXECUTE Conversion.processClientCounties ;" -b'
                                                , @flags                = 32 ;
    IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback ;

    EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id               = @jobId
                                                , @step_name            = N'Execute processClientAnalysts'
                                                , @cmdexec_success_code = 0
                                                , @on_success_action    = 3
                                                , @on_success_step_id   = 0
                                                , @subsystem            = N'CmdExec'
                                                , @command              = N'sqlcmd -E -d Ehlers -Q "EXECUTE Conversion.processClientAnalysts ;" -b'
                                                , @flags                = 32 ;
    IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback ;

    EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id               = @jobId
                                                , @step_name            = N'Execute processClientDCs'
                                                , @cmdexec_success_code = 0
                                                , @on_success_action    = 3
                                                , @on_success_step_id   = 0
                                                , @subsystem            = N'CmdExec'
                                                , @command              = N'sqlcmd -E -d Ehlers -Q "EXECUTE Conversion.processClientDCs ;" -b'
                                                , @flags                = 32 ;
    IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback ;

    EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id               = @jobId
                                                , @step_name            = N'Execute processClientServices'
                                                , @cmdexec_success_code = 0
                                                , @on_success_action    = 3
                                                , @on_success_step_id   = 0
                                                , @subsystem            = N'CmdExec'
                                                , @command              = N'sqlcmd -E -d Ehlers -Q "EXECUTE Conversion.processClientServices ;" -b'
                                                , @flags                = 32 ;
    IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback ;

    EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id               = @jobId
                                                , @step_name            = N'Execute processClientCPAs'
                                                , @cmdexec_success_code = 0
                                                , @on_success_action    = 3
                                                , @on_success_step_id   = 0
                                                , @subsystem            = N'CmdExec'
                                                , @command              = N'sqlcmd -E -d Ehlers -Q "EXECUTE Conversion.processClientCPAs ;" -b'
                                                , @flags                = 32 ;
    IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback ;

    EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id               = @jobId
                                                , @step_name            = N'Execute processLocalAttorney'
                                                , @cmdexec_success_code = 0
                                                , @on_success_action    = 3
                                                , @on_success_step_id   = 0
                                                , @subsystem            = N'CmdExec'
                                                , @command              = N'sqlcmd -E -d Ehlers -Q "EXECUTE Conversion.processLocalAttorney ;" -b'
                                                , @flags                = 32 ;
    IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback ;

    EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id               = @jobId
                                                , @step_name            = N'Execute processElections'
                                                , @cmdexec_success_code = 0
                                                , @on_success_action    = 3
                                                , @on_success_step_id   = 0
                                                , @subsystem            = N'CmdExec'
                                                , @command              = N'sqlcmd -E -d Ehlers -Q "EXECUTE Conversion.processElections ;" -b'
                                                , @flags                = 32 ;
    IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback ;

    EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id               = @jobId
                                                , @step_name            = N'Execute processContacts'
                                                , @cmdexec_success_code = 0
                                                , @on_success_action    = 3
                                                , @on_success_step_id   = 0
                                                , @subsystem            = N'CmdExec'
                                                , @command              = N'sqlcmd -E -d Ehlers -Q "EXECUTE Conversion.processContacts ;" -b'
                                                , @flags                = 32 ;
    IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback ;

    EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id               = @jobId
                                                , @step_name            = N'Execute processContactMailings'
                                                , @cmdexec_success_code = 0
                                                , @on_success_action    = 3
                                                , @on_success_step_id   = 0
                                                , @subsystem            = N'CmdExec'
                                                , @command              = N'sqlcmd -E -d Ehlers -Q "EXECUTE Conversion.processContactMailings ;" -b'
                                                , @flags                = 32 ;
    IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback ;

    EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id               = @jobId
                                                , @step_name            = N'Execute processContactJobFunctions'
                                                , @cmdexec_success_code = 0
                                                , @on_success_action    = 3
                                                , @on_success_step_id   = 0
                                                , @subsystem            = N'CmdExec'
                                                , @command              = N'sqlcmd -E -d Ehlers -Q "EXECUTE Conversion.processContactJobFunctions ;" -b'
                                                , @flags                = 32 ;
    IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback ;

    EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id               = @jobId
                                                , @step_name            = N'Execute processAddressses'
                                                , @cmdexec_success_code = 0
                                                , @on_success_action    = 3
                                                , @on_success_step_id   = 0
                                                , @subsystem            = N'CmdExec'
                                                , @command              = N'sqlcmd -E -d Ehlers -Q "EXECUTE Conversion.processAddresses ;" -b'
                                                , @flags                = 32 ;

    IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback ;

    EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id               = @jobId
                                                , @step_name            = N'Execute processIssues'
                                                , @cmdexec_success_code = 0
                                                , @on_success_action    = 3
                                                , @on_success_step_id   = 0
                                                , @subsystem            = N'CmdExec'
                                                , @command              = N'sqlcmd -E -d Ehlers -Q "EXECUTE Conversion.processIssues ;" -b'
                                                , @flags                = 32 ;
    IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback ;

    EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id               = @jobId
                                                , @step_name            = N'Execute processIssueFirms'
                                                , @cmdexec_success_code = 0
                                                , @on_success_action    = 3
                                                , @on_success_step_id   = 0
                                                , @subsystem            = N'CmdExec'
                                                , @command              = N'sqlcmd -E -d Ehlers -Q "EXECUTE Conversion.processIssueFirms ;" -b'
                                                , @flags                = 32 ;
    IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback ;

    EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id               = @jobId
                                                , @step_name            = N'Execute processBondAttorney'
                                                , @cmdexec_success_code = 0
                                                , @on_success_action    = 1
                                                , @on_success_step_id   = 0
                                                , @subsystem            = N'CmdExec'
                                                , @command              = N'sqlcmd -E -d Ehlers -Q "EXECUTE Conversion.processBondAttorney ;" -b'
                                                , @flags                = 32 ;
    IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback ;

    EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id               = @jobId
                                                , @step_name            = N'Execute processCalls'
                                                , @cmdexec_success_code = 0
                                                , @on_success_action    = 3
                                                , @on_success_step_id   = 0
                                                , @subsystem            = N'CmdExec'
                                                , @command              = N'sqlcmd -E -d Ehlers -Q "Execute Conversion.processCalls" -b'
                                                , @flags                = 32 ;
    IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback ;

    EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id               = @jobId
                                                , @step_name            = N'Execute processArbitrageService'
                                                , @cmdexec_success_code = 0
                                                , @on_success_action    = 3
                                                , @on_success_step_id   = 0
                                                , @subsystem            = N'CmdExec'
                                                , @command              = N'sqlcmd -E -d Ehlers -Q "EXECUTE Conversion.processArbitrageService" -b'
                                                , @flags                = 32 ;
    IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback ;

    EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id               = @jobId
                                                , @step_name            = N'Execute processBiddingHistories'
                                                , @cmdexec_success_code = 0
                                                , @on_success_action    = 3
                                                , @on_success_step_id   = 0
                                                , @subsystem            = N'CmdExec'
                                                , @command              = N'sqlcmd -E -d Ehlers -Q "EXECUTE Conversion.processBiddingHistories" -b'
                                                , @flags                = 32 ;
    IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback ;

    EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id               = @jobId
                                                , @step_name            = N'Execute processBiddingParameters'
                                                , @cmdexec_success_code = 0
                                                , @on_success_action    = 1
                                                , @on_success_step_id   = 0
                                                , @subsystem            = N'CmdExec'
                                                , @command              = N'sqlcmd -E -d Ehlers -Q "EXECUTE Conversion.processBiddingParameters" -b'
                                                , @flags                = 32 ;
    IF ( @@ERROR <> 0 OR @ReturnCode <> 0 ) GOTO QuitWithRollback ;

    IF EXISTS ( SELECT 1 FROM msdb.dbo.sysschedules WHERE name = 'Ehlers Data Conversion Schedule' )
        EXECUTE @ReturnCode = msdb.dbo.sp_attach_schedule @job_id=@jobID, @schedule_name='Ehlers Data Conversion Schedule' ;
    ELSE
        EXECUTE @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id                 = @jobID
                                                        , @name                   = N'Ehlers Data Conversion Schedule'
                                                        , @enabled                = 1
                                                        , @freq_type              = 8
                                                        , @freq_interval          = 62
                                                        , @freq_subday_type       = 4
                                                        , @freq_subday_interval   = 2
                                                        , @freq_relative_interval = 0
                                                        , @freq_recurrence_factor = 1
                                                        , @active_start_date      = 20130101
                                                        , @active_end_date        = 99991231
                                                        , @active_start_time      = 80000
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
