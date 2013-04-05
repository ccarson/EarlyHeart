CREATE TRIGGER dbo.tr_ClientAddresses_Delete ON dbo.ClientAddresses
AFTER DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_ClientAddresses_Delete
     Author:    Chris Carson
    Purpose:    Applies address data to specified edata.Client records


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Create ClientAddressesAudit records reflecting DELETEs
    2)  Stop processing when trigger is invoked by Conversion.processAddresses procedure
    3)  Clear out Address fields on edata.Client records
    4)  Delete Conversion.LegacyAddresses records

    Notes:

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @fromConversion AS VARBINARY (128) = CAST( 'fromConversion' AS VARBINARY (128) ) ; ;
    DECLARE @SystemUser       AS VARCHAR(20)    = dbo.udf_GetSystemUser() ;


--  1)  Create ClientAddressesAudit record reflecting DELETEs
    INSERT  dbo.ClientAddressesAudit (
                ClientAddressesID, ClientID, AddressID
                    , AddressTypeID, ChangeType
                    , ModifiedDate, ModifiedUser )
    SELECT  ClientAddressesID, ClientID, AddressID
                , AddressTypeID, 'D'
                , GETDATE(), @SystemUser
      FROM  deleted ;


--  2)  Stop processing when trigger is invoked by Conversion.processAddresses procedure
    IF  CONTEXT_INFO() = @fromConversion
        RETURN ;


--  3)  Clear out Address fields on edata.Client records
    UPDATE  edata.Clients
       SET  Address1    = ''
          , Address2    = ''
          , City        = ''
          , State     = ''
          , Zip         = ''
          , ChangeDate  = GETDATE()
          , ChangeBy    = @SystemUser
          , ChangeCode  = 'CVAddress'
      FROM  deleted AS d
INNER JOIN  edata.Clients AS c
        ON  c.ClientId = d.ClientID
     WHERE  d.AddressTypeID = 3 ;


--  4)  Delete Conversion.LegacyAddresses records
    DELETE  Conversion.LegacyAddresses
      FROM  Conversion.LegacyAddresses AS a
     WHERE  EXISTS ( SELECT 1 FROM deleted AS b WHERE b.AddressID = a.AddressID ) ;
END
