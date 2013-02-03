CREATE TRIGGER dbo.tr_EmployerAddresses_Insert ON dbo.EmployerAddresses
AFTER INSERT
AS 
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @SystemUser AS VARCHAR(20) = dbo.udf_GetSystemUser() ;

    INSERT  dbo.EmployerAddressesAudit (
            EmployerAddressesID
          , EmployerID
          , AddressID
          , AddressTypeID
          , ChangeType
          , ModifiedDate
          , ModifiedUser )
    SELECT  EmployerAddressesID
          , EmployerID
          , AddressID
          , AddressTypeID
          , 'I'
          , GETDATE()
          , @SystemUser
      FROM  inserted ;
END
