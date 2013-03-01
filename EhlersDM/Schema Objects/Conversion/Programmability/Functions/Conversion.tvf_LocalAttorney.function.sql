CREATE FUNCTION Conversion.tvf_LocalAttorney ( @Source AS VARCHAR(20) )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:  Conversion.tvf_LocalAttorney
     Author:  Chris Carson
    Purpose:  returns Local Attorney from either legacy or converted systems


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Function Arguments:
    @Source     VARCHAR(20)     'Legacy'|'Converted'

    Notes:

************************************************************************************************************************************
*/
RETURN

  WITH  legacy AS (
        SELECT  ClientID            = c.ClientID
              , LocalAttorney       = c.LocalAttorney
              , FirmCategoriesID    = ISNULL( fc.FirmCategoriesID, 0 )
          FROM  edata.Clients  AS c
     LEFT JOIN  dbo.Firm           AS f  ON f.FirmName        = c.LocalAttorney
     LEFT JOIN  dbo.FirmCategories AS fc ON fc.FirmID         = f.firmID
     LEFT JOIN  dbo.FirmCategory   AS ct ON ct.FirmCategoryID = fc.FirmCategoryID
         WHERE  ISNULL( f.FirmName, c.LocalAttorney ) = c.LocalAttorney
           AND  ISNULL( ct.LegacyValue, 'LATTY' )   = 'LATTY'
           AND  c.LocalAttorney <> '' 
           AND  @Source = 'Legacy' ) ,

        converted AS (
        SELECT  ClientID            = c.ClientID
              , LocalAttorney       = f.FirmName
              , FirmCategoriesID    = c.FirmCategoriesID
          FROM  dbo.ClientFirms    AS c
    INNER JOIN  dbo.FirmCategories AS fc ON fc.FirmCategoriesID = c.FirmCategoriesID
    INNER JOIN  dbo.FirmCategory   AS ct ON ct.FirmCategoryID   = fc.FirmCategoryID
    INNER JOIN  dbo.Firm           AS f  ON f.FirmID            = fc.FirmID
         WHERE  ct.LegacyValue = 'LATTY'
           AND  @Source = 'Converted') ,

    inputData AS (
    SELECT  ClientID, LocalAttorney, FirmCategoriesID FROM legacy
        UNION ALL
    SELECT  ClientID, LocalAttorney, FirmCategoriesID FROM converted )

SELECT  ClientID
      , LocalAttorney
      , FirmCategoriesID
  FROM  inputData ;
