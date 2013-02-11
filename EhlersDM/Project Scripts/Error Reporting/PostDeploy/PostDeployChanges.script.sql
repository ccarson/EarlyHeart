--  this SQLCMD variable should not be changed!
:setvar  PostDeployPath     ..\PostDeployChanges\

/*
************************************************************************************************************************************

     Script:    PostDeployChanges.script.sql
     Author:    Chris Carson 
    Purpose:    Any post-deployment change scripts execute from here

    USAGE
    1)  Enable / Disable RI in database
    2)  Enable / Disable Triggers in database
    3)  Add SQL Agent Jobs to server if requested

    NOTES
    Leave the SET NOCOUNT statements in place.  No statements in the script will cause SQL errors

************************************************************************************************************************************
*/

SET NOCOUNT ON ;

    :r  $(PostDeployPath)EnableRI.script.sql
    
    :r  $(PostDeployPath)EnableTriggers.script.sql
    
    :r  $(PostDeployPath)BuildSQLAgentJobs.script.sql

SET NOCOUNT OFF ;