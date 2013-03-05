CREATE FUNCTION Conversion.tvf_AddressChecksum ( @LegacyTableName AS VARCHAR(20) )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:    Conversion.tvf_AddressChecksum
     Author:    Chris Carson
    Purpose:    computes the checksum for a given AddressID


    revisor         date                description
    ---------       ----------          ----------------------------
    ccarson         2013-01-24          created


    Function Arguments:
    @LegacyTableName    VARCHAR(20)     'Address'|'Firms'|'Clients'|'FirmContacts'|'ClientContacts'

    Notes:

************************************************************************************************************************************
*/
RETURN
  WITH  blankAddress AS (
        SELECT  invalidAddress =
                CAST( HASHBYTES ( 'md5', CAST( 0 AS NVARCHAR(20) )
                                            + QUOTENAME( '' )
                                            + QUOTENAME( '' )
                                            + QUOTENAME( '' )
                                            + QUOTENAME( '' )
                                            + QUOTENAME( '' ) ) AS VARBINARY(128) ) ) ,

        firms AS (
        SELECT  LegacyID        = f.FirmID
              , LegacyTableName = @LegacyTableName
              , AddressID       = ISNULL( la.AddressID, 0 )
              , Address1        = QUOTENAME( ISNULL( f.Address1, '' ) )
              , Address2        = QUOTENAME( ISNULL( f.Address2, '' ) )
              , City            = QUOTENAME( ISNULL( f.City, '' ) )
              , [State]         = QUOTENAME( ISNULL( f.[State], '' ) )
              , Zip             = QUOTENAME( ISNULL( f.Zip, '' ) )
          FROM  edata.Firms            AS f
     LEFT JOIN  Conversion.LegacyAddresses AS la
            ON  la.LegacyID = f.FirmID AND la.LegacyTableName = @LegacyTableName
         WHERE  @LegacyTableName = 'Firms' ) ,

        clients AS (
        SELECT  LegacyID        = c.ClientID
              , LegacyTableName = @LegacyTableName
              , AddressID       = ISNULL( la.AddressID, 0 )
              , Address1        = QUOTENAME( ISNULL( c.Address1, '' ) )
              , Address2        = QUOTENAME( ISNULL( c.Address2, '' ) )
              , City            = QUOTENAME( ISNULL( c.City, '' ) )
              , [State]         = QUOTENAME( ISNULL( c.[State], '' ) )
              , Zip             = QUOTENAME( ISNULL( c.Zip, '' ) )
          FROM  edata.Clients   AS c
     LEFT JOIN  Conversion.LegacyAddresses AS la
            ON  la.LegacyID = c.ClientID AND la.LegacyTableName = @LegacyTableName
         WHERE  @LegacyTableName = 'Clients' ) ,

        clientContacts AS (
        SELECT  LegacyID        = cc.ContactID
              , LegacyTableName = @LegacyTableName
              , AddressID       = ISNULL( la.AddressID,0 )
              , Address1        = QUOTENAME( ISNULL( cc.Address1, '' ) )
              , Address2        = QUOTENAME( ISNULL( cc.Address2, '' ) )
              , City            = QUOTENAME( ISNULL( cc.City, '' ) )
              , [State]         = QUOTENAME( ISNULL( cc.[State], '' ) )
              , Zip             = QUOTENAME( ISNULL( cc.Zip, '' ) )
          FROM  edata.ClientContacts  AS cc
    INNER JOIN  Conversion.LegacyContacts AS lc
            ON  lc.LegacyContactID = cc.ContactID AND lc.LegacyTableName = @LegacyTableName
     LEFT JOIN  Conversion.LegacyAddresses AS la
            ON  la.LegacyID = cc.ContactID AND la.LegacyTableName = @LegacyTableName
         WHERE  @LegacyTableName = 'ClientContacts' ) ,

        firmContacts AS (
        SELECT  LegacyID        = fc.ContactID
              , LegacyTableName = @LegacyTableName
              , AddressID       = ISNULL( la.AddressID,0 )
              , Address1        = QUOTENAME( ISNULL( fc.Address1, '' ) )
              , Address2        = QUOTENAME( ISNULL( fc.Address2, '' ) )
              , City            = QUOTENAME( ISNULL( fc.City, '' ) )
              , [State]         = QUOTENAME( ISNULL( fc.[State], '' ) )
              , Zip             = QUOTENAME( ISNULL( fc.Zip, '' ) )
          FROM  edata.FirmContacts  AS fc
    INNER JOIN  Conversion.LegacyContacts AS lc
            ON  lc.LegacyContactID = fc.ContactID AND lc.LegacyTableName = @LegacyTableName
     LEFT JOIN  Conversion.LegacyAddresses AS la
            ON  la.LegacyID = fc.ContactID AND la.LegacyTableName = @LegacyTableName
         WHERE  @LegacyTableName = 'FirmContacts' ) ,

        addresses AS (
        SELECT  LegacyID        = la.LegacyID
              , LegacyTableName = la.LegacyTableName
              , AddressID       = a.AddressID
              , Address1        = QUOTENAME( a.Address1 )
              , Address2        = QUOTENAME( a.Address2 )
              , City            = QUOTENAME( a.City )
              , [State]         = QUOTENAME( a.[State] )
              , Zip             = QUOTENAME( a.Zip )
          FROM  dbo.Address AS a
    INNER JOIN  Conversion.LegacyAddresses AS la
            ON  la.AddressID = a.AddressID
         WHERE  @LegacyTableName = 'Address' ) ,

        inputData AS (
        SELECT  LegacyID, LegacyTableName, AddressID, Address1, Address2, City, [State], Zip FROM firms          UNION ALL
        SELECT  LegacyID, LegacyTableName, AddressID, Address1, Address2, City, [State], Zip FROM clients        UNION ALL
        SELECT  LegacyID, LegacyTableName, AddressID, Address1, Address2, City, [State], Zip FROM clientContacts UNION ALL
        SELECT  LegacyID, LegacyTableName, AddressID, Address1, Address2, City, [State], Zip FROM firmContacts   UNION ALL
        SELECT  LegacyID, LegacyTableName, AddressID, Address1, Address2, City, [State], Zip FROM addresses ) ,

        rawData AS (
        SELECT  LegacyID        = LegacyID
              , LegacyTableName = LegacyTableName
              , AddressID       = AddressID
              , AddressChecksum = CAST( HASHBYTES ( 'md5', CAST( AddressID AS NVARCHAR(20) )
                                                               + Address1
                                                               + Address2
                                                               + City
                                                               + State
                                                               + Zip ) AS VARBINARY(128) )
          FROM  inputData )

SELECT  LegacyID, LegacyTableName, AddressID, AddressChecksum
  FROM  rawData AS a
 WHERE  NOT EXISTS ( SELECT 1 from blankAddress AS b
                      WHERE b.invalidAddress = a.addressChecksum ) ;
