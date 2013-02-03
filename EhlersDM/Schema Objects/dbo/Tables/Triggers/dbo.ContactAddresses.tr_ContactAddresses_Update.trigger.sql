CREATE TRIGGER dbo.tr_ContactAddresses_Update ON dbo.ContactAddresses
AFTER UPDATE
AS 
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @SystemUser AS VARCHAR(20) = dbo.udf_GetSystemUser() ;

    INSERT  dbo.ContactAddressesAudit (
            ContactAddressesID
          , ContactID
          , AddressID
          , AddressTypeID
          , ChangeType
          , ModifiedDate
          , ModifiedUser )
    SELECT  ContactAddressesID
          , ContactID
          , AddressID
          , AddressTypeID
          , 'U'
          , GETDATE()
          , @SystemUser
      FROM  inserted ;
END


