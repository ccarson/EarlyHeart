CREATE VIEW Conversion.vw_LegacyBidAnnual
/*
************************************************************************************************************************************

       View:    Conversion.vw_LegacyBidAnnual
     Author:    Chris Carson
    Purpose:    consolidates and scrubs data from the edata.BidAnnual and edata.InternetBidAnnual tables


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Notes:

    Notes:

************************************************************************************************************************************
*/
AS
    SELECT  BidderID                = CAST( NULL AS INT )
          , IssueID                 = IssueID
          , FirmID                  = FirmID
          , PaymentDate             = CAST( MaturityDate     AS DATE )
          , PaymentAmount           = CAST( maturity         AS DECIMAL(15,2) )
          , OrginalPaymentAmount    = CAST( OriginalMaturity AS DECIMAL(15,2) )
          , InterestRate            = CAST( coupon           AS DECIMAL(6,3) )
          , TermBond                = TermBond
      FROM  edata.BidAnnual AS ba
     WHERE  EXISTS ( SELECT 1 FROM edata.Firms AS f WHERE f.FirmID = ba.FirmID ) 
       AND  EXISTS ( SELECT 1 FROM edata.Issues AS i WHERE i.IssueID = ba.IssueID ) 
        UNION ALL
    SELECT  BidderID                = CAST( NULL AS INT )
          , IssueID                 = iba.IssueID
          , FirmID                  = iba.FirmID
          , PaymentDate             = CAST( iba.MaturityDate AS DATE )
          , PaymentAmount           = CAST( iba.maturity     AS DECIMAL(15,2) )
          , OrginalPaymentAmount    = CAST( 0                AS DECIMAL(15,2) )
          , InterestRate            = CAST( iba.coupon       AS DECIMAL(6,3) )          
          , TermBond                = iba.TermBond
      FROM  edata.InternetBidAnnual AS iba
     WHERE  NOT EXISTS ( SELECT 1 FROM edata.BidAnnual AS ba
                          WHERE ba.IssueID = iba.IssueID
                            AND ba.FirmID = iba.FirmID
                            AND ba.MaturityDate = iba.MaturityDate ) 
       AND  EXISTS ( SELECT 1 FROM edata.Firms AS f WHERE f.FirmID = iba.FirmID ) 
       AND  EXISTS ( SELECT 1 FROM edata.Issues AS i WHERE i.IssueID = iba.IssueID ) ; 
