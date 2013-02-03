CREATE TRIGGER dbo.tr_FirmAddresses_Delete ON dbo.FirmAddresses
AFTER DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_FirmAddresses_Delete
     Author:    Chris Carson
    Purpose:    Clears address data on edata.dbo.Firms


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Create FirmAddressesAudit records reflecting DELETEs
    2)  Stop processing when trigger is invoked by Conversion.processAddresses procedure
    3)  Update Address Data back to dbo.Firms
    4)  Delete records on Conversion.LegacyAddresses

    Notes:

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @processAddresses AS VARBINARY(128) = CAST( 'processAddresses' AS VARBINARY(128) ) ;
    DECLARE @SystemUser       AS VARCHAR(20)    = dbo.udf_GetSystemUser() ; 

--  1)  Create FirmAddressesAudit record reflecting DELETEs
    INSERT  dbo.FirmAddressesAudit (
                FirmAddressesID, FirmID, AddressID
                    , AddressTypeID, ChangeType
                    , ModifiedDate, ModifiedUser )
    SELECT  FirmAddressesID, FirmID, AddressID
                , AddressTypeID, 'D'
                , GETDATE(), @SystemUser
      FROM  deleted ;


--  2)  Stop processing when trigger is invoked by Conversion.processAddresses procedure
    IF  CONTEXT_INFO() = @processAddresses
        RETURN ;


--  3)  Update Address Data back to dbo.Firms
    UPDATE  edata.dbo.Clients
       SET  Address1   = ''
          , Address2   = ''
          , City       = ''
          , State    = ''
          , Zip        = ''
          , ChangeDate = GETDATE()
          , ChangeBy   = @SystemUser
          , ChangeCode = 'CVAddress'
      FROM  deleted AS d
INNER JOIN  edata.dbo.Firms AS f
        ON  f.FirmID = d.FirmID
     WHERE  d.AddressTypeID = 3 ;


--  4)  Delete Conversion.LegacyAddresses records
    DELETE  Conversion.LegacyAddresses
      FROM  Conversion.LegacyAddresses AS a
     WHERE  EXISTS ( SELECT 1 FROM deleted AS b WHERE b.AddressID = a.AddressID ) ;
END
