/*
************************************************************************************************************************************

     Script:    PreDeployment.Script.sql
     Author:    Chris Carson
    Purpose:    executes database logic *BEFORE* SQL changes from project are applied to database


    Revision History:

    revisor     date            description
    --------    ----------      ----------------------------------
    ccarson     ###DATE###      created
    
    NOTES
    Make sure the "Build Action" property for this file is set to "PreDeploy" otherwise it will not execute
    The template includes logic for PreDeploy datachanges and it should not be removed
    Add other custom pre-deploy logic before or after the data changes


************************************************************************************************************************************
*/

--  Execute any pre-deploy data changes
IF  ( '$(PreDeployChanges)' = 'YES' )
BEGIN 
    :r  .\PreDeployChanges.script.sql
END
