CREATE TRIGGER dbo.tr_ClientAddresses_Update ON dbo.ClientAddresses
AFTER UPDATE
AS 
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @SystemUser AS VARCHAR(20) = dbo.udf_GetSystemUser() ;

    INSERT  dbo.ClientAddressesAudit (
            ClientAddressesID
          , ClientID
          , AddressID
          , AddressTypeID
          , ChangeType
          , ModifiedDate
          , ModifiedUser )
    SELECT  ClientAddressesID
          , ClientID
          , AddressID
          , AddressTypeID
          , 'U'
          , GETDATE()
          , @SystemUser 
      FROM  inserted ;
END