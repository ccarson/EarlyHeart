/*
************************************************************************************************************************************
     Script:    OtherChangesTemplate.script.sql
    Purpose:    Documents usage of the OtherChanges folder
    
    This folder contains scripts for any non-data changes required as part of a project publish
    Examples could be: SQL Agent job creation, granting/revocation of permissions, special backups

    USAGE:
    1)  Each set of related changes should have a separate script in the project OtherChanges folder
    2)  Refer to each script directly in either PreDeployment.script.sql or the PostDeployment.script.sql
************************************************************************************************************************************
*/

--  Any reqired data changes go here