CREATE VIEW Conversion.vw_ConvertedAddress
/*
************************************************************************************************************************************

       View:    Conversion.vw_ConvertedAddress
     Author:    Chris Carson
    Purpose:    expanded view of current converted Address Data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Notes:

************************************************************************************************************************************
*/
AS
SELECT  LegacyID        = la.LegacyID
      , LegacyTableName = la.LegacyTableName
      , AddressID       = a.AddressID
      , Address1        = a.Address1
      , Address2        = a.Address2
      , City            = a.City
      , [State]         = a.[State]
      , Zip             = a.Zip
      , ChangeDate      = a.ModifiedDate
      , ChangeBy        = a.ModifiedUser
  FROM  dbo.Address AS a
  JOIN  Conversion.LegacyAddresses AS la
    ON  la.AddressID = a.AddressID ;
