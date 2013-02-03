CREATE TRIGGER dbo.tr_ClientContacts_Update ON dbo.ClientContacts
AFTER UPDATE
AS 
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @SystemUser AS VARCHAR(20) = dbo.udf_GetSystemUser() ;

    INSERT  dbo.ClientContactsAudit (
            ClientContactsID
          , ClientID
          , ContactID
          , ChangeType
          , ModifiedDate
          , ModifiedUser )
    SELECT  ClientContactsID
          , ClientID
          , ContactID
          , 'U'
          , GETDATE()
          , @SystemUser 
      FROM  inserted ;
END
