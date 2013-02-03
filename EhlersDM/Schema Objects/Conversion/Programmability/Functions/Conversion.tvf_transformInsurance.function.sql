CREATE FUNCTION Conversion.tvf_transformInsurance()
RETURNS TABLE 
WITH SCHEMABINDING AS
/*
************************************************************************************************************************************

   Function:    Conversion.tvf_transformInsurance
     Author:    Chris Carson
    Purpose:    given the legacy Insurance value, returns the converted FirmID


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Function Arguments:

    Notes:

************************************************************************************************************************************
*/
RETURN
      WITH  insuranceMapping ( Insurance, FullName ) AS (
            SELECT  'ACA'      , 'ACA Financial Guaranty Corporation'     UNION ALL
            SELECT  'AGC'      , 'Assured Guaranty Corporation'           UNION ALL
            SELECT  'AGM'      , 'Assured Guaranty Municipal Corporation' UNION ALL
            SELECT  'AMBA'     , 'Ambac Indemnity Corporation'            UNION ALL
            SELECT  'AMBAC'    , 'Ambac Indemnity Corporation'            UNION ALL
            SELECT  'CIFG'     , 'CIFG Assurance North America, Inc.'     UNION ALL
            SELECT  'FGIC'     , 'FGIC'                                   UNION ALL
            SELECT  'FSA'      , 'Assured Guaranty Corporation'           UNION ALL
            SELECT  'RAA'      , 'Radian Asset Assurance Inc.'            UNION ALL
            SELECT  'RADIA'    , 'Radian Asset Assurance Inc.'            UNION ALL
            SELECT  'Radian'   , 'Radian Asset Assurance Inc.'            UNION ALL
            SELECT  'XLCA'     , 'Syncora Guarantee'                      UNION ALL
            SELECT  'XLCapital', 'Syncora Guarantee' )

    SELECT  InsuranceFirmCategoriesID = FirmCategoriesID
          , Insurance
      FROM  insuranceMapping AS i
 LEFT JOIN  dbo.Firm AS f
        ON  i.FullName = f.FirmName
 LEFT JOIN  dbo.FirmCategories AS fc
        ON  fc.FirmID = f.FirmID AND fc.FirmCategoryID = 4 ;
