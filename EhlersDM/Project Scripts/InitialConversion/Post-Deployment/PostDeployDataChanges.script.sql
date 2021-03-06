--  this SQLCMD variable should not be changed!
:setvar  DataChangesPath     ..\DataChanges\

/*
************************************************************************************************************************************

     Script:    PostDeployDataChanges.sql
     Author:    Chris Carson 
    Purpose:    Any post-deployment data changes go into this script

    Initial Conversion
    
    Load Office Addresses
    Load Static Lists
    
************************************************************************************************************************************
*/

SET NOCOUNT ON ;

:r  $(DataChangesPath)LoadOfficeAddresses.script.sql

:r  $(DataChangesPath)LoadStaticLists.script.sql

SET NOCOUNT OFF ; 
