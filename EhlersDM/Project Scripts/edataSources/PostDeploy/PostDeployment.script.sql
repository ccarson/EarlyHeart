/*
************************************************************************************************************************************

     Script:    PostDeployment.Script.sql
     Author:    Chris Carson
    Purpose:    executes database changes *AFTER* SQL changes from project are applied to database


    Revision History:

    revisor     date            description
    --------    ----------      ----------------------------------
    ccarson     ###DATE###      created
    
    NOTES
    Make sure the "Build Action" property for this file is set to "PostDeploy" otherwise it will not execute
    Do not alter the SQL in this script, the project may not build / publish correctly if this script is altered


************************************************************************************************************************************
*/

--  Execute any post-deploy data changes
IF  ( '$(PostDeployChanges)' = 'YES' )
BEGIN 
    :r  .\PostDeployChanges.script.sql
END


