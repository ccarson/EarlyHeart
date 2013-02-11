/*
************************************************************************************************************************************
     Script:    BuildSQLAgentJobs.script.sql
    Purpose:    Drops/Creates the Ehlers Conversion job on the server
    
    NOTES
        The parameter @productionServer is *not* the target server on which the proc creates the SQL Agent jobs
        This proc creates the jobs on the SQL Instance of the target server for the publish action
        Target server may or may not be actual production server
    
************************************************************************************************************************************
*/

DECLARE @rc AS INT = 0 ;

IF  ( '$(BuildSQLAgentJobs)' = 'YES' )
BEGIN
    EXECUTE @rc = Conversion.buildDataConversionAgentJob @productionServer = '$(ProductionServer)'
                                                       , @jobOwner         = '$(AgentJobOwner)' ;
    IF  ( @rc <> 0 ) RAISERROR ('Error creating Data Conversion Job', @rc, 1) ;


    EXECUTE @rc = Conversion.buildErrorReportingAgentJob @productionServer = '$(ProductionServer)'
                                                       , @jobOwner         = '$(AgentJobOwner)' ;
    IF  ( @rc <> 0 ) RAISERROR ('Error creating Error Reporting Job', @rc, 1) ;
END