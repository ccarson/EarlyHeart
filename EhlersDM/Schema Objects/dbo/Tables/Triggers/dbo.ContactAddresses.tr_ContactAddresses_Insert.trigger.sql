CREATE TRIGGER dbo.tr_ContactAddresses_Insert ON dbo.ContactAddresses
AFTER INSERT
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_ContactAddresses_Insert
     Author:    Chris Carson
    Purpose:    loads dbo.Address data back to edata.FirmContacts and edata.ClientContacts tables


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Create ContactAddressesAudit records reflecting INSERTs
    2)  Stop processing when trigger is invoked by Conversion.processAddresses procedure
    3)  Update Address Data back to dbo.FirmContacts
    4)  Update Address Data back to dbo.ClientContacts
    5)  Create records on Conversion.LegacyAddresses

    Notes:

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @fromConversion AS VARBINARY (128) = CAST( 'fromConversion' AS VARBINARY (128) ) ; ;


--  1)  Create ContactAddressesAudit records reflecting INSERTs
    INSERT  dbo.ContactAddressesAudit (
                ContactAddressesID, ContactID, AddressID
                    , AddressTypeID, ChangeType
                    , ModifiedDate, ModifiedUser )
    SELECT  ContactAddressesID, ContactID, AddressID
                , AddressTypeID, 'I'
                , ModifiedDate, ModifiedUser
      FROM  inserted ;


--  2)  Stop processing when trigger is invoked by Conversion.processAddresses procedure
    IF  CONTEXT_INFO() = @fromConversion
        RETURN ;


--  3)  Update Address Data back to dbo.FirmContacts
    UPDATE  edata.FirmContacts
       SET  Address1   = a.Address1
          , Address2   = a.Address2
          , City       = a.City
          , State    = a.State
          , Zip        = a.Zip
          , ChangeDate = i.ModifiedDate
          , ChangeBy   = i.ModifiedUser
          , ChangeCode = 'CVAddress'
      FROM  inserted AS i
INNER JOIN  dbo.Address AS a
        ON  a.AddressID = i.AddressID AND i.AddressTypeID = 3
INNER JOIN  Conversion.LegacyContacts AS lc
        ON  lc.ContactID = i.ContactID
INNER JOIN  edata.FirmContacts AS fc
        ON  fc.ContactID = lc.LegacyContactID ;


--  4)  Update Address Data back to dbo.ClientContacts
    UPDATE  edata.ClientContacts
       SET  Address1   = a.Address1
          , Address2   = a.Address2
          , City       = a.City
          , State    = a.State
          , Zip        = a.Zip
          , ChangeDate = i.ModifiedDate
          , ChangeBy   = i.ModifiedUser
          , ChangeCode = 'CVAddress'
      FROM  inserted AS i
INNER JOIN  dbo.Address AS a
        ON  a.AddressID = i.AddressID AND i.AddressTypeID = 3
INNER JOIN  Conversion.LegacyContacts AS lc
        ON  lc.ContactID = i.ContactID
INNER JOIN  edata.ClientContacts AS cc
        ON  cc.ContactID = lc.LegacyContactID ;


--  5)  Create records on Conversion.LegacyAddresses
    INSERT  Conversion.LegacyAddresses ( LegacyID, LegacyTableName, AddressID )
    SELECT  lc.LegacyContactID, lc.LegacyTableName, i.AddressID
      FROM  inserted AS i
INNER JOIN  Conversion.LegacyContacts AS lc
        ON  lc.ContactID = i.ContactID
     WHERE  i.AddressTypeID = 3 ;
END
