CREATE TRIGGER dbo.tr_Address_Update ON dbo.Address
AFTER UPDATE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_Address_Update
     Author:    Chris Carson
    Purpose:    applies Address change data back to legacy tables


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Create dbo.AddressAudit records reflecting UPDATE
    2)  Stop processing when trigger is invoked by Conversion.processAddresses procedure
    3)  Update Address Data back to dbo.Firms
    4)  Update Address Data back to dbo.Clients
    5)  Update Address Data back to dbo.FirmContacts
    6)  Update Address Data back to dbo.ClientContacts

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @processAddresses AS VARBINARY(128) = CAST( 'processAddresses' AS VARBINARY(128) ) ;


--  1)  Create dbo.AddressAudit records reflecting UPDATE
    INSERT  dbo.AddressAudit (
            AddressID
                , Address1, Address2, Address3
                , City, State, Zip
                , Verified
                , ChangeType
                , ModifiedDate, ModifiedUser )
    SELECT  d.AddressID
                , d.Address1, d.Address2, d.Address3
                , d.City, d.State, d.Zip
                , d.Verified
                , 'U'
                , i.ModifiedDate, i.ModifiedUser
      FROM  inserted AS i
INNER JOIN  deleted  AS d ON i.AddressID = d.AddressID ;


--  2)  Stop processing when trigger is invoked by Conversion.processAddresses procedure
    IF  CONTEXT_INFO() = @processAddresses RETURN ;


--  3)  Update Address Data back to edata.Firms
    UPDATE  edata.Firms
       SET  Address1   = i.Address1
          , Address2   = i.Address2
          , City       = i.City
          , [State]    = i.[State]
          , Zip        = i.Zip
          , ChangeDate = i.ModifiedDate
          , ChangeBy   = i.ModifiedUser
          , ChangeCode = 'CVAddress'
      FROM  inserted AS i
INNER JOIN  Conversion.LegacyAddresses AS la
        ON  la.AddressID = i.AddressID AND la.LegacyTableName = 'Firms'
INNER JOIN  edata.Firms AS f
        ON  f.FirmID = la.LegacyID ;


--  4)  Update Address Data back to edata.Clients
    UPDATE  edata.Clients
       SET  Address1   = i.Address1
          , Address2   = i.Address2
          , City       = i.City
          , [State]    = i.[State]
          , Zip        = i.Zip
          , ChangeDate = i.ModifiedDate
          , ChangeBy   = i.ModifiedUser
          , ChangeCode = 'CVAddress'
      FROM  inserted AS i
INNER JOIN  Conversion.LegacyAddresses AS la
        ON  la.AddressID = i.AddressID AND la.LegacyTableName = 'Clients'
INNER JOIN  edata.Clients AS c
        ON  c.ClientID = la.LegacyID ;


--  5)  Update Address Data back to edata.FirmContacts
    UPDATE  edata.FirmContacts
       SET  Address1   = i.Address1
          , Address2   = i.Address2
          , City       = i.City
          , [State]    = i.[State]
          , Zip        = i.Zip
          , ChangeDate = i.ModifiedDate
          , ChangeBy   = i.ModifiedUser
          , ChangeCode = 'CVAddress'
      FROM  inserted AS i
INNER JOIN  Conversion.LegacyAddresses AS la
        ON  la.AddressID = i.AddressID AND la.LegacyTableName = 'FirmContacts'
INNER JOIN  edata.FirmContacts AS fc
        ON  fc.ContactID = la.LegacyID ;


--  6)  Update Address Data back to edata.ClientContacts
    UPDATE  edata.ClientContacts
       SET  Address1   = i.Address1
          , Address2   = i.Address2
          , City       = i.City
          , [State]    = i.[State]
          , Zip        = i.Zip
          , ChangeDate = i.ModifiedDate
          , ChangeBy   = i.ModifiedUser
          , ChangeCode = 'CVAddress'
      FROM  inserted AS i
INNER JOIN  Conversion.LegacyAddresses AS la
        ON  la.AddressID = i.AddressID AND la.LegacyTableName = 'ClientContacts'
INNER JOIN  edata.ClientContacts AS cc
        ON  cc.ContactID = la.LegacyID ;
END
