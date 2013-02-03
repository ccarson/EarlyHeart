CREATE TRIGGER  tr_FirmContacts_Delete
            ON  dbo.FirmContacts
AFTER DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    tr_FirmContacts_Delete
     Author:    Chris Carson
    Purpose:    Drops legacy FirmContacts records after deletion in Firm application

    revisor         date                description
    ---------       ----------          ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Write Audit record to show deletion
    2)  DELETE records from edata.dbo.FirmContacts
    3)  DELETE records from Conversion.LegacyContacts

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @SystemUser AS VARCHAR(20) = dbo.udf_GetSystemUser() ;

--  1)  Write Audit record to show deletion
BEGIN TRY
    INSERT  dbo.FirmContactsAudit (
            FirmContactsID
          , FirmID
          , ContactID
          , ChangeType
          , ModifiedDate
          , ModifiedUser )
    SELECT  FirmContactsID
          , FirmID
          , ContactID
          , 'D'
          , GETDATE()
          , @SystemUser
      FROM  deleted ;

--  2)  Delete records from edata.dbo.FirmContacts
      WITH  legacy AS (
            SELECT * FROM edata.dbo.FirmContacts AS fc
             WHERE EXISTS ( SELECT 1
                              FROM Conversion.LegacyContacts AS lc
                        INNER JOIN deleted AS d ON d.ContactID = lc.ContactID
                             WHERE lc.LegacyContactID = fc.ContactID AND lc.LegacyTableName = 'FirmContacts' ) )
    DELETE  legacy;


--  3)  DELETE records from Conversion.LegacyContacts
      WITH  legacyContacts AS (
            SELECT * FROM Conversion.LegacyContacts AS lc
             WHERE EXISTS ( SELECT 1 FROM deleted AS d WHERE d.ContactID = lc.ContactID ) )
    DELETE  legacyContacts ;

END TRY
BEGIN CATCH
    ROLLBACK ;
    EXECUTE dbo.processEhlersError ;
END CATCH

END