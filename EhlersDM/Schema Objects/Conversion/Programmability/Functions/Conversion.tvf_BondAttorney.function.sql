CREATE FUNCTION Conversion.tvf_BondAttorney ( @Source AS VARCHAR(20) )
RETURNS TABLE AS
/*
************************************************************************************************************************************

   Function:    Conversion.tvf_IssueFirms
     Author:    Chris Carson
    Purpose:    returns professional services data in a format that can be used by legacy and converted systems


    revisor         date                description
    ---------       ----------          ----------------------------
    ccarson         2013-01-24          created


    Function Arguments:
    @Source     VARCHAR(20)    'Legacy'|'Converted'

    Notes:

************************************************************************************************************************************
*/
RETURN
  WITH  issueFirmsData AS (
        SELECT  IssueFirmsID        = a.IssueFirmsID
              , IssueID             = a.IssueID
              , FirmCategoriesID    = a.FirmCategoriesID
              , FirmID              = b.FirmID 
              , FirmName            = f.FirmName
              , ModifiedDate        = a.ModifiedDate
              , ModifiedUser        = a.ModifiedUser
          FROM  dbo.IssueFirms                           AS a 
    INNER JOIN  Conversion.tvf_IssueFirms( 'Converted' ) AS b 
            ON  b.IssueID = a.IssueID AND b.FirmCategoriesID = a.FirmCategoriesID
    INNER JOIN  dbo.Firm AS f ON f.FirmID = b.FirmID 
         WHERE  Category = 'bc' ) , 
        
        bondAttorney AS ( 
        SELECT  FirmID                = fc.FirmID
              , ContactJobFunctionsID = cjf.ContactJobFunctionsID
              , Attorney              = c.FirstName + ' ' + c.LastName 
          FROM  dbo.Contact             AS c 
    INNER JOIN  dbo.FirmContacts        AS fc  ON fc.ContactID = c.ContactID
    INNER JOIN  dbo.ContactJobFunctions AS cjf ON cjf.ContactID = c.ContactID
    INNER JOIN  dbo.JobFunction         AS jf  ON jf.JobFunctionID = cjf.JobFunctionID
         WHERE  jf.Value = 'Bond Attorney' 
           AND  EXISTS ( SELECT 1 FROM issueFirmsData AS i WHERE i.FirmID = fc.FirmID ) ) , 
         
        legacy AS ( 
        SELECT  IssueFirmsID            = f.IssueFirmsID
              , ContactJobFunctionsID   = a.ContactJobFunctionsID
              , ModifiedDate            = ISNULL( i.ChangeDate, GETDATE() ) 
              , ModifiedUser            = ISNULL( NULLIF( i.ChangeBy, 'processIssues' ), 'processBondAttorney' )
              , Attorney                = a.Attorney
              , FirmID                  = f.FirmID
              , FirmName                = f.FirmName
              , IssueID                 = i.IssueID
          FROM  edata.dbo.Issues AS i 
    INNER JOIN  issueFirmsData   AS f ON i.IssueID = f.IssueID
    INNER JOIN  bondAttorney     AS a ON a.FirmID  = f.FirmID AND i.Attorney = a.Attorney
         WHERE  @Source = 'Legacy' ) , 
        
        converted AS ( 
        SELECT  IssueFirmsID            = ifc.IssueFirmsID
              , ContactJobFunctionsID   = ifc.ContactJobFunctionsID
              , ModifiedDate            = ifc.ModifiedDate
              , ModifiedUser            = ifc.ModifiedUser
              , Attorney                = ba.Attorney
              , FirmID                  = isf.FirmID
              , FirmName                = isf.FirmName
              , IssueID                 = isf.IssueID
          FROM  dbo.IssueFirmsContacts  AS ifc
    INNER JOIN  bondAttorney            AS ba  ON ba.ContactJobFunctionsID = ifc.ContactJobFunctionsID
    INNER JOIN  issueFirmsData          AS isf ON isf.IssueFirmsID = ifc.IssueFirmsID
         WHERE  @Source = 'Converted' ) 

    SELECT  IssueFirmsID, ContactJobFunctionsID, ModifiedDate, ModifiedUser, Attorney, FirmID, FirmName, IssueID                 
      FROM  legacy
        UNION ALL
    SELECT  IssueFirmsID, ContactJobFunctionsID, ModifiedDate, ModifiedUser, Attorney, FirmID, FirmName, IssueID                 
      FROM  converted ;
GO

