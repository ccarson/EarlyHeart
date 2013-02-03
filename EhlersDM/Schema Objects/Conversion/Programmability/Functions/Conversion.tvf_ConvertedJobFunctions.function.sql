CREATE FUNCTION Conversion.tvf_ConvertedJobFunctions ( @Source AS VARCHAR(20) )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:    Conversion.tvf_ConvertedJobFunctions
     Author:    Chris Carson
    Purpose:    returns JobFunctions data in a table format


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Function Arguments:
    @Source     VARCHAR(20)     'Legacy'|'Converted'

    Notes:

************************************************************************************************************************************
*/
RETURN
  WITH  firmsData AS ( 
        SELECT  LegacyContactID = fc.ContactID
              , LegacyTableName = 'FirmContacts'
              , ContactID       = lc.ContactID
              , JobFunction     = fc.JobFunction
              , ModifiedDate    = ISNULL( fc.ChangeDate, GETDATE() )
              , ModifiedUser    = ISNULL( NULLIF( fc.ChangeBy, '' ) , 'processJobFunctions' )
          FROM  edata.dbo.FirmContacts    AS fc
    INNER JOIN  Conversion.LegacyContacts AS lc ON lc.LegacyContactID = fc.ContactID 
         WHERE  lc.LegacyTableName = 'FirmContacts' AND fc.JobFunction <> '' AND  @Source = 'Legacy'
           AND  EXISTS ( SELECT 1 FROM edata.dbo.Firms AS f WHERE f.FirmID = fc.FirmID ) ) , 

        clientsData AS (
        SELECT  LegacyContactID = cc.ContactID
              , LegacyTableName = 'ClientContacts'
              , ContactID       = lc.ContactID
              , JobFunction     = cc.JobFunction
              , ModifiedDate    = ISNULL( cc.ChangeDate, GETDATE() )
              , ModifiedUser    = ISNULL( NULLIF( cc.ChangeBy, '' ), 'processJobFunctions' )
          FROM  edata.dbo.ClientContacts  AS cc
    INNER JOIN  Conversion.LegacyContacts AS lc ON lc.LegacyContactID = cc.ContactID 
         WHERE  lc.LegacyTableName = 'ClientContacts' AND cc.JobFunction <> '' AND @Source = 'Legacy'
           AND  EXISTS ( SELECT 1 FROM edata.dbo.Clients AS c WHERE c.ClientID = cc.ClientID ) ) , 
           
        legacy  AS ( 
        SELECT  LegacyContactID = fd.LegacyContactID
              , LegacyTableName = fd.LegacyTableName
              , ContactID       = fd.ContactID
              , JobFunctionID   = jf.JobFunctionID
              , ModifiedDate    = fd.ModifiedDate
              , ModifiedUser    = fd.ModifiedUser 
          FROM  firmsData AS fd 
   CROSS APPLY  dbo.tvf_CSVSplit( fd.JobFunction , ',' ) AS x
    INNER JOIN  dbo.JobFunction AS jf ON jf.LegacyValue = x.Item AND jf.IsFirm= 1 AND jf.LegacyValue <> '' 
            UNION ALL 
        SELECT  LegacyContactID = cd.LegacyContactID
              , LegacyTableName = cd.LegacyTableName
              , ContactID       = cd.ContactID
              , JobFunctionID   = jf.JobFunctionID
              , ModifiedDate    = cd.ModifiedDate
              , ModifiedUser    = cd.ModifiedUser 
          FROM  clientsData AS cd 
   CROSS APPLY  dbo.tvf_CSVSplit( cd.JobFunction , ',' ) AS x
    INNER JOIN  dbo.JobFunction AS jf ON jf.LegacyValue = x.Item AND jf.IsClient= 1 AND jf.LegacyValue <> '' ) , 
    
        converted AS (
        SELECT  LegacyContactID = lc.LegacyContactID
              , LegacyTableName = lc.LegacyTableName
              , ContactID       = cj.ContactID
              , JobFunctionID   = cj.JobFunctionID
              , ModifiedDate    = cj.ModifiedDate
              , ModifiedUser    = cj.ModifiedUser
          FROM  dbo.ContactJobFunctions   AS cj
    INNER JOIN  dbo.JobFunction           AS jf ON cj.JobFunctionID = jf.JobFunctionID AND jf.LegacyValue <> ''
    INNER JOIN  Conversion.LegacyContacts AS lc ON lc.ContactID = cj.ContactID
         WHERE  cj.Active = 1 AND @Source = 'Converted' ) , 

        inputData AS (
        SELECT  LegacyContactID, LegacyTableName, ContactID, JobFunctionID, ModifiedDate, ModifiedUser FROM legacy
            UNION ALL
        SELECT  LegacyContactID, LegacyTableName, ContactID, JobFunctionID, ModifiedDate, ModifiedUser FROM converted ) 

SELECT  DISTINCT 
        LegacyContactID, LegacyTableName, ContactID, JobFunctionID, ModifiedDate, ModifiedUser
  FROM  inputData ;

GO