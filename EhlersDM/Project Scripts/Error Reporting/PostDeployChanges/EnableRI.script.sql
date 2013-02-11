/*
************************************************************************************************************************************

     Script:    EnableRI.script.sql
    Purpose:    Enables / Disable RI on target database

    NOTES
        If the TargetServer is == ProductionServer, RI cannot be disabled from the publish project
************************************************************************************************************************************
*/

IF  ( '$(TargetServer)' <> '$(ProductionServer)' ) 
    IF  ( '$(EnableRI)' = 'YES' )
        EXECUTE sp_MSForEachTable 'ALTER TABLE ? CHECK CONSTRAINT ALL' ;
    ELSE
        EXECUTE sp_MSForEachTable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL' ;
ELSE
    EXECUTE sp_MSForEachTable 'ALTER TABLE ? CHECK CONSTRAINT ALL' ;
