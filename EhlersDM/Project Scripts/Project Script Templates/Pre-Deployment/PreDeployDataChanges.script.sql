--  this SQLCMD variable should not be changed!
:setvar  DataChangesPath     ..\DataChanges\

/*
************************************************************************************************************************************

     Script:    PreDeployDataChanges.sql
     Author:    Chris Carson
    Purpose:    Any pre-deployment data changes go into this script

    USAGE
    1)  Add an :r reference to each data change script that needs to execute *before* deployment

    EXAMPLE
    :r  $(DataChangesPath)DataChangesTemplate.sql

    NOTES
    Leave the SET NOCOUNT statements in place.  No statements in the script will cause SQL errors

************************************************************************************************************************************
*/

SET NOCOUNT ON ;

--  ### BEGIN EXAMPLE
--  :r  $(DataChangesPath)Script1.script.sql
--  :r  $(DataChangesPath)Script2.script.sql
--  :r  $(DataChangesPath)Script3.script.sql
--  ### END EXAMPLE

SET NOCOUNT OFF ;