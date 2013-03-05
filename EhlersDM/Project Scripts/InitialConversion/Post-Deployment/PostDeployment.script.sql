/*
************************************************************************************************************************************

     Script:    PostDeployment.Script.sql
     Author:    Chris Carson
    Purpose:    executes database logic *AFTER* SQL changes from project are applied to database


    Revision History:

    revisor     date            description
    --------    ----------      ----------------------------------
    ccarson     ###DATE###      created

    NOTES
    Make sure the "Build Action" property for this file is set to "PostDeploy" otherwise it will not execute

    Initial Conversion
    1)  Execute data changes
    2)  Enable / Disable Referential Integrity ( for development purposes )
    3)  Enable / Disable Database Triggers     ( for development purposes )
    4)  Drop/Create SQL Agent jobs to run conversion ( if requested )
    5)  Grant permissions to the domain SQL-Users group for the target database
    6)  Create EHLERS/Ehlers-WB2$ user for the database if the login exists


************************************************************************************************************************************
*/

--  1)  Execute data changes
IF  ( '$(PostDeployDataChanges)' = 'YES' )
BEGIN
    :r  .\PostDeployDataChanges.script.sql
END


--  2)  Enable / Disable Referential Integrity ( for development purposes )
IF  ( '$(EnableRI)' = 'YES' )
    EXECUTE sp_MSForEachTable 'ALTER TABLE ? CHECK CONSTRAINT ALL' ;
ELSE
    EXECUTE sp_MSForEachTable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL' ;


--  3)  Enable / Disable Database Triggers     ( for development purposes )
IF  ( '$(EnableTriggers)' = 'YES' )
    EXECUTE sp_MSForEachTable 'ALTER TABLE ? ENABLE TRIGGER ALL' ;
ELSE
    EXECUTE sp_MSForEachTable 'ALTER TABLE ? DISABLE TRIGGER ALL' ;


--  4)  Drop/Create SQL Agent jobs to run conversion ( if requested )
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


--  5)  Grant permissions to the domain SQL-Users group for the target database
:r ..\OtherChanges\SetSQLUsersGroupPermissions.script.sql


-- 6)   Create EHLERS/Ehlers-WB2$ user for the database if the login exists
IF  EXISTS ( SELECT 1 FROM sys.syslogins WHERE name = 'EHLERS/Ehlers-WB2$' )
BEGIN 
    CREATE USER [EHLERS\EHLERS-WB2$] FOR LOGIN [EHLERS\EHLERS-WB2$] ;
    GRANT CONNECT TO [EHLERS\EHLERS-WB2$] ;    
END
    
    
    
    







