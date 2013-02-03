CREATE TRIGGER dbo.tr_FirmContacts_Update ON dbo.FirmContacts
AFTER UPDATE
AS 
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @SystemUser AS VARCHAR(20) = dbo.udf_GetSystemUser() ;

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
          , 'U'
          , GETDATE()
          , @SystemUser
      FROM  inserted ;
END
