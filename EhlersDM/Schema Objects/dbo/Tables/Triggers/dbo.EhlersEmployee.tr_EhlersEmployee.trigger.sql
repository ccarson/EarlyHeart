CREATE TRIGGER  dbo.tr_EhlersEmployee 
            ON  dbo.EhlersEmployee
AFTER INSERT, UPDATE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_EhlersEmployee
     Author:    Chris Carson
    Purpose:    updates modifed data on EhlersEmployee

    revisor         date            description
    ---------       ----------      ----------------------------
    ccarson         2013-01-24      created

    Logic Summary:
    1)  Update dbo.EhlersEmployee with current timestamp and current user
    
    Notes:
    This trigger ensures that manually edited records still get the Modified data updated correctly.

************************************************************************************************************************************
*/
BEGIN

    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @SystemUser AS VARCHAR(20)  = dbo.udf_GetSystemUser() ;

    BEGIN TRY    
        UPDATE  dbo.EhlersEmployee
           SET  ModifiedDate = SYSDATETIME() 
              , ModifiedUser = @SystemUser 
          FROM  dbo.EhlersEmployee AS ee
         WHERE  EXISTS ( SELECT 1 FROM inserted AS i WHERE i.EhlersEmployeeID = ee.EhlersEmployeeID ) ;
    END TRY
    
    BEGIN CATCH
        ROLLBACK ; 
        EXECUTE  dbo.processEhlersError ; 
    END CATCH

END
