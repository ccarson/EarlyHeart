CREATE TRIGGER dbo.tr_FirmAddresses_Insert ON dbo.FirmAddresses
AFTER INSERT
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_FirmAddresses_Insert
     Author:    Chris Carson
    Purpose:    loads dbo.Address data back to edata.Firms


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Create FirmAddressesAudit records reflecting INSERTs
    2)  Stop processing when trigger is invoked by Conversion.processAddresses procedure
    3)  Update Address Data back to dbo.FirmContacts
    4)  Create records on Conversion.LegacyAddresses

    Notes:

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @processAddresses AS VARBINARY(128) = CAST( 'processAddresses' AS VARBINARY(128) ) ;


--  1)  Create FirmAddressesAudit records reflecting INSERTs
    INSERT  dbo.FirmAddressesAudit (
            FirmAddressesID, FirmID
                , AddressID, AddressTypeID
                , ChangeType
                , ModifiedDate, ModifiedUser )
    SELECT  FirmAddressesID, FirmID
                , AddressID, AddressTypeID
                , 'I'
                , ModifiedDate, ModifiedUser
      FROM  inserted  ;


--  2)  Stop processing when trigger is invoked by Conversion.processAddresses procedure
    IF  CONTEXT_INFO() = @processAddresses
        RETURN ;


--  3)  Update Address Data back to dbo.Firms
    UPDATE  edata.Firms
       SET  Address1   = a.Address1
          , Address2   = a.Address2
          , City       = a.City
          , State    = a.State
          , Zip        = a.Zip
          , ChangeDate = i.ModifiedDate
          , ChangeBy   = i.ModifiedUser
          , ChangeCode = 'CVAddress'
      FROM  inserted AS i
INNER JOIN  edata.Firms AS f
        ON  f.FirmID = i.FirmID AND i.AddressTypeID = 3
INNER JOIN  dbo.Address AS a
        ON  a.AddressID = i.AddressID ;


--  4)  Create records on Conversion.LegacyAddresses
    INSERT  Conversion.LegacyAddresses ( LegacyID, LegacyTableName, AddressID )
    SELECT  i.FirmID, 'Firms', i.AddressID
      FROM  inserted AS i
     WHERE  i.AddressTypeID = 3 ;
END
