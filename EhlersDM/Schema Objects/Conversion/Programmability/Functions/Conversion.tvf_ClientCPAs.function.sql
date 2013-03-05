CREATE FUNCTION Conversion.tvf_ClientCPAs ( @Source AS VARCHAR(20) )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:  Conversion.tvf_ClientCPAs
     Author:  Chris Carson
    Purpose:  returns ClientCPAs from either legacy or converted systems


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
        SELECT  ClientID                =   c.ClientID
              , ClientCPA               =   c.ClientCPA
              , ClientCPAFirmID         =   ISNULL( c.ClientCPAFirmID, 0 )
              , FirmCategoriesID        =   ISNULL( fc.FirmCategoriesID, 0 )
          FROM  edata.Clients  AS c
     LEFT JOIN  dbo.Firm           AS f  ON f.FirmID          = c.ClientCPAFirmID
     LEFT JOIN  dbo.FirmCategories AS fc ON fc.FirmID         = f.firmID 
     LEFT JOIN  dbo.FirmCategory   AS ct ON ct.FirmCategoryID = fc.FirmCategoryID 
         WHERE  ISNULL( f.FirmName, c.ClientCPA ) = c.ClientCPA
		   AND  ISNULL(ct.LegacyValue, 'CCPA' )   = 'CCPA'
           AND  @Source = 'Legacy' ) ,

        converted AS (
        SELECT  ClientID                =   c.ClientID
              , ClientCPA               =   f.FirmName
              , ClientCPAFirmID         =   f.FirmID
              , FirmCategoriesID        =   c.FirmCategoriesID
          FROM  dbo.ClientFirms    AS c
    INNER JOIN  dbo.FirmCategories AS fc ON fc.FirmCategoriesID = c.FirmCategoriesID
    INNER JOIN  dbo.FirmCategory   AS ct ON ct.FirmCategoryID   = fc.FirmCategoryID 
    INNER JOIN  dbo.Firm           AS f  ON f.FirmID            = fc.FirmID 
         WHERE  ct.LegacyValue = 'CCPA' 
           AND  @Source = 'Converted') ,
    
    inputData AS ( 
    SELECT  ClientID, ClientCPA, ClientCPAFirmID, FirmCategoriesID FROM legacy 
        UNION ALL
    SELECT  ClientID, ClientCPA, ClientCPAFirmID, FirmCategoriesID FROM converted ) 
            
SELECT  ClientID
      , ClientCPA
      , ClientCPAFirmID
      , FirmCategoriesID 
  FROM  inputData ; 
