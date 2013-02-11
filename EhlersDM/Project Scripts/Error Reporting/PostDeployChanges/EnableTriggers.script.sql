/*
************************************************************************************************************************************

     Script:    EnableTriggers.script.sql
    Purpose:    Enables / Disable DML Triggers on target database

    NOTES
        If the TargetServer is == ProductionServer, Triggers cannot be disabled from the publish project
************************************************************************************************************************************
*/

IF  ( '$(TargetServer)' <> '$(ProductionServer)' ) 
    IF  ( '$(EnableTriggers)' = 'YES' )
        EXECUTE sp_MSForEachTable 'ALTER TABLE ? ENABLE TRIGGER ALL' ;
    ELSE
        EXECUTE sp_MSForEachTable 'ALTER TABLE ? DISABLE TRIGGER ALL' ;
ELSE
    EXECUTE sp_MSForEachTable 'ALTER TABLE ? ENABLE TRIGGER ALL' ;
