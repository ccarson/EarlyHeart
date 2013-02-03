CREATE VIEW Conversion.vw_LegacyAddress
AS
/*
************************************************************************************************************************************

       View:    Conversion.vw_LegacyAddress
     Author:    Chris Carson
    Purpose:    shows "scrubbed" version of legacy Address data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Notes:

************************************************************************************************************************************
*/
  WITH  firmsData AS (
        SELECT  LegacyID        = f.FirmID
              , LegacyTableName = 'Firms'
              , AddressID       = ISNULL( la.AddressID, 0 )
              , Address1        = ISNULL( f.Address1, '' )
              , Address2        = ISNULL( f.Address2, '' )
              , City            = ISNULL( f.City, '' )
              , [State]         = ISNULL( f.[State], '' )
              , Zip             = ISNULL( f.Zip, '' )
              , ChangeDate      = ISNULL( f.ChangeDate, GETDATE() )
              , ChangeBy        = ISNULL( NULLIF ( f.ChangeBy, '' ), 'processAddresses')
          FROM  edata.dbo.Firms            AS f
     LEFT JOIN  Conversion.LegacyAddresses AS la
            ON  la.LegacyID = f.FirmID AND la.LegacyTableName = 'Firms' ) ,

        clientsData AS (
        SELECT  LegacyID        = c.ClientID
              , LegacyTableName = 'Clients'
              , AddressID       = ISNULL( la.AddressID, 0 )
              , Address1        = ISNULL( c.Address1, '' )
              , Address2        = ISNULL( c.Address2, '' )
              , City            = ISNULL( c.City, '' )
              , [State]         = ISNULL( c.[State], '' )
              , Zip             = ISNULL( c.Zip, '' )
              , ChangeDate      = ISNULL( c.ChangeDate, GETDATE() )
              , ChangeBy        = ISNULL( NULLIF ( c.ChangeBy, '' ), 'processAddresses')
          FROM  edata.dbo.Clients          AS c
     LEFT JOIN  Conversion.LegacyAddresses AS la
            ON  la.LegacyID = c.ClientID AND la.LegacyTableName = 'Clients' ) ,

        firmContactsData AS (
        SELECT  LegacyID        = fc.ContactID
              , LegacyTableName = 'FirmContacts'
              , AddressID       = ISNULL( la.AddressID, 0 )
              , Address1        = ISNULL( fc.Address1, '' )
              , Address2        = ISNULL( fc.Address2, '' )
              , City            = ISNULL( fc.City, '' )
              , [State]         = ISNULL( fc.[State], '' )
              , Zip             = ISNULL( fc.Zip, '' )
              , ChangeDate      = ISNULL( fc.ChangeDate, GETDATE() )
              , ChangeBy        = ISNULL( NULLIF ( fc.ChangeBy, '' ), 'processAddresses')
          FROM  edata.dbo.FirmContacts  AS fc
     LEFT JOIN  Conversion.LegacyAddresses AS la
            ON  la.LegacyID = fc.ContactID AND la.LegacyTableName = 'FirmContacts' ) ,

        clientContactsData AS (
        SELECT  LegacyID        = cc.ContactID
              , LegacyTableName = 'ClientContacts'
              , AddressID       = ISNULL( la.AddressID, 0 )
              , Address1        = ISNULL( cc.Address1, '' )
              , Address2        = ISNULL( cc.Address2, '' )
              , City            = ISNULL( cc.City, '' )
              , [State]         = ISNULL( cc.[State], '' )
              , Zip             = ISNULL( cc.Zip, '' )
              , ChangeDate      = ISNULL( cc.ChangeDate, GETDATE() )
              , ChangeBy        = ISNULL( NULLIF ( cc.ChangeBy, '' ), 'processAddresses')
          FROM  edata.dbo.ClientContacts    AS cc
     LEFT JOIN  Conversion.LegacyAddresses  AS la
            ON  la.LegacyID = cc.ContactID AND la.LegacyTableName = 'ClientContacts' ) ,

        inputData AS (
        SELECT  LegacyID, LegacyTableName, AddressID
                    , Address1, Address2, City, [State], Zip
                    , ChangeDate, ChangeBy
          FROM  firmsData
            UNION ALL
        SELECT  LegacyID, LegacyTableName, AddressID
                    , Address1, Address2, City, [State], Zip
                    , ChangeDate, ChangeBy
          FROM  clientsData
            UNION ALL
        SELECT  LegacyID, LegacyTableName, AddressID
                    , Address1, Address2, City, [State], Zip
                    , ChangeDate, ChangeBy
          FROM  firmContactsData
            UNION ALL
        SELECT  LegacyID, LegacyTableName, AddressID
                    , Address1, Address2, City, [State], Zip
                    , ChangeDate, ChangeBy
          FROM  clientContactsData )

SELECT  LegacyID, LegacyTableName, AddressID
            , Address1, Address2, City, [State], Zip
            , ChangeDate, ChangeBy
  FROM  inputData AS a
 WHERE  LEN(Address1) + LEN(Address2) + LEN(City) + LEN([State]) + LEN(Zip) > 0 ;

