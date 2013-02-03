CREATE FUNCTION Conversion.tvf_ConvertedFirmCategories( @Source AS VARCHAR(20) )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:  Conversion.tvf_ConvertedFirmCategories
     Author:  Chris Carson
    Purpose:  returns FirmCategories from in a table format


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Function Arguments:
    @Source     VARCHAR(20)     'Legacy'|'Converted'

    Notes:
    This view excludes dbo.FirmCategory recrods that do not convert back to legacy

************************************************************************************************************************************
*/
RETURN
  WITH  legacy AS (
        SELECT  FirmID           = f.FirmID
              , FirmCategoryID   = fct.FirmCategoryID
          FROM  edata.dbo.Firms AS f
   CROSS APPLY  dbo.tvf_CSVSplit( f.FirmCategory, ',' ) AS x
    INNER JOIN  dbo.FirmCategory    AS fct
            ON  fct.LegacyValue = x.Item AND fct.LegacyValue <> ''
         WHERE  @Source = 'Legacy' ) ,

        converted AS (
        SELECT  FirmID              = fcs.FirmID
              , FirmCategoryID      = fcs.FirmCategoryID
          FROM  dbo.FirmCategories AS fcs
    INNER JOIN  dbo.FirmCategory   AS fct
            ON  fct.FirmCategoryID = fcs.FirmCategoryID AND fct.LegacyValue <> '' AND fcs.Active = 1
         WHERE  @Source = 'Converted') ,

        inputData AS (
        SELECT  FirmID, FirmCategoryID FROM legacy    UNION ALL
        SELECT  FirmID, FirmCategoryID FROM converted )

SELECT  FirmID           = FirmID
      , FirmCategoryID   = FirmCategoryID
  FROM  inputData ; 
  