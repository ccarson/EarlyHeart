CREATE TRIGGER dbo.tr_ClientAddresses_Insert ON dbo.ClientAddresses
AFTER INSERT
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_ClientAddresses_Insert
     Author:    Chris Carson
    Purpose:    loads dbo.Address data back to edata.Clients


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Create ClientAddressesAudit records reflecting INSERTs
    2)  Stop processing when trigger is invoked by Conversion.processAddresses procedure
    3)  Update Address Data back to dbo.ClientContacts
    4)  Create records on Conversion.LegacyAddresses

    Notes:

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @fromConversion AS VARBINARY (128) = CAST( 'fromConversion' AS VARBINARY (128) ) ; ;


--  1)  Create ClientAddressesAudit records reflecting INSERTs
    INSERT  dbo.ClientAddressesAudit (
                ClientAddressesID, ClientID, AddressID
                    , AddressTypeID, ChangeType
                    , ModifiedDate, ModifiedUser )
    SELECT  ClientAddressesID, ClientID, AddressID
                , AddressTypeID, 'I'
                , ModifiedDate, ModifiedUser 
      FROM  inserted ;


--  2)  Stop processing when trigger is invoked by Conversion.processAddresses procedure
    IF  CONTEXT_INFO() = @fromConversion
        RETURN ;


--  3)  Update Address Data back to dbo.Clients
    UPDATE  edata.Clients 
       SET  Address1    = a.Address1
          , Address2    = a.Address2
          , City        = a.City
          , State       = a.State
          , Zip         = a.Zip
          , ChangeDate  = i.ModifiedDate
          , ChangeBy    = i.ModifiedUser
          , ChangeCode = 'CVAddress'
      FROM  edata.Clients AS c
INNER JOIN  inserted AS i
        ON  i.ClientID= c.ClientID AND i.AddressTypeID = 3
INNER JOIN  dbo.Address AS a
        ON  a.AddressID = i.AddressID ; 


--  4)  Create records on Conversion.LegacyAddresses
    INSERT  Conversion.LegacyAddresses ( LegacyID, LegacyTableName, AddressID )
    SELECT  i.ClientID, 'Clients', i.AddressID
      FROM  inserted AS i
     WHERE  i.AddressTypeID = 3 ;
END
