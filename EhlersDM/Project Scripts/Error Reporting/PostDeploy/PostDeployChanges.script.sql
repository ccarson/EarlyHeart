--  this SQLCMD variable should not be changed!
:setvar  PostDeployPath     ..\PostDeployChanges\

/*
************************************************************************************************************************************

     Script:    PostDeployChanges.script.sql
     Author:    Chris Carson
    Purpose:    Any post-deployment change scripts execute from here

    USAGE
    1)  Load Error types and email recipients

    NOTES
    Leave the SET NOCOUNT statements in place.  No statements in the script will cause SQL errors

************************************************************************************************************************************
*/

SET NOCOUNT ON ;

    :r  $(PostDeployPath)LoadErrorTypeAndRecipients.script.sql

SET NOCOUNT OFF ;