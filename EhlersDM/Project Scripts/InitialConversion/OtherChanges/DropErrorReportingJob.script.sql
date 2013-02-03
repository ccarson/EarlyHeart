DECLARE @jobID          AS BINARY(16)
      , @jobName        AS SYSNAME
      , @databaseName   AS NVARCHAR(50) = '$(DatabaseName)' ;

SELECT  @jobName = 'Ehlers Data Conversion - ' + @databaseName ;

IF  EXISTS ( SELECT job_id FROM msdb.dbo.sysjobs_view WHERE NAME = @jobName )
BEGIN
    SELECT  @jobID = job_id FROM msdb.dbo.sysjobs_view WHERE NAME = @jobName ;
    EXECUTE msdb.dbo.sp_delete_job @job_id = @jobID, @delete_unused_schedule = 0 ;
END


SELECT  @jobName = 'Ehlers Error Reporting - ' + @databaseName ;

IF  EXISTS ( SELECT job_id FROM msdb.dbo.sysjobs_view WHERE NAME = @jobName )
BEGIN
    SELECT  @jobID = job_id FROM msdb.dbo.sysjobs_view WHERE NAME = @jobName ;
    EXECUTE msdb.dbo.sp_delete_job @job_id = @jobID, @delete_unused_schedule = 0 ;
END