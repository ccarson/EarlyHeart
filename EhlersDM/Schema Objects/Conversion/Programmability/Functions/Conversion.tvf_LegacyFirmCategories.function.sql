CREATE FUNCTION Conversion.tvf_LegacyFirmCategories( @Source AS VARCHAR(20) )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:  Conversion.tvf_LegacyFirmCategories
     Author:  Chris Carson
    Purpose:  returns FirmCategories from either legacy or converted in a CSV list format


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Function Arguments:
    @Source     VARCHAR(20)     'Legacy'|'Converted'

    Notes:
    Note that not all converted FirmCategory records will convert back to legacy
    
************************************************************************************************************************************
*/
RETURN
  WITH  legacy AS (
        SELECT  FirmID           = f.FirmID
              , Item             = CAST( x.Item AS VARCHAR(50) )
          FROM  edata.Firms AS f
   CROSS APPLY  dbo.tvf_CSVSplit( f.FirmCategory, ',' ) AS x
    INNER JOIN  dbo.FirmCategory    AS fct
            ON  fct.LegacyValue = x.Item AND fct.LegacyValue <> ''
         WHERE  @Source = 'Legacy' ) ,

        converted AS (
        SELECT  FirmID              = fcs.FirmID
              , Item                = CAST( fct.LegacyValue AS VARCHAR(50) )
          FROM  dbo.FirmCategories AS fcs
    INNER JOIN  dbo.FirmCategory   AS fct
            ON  fct.FirmCategoryID = fcs.FirmCategoryID AND fct.LegacyValue <> '' AND fcs.Active = 1
         WHERE  @Source = 'Converted') ,

        inputData AS (
        SELECT  FirmID, Item FROM legacy    UNION ALL
        SELECT  FirmID, Item FROM converted )

SELECT  DISTINCT 
        FirmID           = FirmID
      , FirmCategory     = CAST( STUFF( ( SELECT  ',' + Item
                                            FROM  inputData AS a
                                           WHERE  a.FirmID = b.FirmID
                                        ORDER BY  ',' + Item
                                             FOR  XML PATH ('') ), 1, 1, '' ) AS VARCHAR(50) )
  FROM  inputData AS b ;
