CREATE VIEW Conversion.vw_LegacyMaturities
/*
************************************************************************************************************************************

       View:    Conversion.vw_LegacyMaturities
     Author:    Chris Carson
    Purpose:    shows "scrubbed" version of edata.Maturities data

    Revision History:
    revisor     date            description
    ---------   -----------     ----------------------------
    ccarson     2012-09-10      Created
    ccarson     2013-02-01      Modified to exclude orphaned issues
    ccarson     ###DATE###      Issues Conversion
    
    Notes:

************************************************************************************************************************************
*/
AS
      WITH  insurance AS ( 
            SELECT  m.issueID
                  , a.InsuranceFirmCategoriesID
                  , a.Insurance
                  , N = ROW_NUMBER() OVER ( PARTITION BY IssueID ORDER BY (SELECT NULL) ) 
              FROM  edata.Maturities AS m
        INNER JOIN  Conversion.tvf_transformInsurance() AS a ON a.Insurance = m.Insurance ) 
    SELECT  IssueID                     = m.IssueID
          , InsuranceFirmCategoriesID   = a.InsuranceFirmCategoriesID
          , Insurance                   = ISNULL( m.Insurance , '' )
          , PaymentDate                 = m.MaturityDate
          , IssueAmount                 = CAST( m.maturity             AS DECIMAL(15,2) )
          , RefundAmount                = CAST( m.RefundedAmount       AS DECIMAL(15,2) )
          , Cusip3                      = CAST( ISNULL( m.c3,'' )      AS CHAR(3) )
          , InterestRate                = CAST( m.coupon               AS DECIMAL(7,4) )
          , Term                        = m.term
          , PriceToCall                 = m.ptc
          , ReofferingYield             = CAST( ISNULL( m.reoffer, 0 ) AS DECIMAL(7,4) )
          , NotReoffered                = m.nro
      FROM  edata.Maturities AS m
INNER JOIN  dbo.Issue        AS i ON i.IssueID = m.IssueID
 LEFT JOIN  insurance        AS a ON m.IssueID = a.IssueID AND ISNULL(a.N, 1) = 1 