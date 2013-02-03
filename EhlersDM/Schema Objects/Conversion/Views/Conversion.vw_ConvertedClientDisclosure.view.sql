CREATE VIEW Conversion.vw_ConvertedClientDisclosure
/*
************************************************************************************************************************************

       View:    Conversion.vw_ConvertedClientDisclosure
     Author:    ccarson
    Purpose:    shows Legacy version of dbo.Client and dbo.ClientDocuments Data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Notes:

************************************************************************************************************************************
*/
AS
    SELECT  ClientID        = c.ClientID
          , DisclosureType  = CAST( CASE c.DisclosureContractType
                                        WHEN 'Full'     THEN 0
                                        WHEN 'Limited'  THEN 1
                                    END  AS INT )
          , ContractType    = CAST( CASE c.ContractBillingType
                                         WHEN 'Fee'      THEN 0
                                         WHEN 'Hourly'   THEN 1
                                         WHEN 'Client'   THEN 2
                                         ELSE 4
                                    END  AS INT )
          , ContractDate    = CAST( NULLIF( d.DocumentDate, '1900-01-01' ) AS SMALLDATETIME )
          , ChangeDate      = c.ModifiedDate
          , ChangeBy        = c.ModifiedUser
      FROM  dbo.Client           AS c
 LEFT JOIN  dbo.ClientDocument   AS d ON d.ClientID = c.ClientID
     WHERE  c.DisclosureContractType <> '' AND ISNULL( d.ClientDocumentNameID, 2 ) = 2 ;
