CREATE FUNCTION Conversion.tvf_FirmCategories( @Source AS VARCHAR(20)
                                             , @Format AS VARCHAR(20) )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:  Conversion.tvf_FirmCategories
     Author:  Chris Carson
    Purpose:  returns FirmCategories from either legacy or converted in a comparable format


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Function Arguments:
    @Source     VARCHAR(20)     'Legacy'|'Converted'
    @Format     VARCHAR(20)     'CSV', 'Table'

    Notes:
    'CSV' returns the legacy version of the edata.dbo.Firms.FirmCategory field, UPPERed and Sorted
    'Table' returns FirmCategories in a table format, and includes the dbo.FirmCategory.FirmCategoryID for each record

************************************************************************************************************************************
*/
RETURN
  WITH  legacy AS (
        SELECT  FirmID           = f.FirmID
              , FirmCategoriesID = fcs.FirmCategoriesID
              , FirmCategoryID   = fct.FirmCategoryID
              , Item             = CAST( UPPER(x.Item) AS VARCHAR(50) )
          FROM  edata.dbo.Firms AS f
   CROSS APPLY  dbo.tvf_CSVSplit( f.FirmCategory, ',' ) AS x
    INNER JOIN  dbo.FirmCategory    AS fct
            ON  fct.LegacyValue = x.Item AND fct.LegacyValue <> ''
    LEFT  JOIN  dbo.FirmCategories AS fcs
            ON  fcs.FirmID = f.firmID and fcs.FirmCategoryID = fct.FirmCategoryID
         WHERE  @Source = 'Legacy' ) ,

        converted AS (
        SELECT  FirmID              = fcs.FirmID
              , FirmCategoriesID    = fcs.FirmCategoriesID
              , FirmCategoryID      = fcs.FirmCategoryID
              , Item                = CAST( UPPER(fct.LegacyValue) AS VARCHAR(50) )
          FROM  dbo.FirmCategories AS fcs
    INNER JOIN  dbo.FirmCategory   AS fct
            ON  fct.FirmCategoryID = fcs.FirmCategoryID AND fct.LegacyValue <> ''
         WHERE  @Source = 'Converted') ,

        inputData AS (
        SELECT  FirmID, FirmCategoriesID, FirmCategoryID, Item FROM legacy    UNION ALL
        SELECT  FirmID, FirmCategoriesID, FirmCategoryID, Item FROM converted )

SELECT  FirmID           = FirmID
      , FirmCategoriesID = NULL
      , FirmCategoryID   = NULL
      , FirmCategory     = CAST( STUFF( ( SELECT  ',' + Item
                                            FROM  inputData AS a
                                           WHERE  a.FirmID = b.FirmID
                                        ORDER BY  ',' + Item
                                             FOR  XML PATH ('') ), 1, 1, '' ) AS VARCHAR(50) )
  FROM  inputData AS b
 WHERE  @Format = 'CSV'
    UNION
SELECT  FirmID           = FirmID
      , FirmCategoriesID = FirmCategoriesID
      , FirmCategoryID   = FirmCategoryID
      , FirmCategory     = Item
  FROM  inputData
 WHERE  @Format = 'Table' ;
