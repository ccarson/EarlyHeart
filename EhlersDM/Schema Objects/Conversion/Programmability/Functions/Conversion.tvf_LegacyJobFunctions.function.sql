CREATE FUNCTION Conversion.tvf_LegacyJobFunctions( @Source AS VARCHAR(20) )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:    Conversion.tvf_LegacyJobFunctions
     Author:    Chris Carson
    Purpose:    returns JobFunctions data in the legacy CSV field format


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Function Arguments:
    @Source     VARCHAR(20)     'Converted'|'Legacy'

    Notes:

************************************************************************************************************************************
*/
RETURN
  WITH  firmsData AS (
        SELECT  LegacyContactID = fc.ContactID
              , LegacyTableName = lc.LegacyTableName
              , ContactID       = lc.ContactID
              , JobFunction     = fc.JobFunction
          FROM  edata.dbo.FirmContacts    AS fc
     LEFT JOIN  Conversion.LegacyContacts AS lc ON lc.LegacyContactID = fc.ContactID
         WHERE  lc.LegacyTableName = 'FirmContacts' AND fc.JobFunction <> '' AND @Source = 'Legacy'
           AND  EXISTS ( SELECT 1 FROM edata.dbo.Firms AS f WHERE f.FirmID = fc.FirmID ) ) ,

        clientsData AS (
        SELECT  LegacyContactID = cc.ContactID
              , LegacyTableName = lc.LegacyTableName
              , ContactID       = lc.ContactID
              , JobFunction     = cc.JobFunction
          FROM  edata.dbo.ClientContacts  AS cc
     LEFT JOIN  Conversion.LegacyContacts AS lc ON lc.LegacyContactID = cc.ContactID
         WHERE  lc.LegacyTableName = 'ClientContacts' AND cc.JobFunction <> '' AND @Source = 'Legacy'
           AND  EXISTS ( SELECT 1 FROM edata.dbo.Clients AS c WHERE c.ClientID = c.ClientID ) ) ,

        legacy  AS (
        SELECT  LegacyContactID = f.ContactID
              , LegacyTableName = f.LegacyTableName
              , ContactID       = f.ContactID
              , Item            = x.Item
          FROM  firmsData                               AS f
   CROSS APPLY  dbo.tvf_CSVSplit( f.JobFunction , ',' ) AS x
    INNER JOIN  dbo.JobFunction AS j ON j.LegacyValue = x.Item AND j.IsFirm = 1 AND j.LegacyValue <> ''
            UNION ALL
        SELECT  LegacyContactID = c.ContactID
              , LegacyTableName = c.LegacyTableName
              , ContactID       = c.ContactID
              , Item            = x.Item
          FROM  clientsData                             AS c
   CROSS APPLY  dbo.tvf_CSVSplit( c.JobFunction , ',' ) AS x
    INNER JOIN  dbo.JobFunction                         AS j ON j.LegacyValue = x.Item AND j.IsClient = 1 AND j.LegacyValue <> '' ) ,

        converted AS (
        SELECT  LegacyContactID = lc.LegacyContactID
              , LegacyTableName = lc.LegacyTableName
              , ContactID       = cj.ContactID
              , Item            = jf.LegacyValue
          FROM  dbo.ContactJobFunctions   AS cj
    INNER JOIN  dbo.JobFunction           AS jf ON cj.JobFunctionID = jf.JobFunctionID AND jf.LegacyValue <> ''
    INNER JOIN  Conversion.LegacyContacts AS lc ON lc.ContactID = cj.ContactID
         WHERE  @Source = 'Converted' AND cj.Active = 1 ) ,

        inputData AS (
        SELECT  LegacyContactID, LegacyTableName, ContactID, Item FROM legacy
            UNION ALL
        SELECT  LegacyContactID, LegacyTableName, ContactID, Item FROM converted )

SELECT  DISTINCT
        LegacyContactID  = LegacyContactID
      , LegacyTableName  = LegacyTableName
      , ContactID        = ContactID
      , JobFunction      = CAST( STUFF( ( SELECT  ',' + Item
                                            FROM  inputData AS a
                                           WHERE  a.LegacyContactID     = b.LegacyContactID
                                                  AND a.LegacyTableName = b.LegacyTableName
                                                  AND a.ContactID       = b.ContactID
                                           ORDER  BY ',' + Item
                                             FOR  XML PATH ('') ), 1, 1, '' ) AS VARCHAR(50) )
  FROM  inputData AS b ;
