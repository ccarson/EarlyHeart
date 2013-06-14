CREATE VIEW Conversion.vw_ConvertedIssues
/*
************************************************************************************************************************************

       View:    Conversion.vw_ConvertedIssues
     Author:    Chris Carson
    Purpose:    shows legacy view of converted dbo.Issue table


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         ###DATE###          created -- Issues Conversion

    Notes:

************************************************************************************************************************************
*/
AS
      WITH  taxStatusValue AS (
            SELECT  OldListValue
                  , DisplayValue
              FROM  dbo.StaticList
             WHERE  ListCategoryID = 279 )

    SELECT  IssueID                 =  iss.IssueID
          , DatedDate               =  iss.DatedDate
          , Amount                  =  iss.IssueAmount
          , ClientID                =  iss.ClientID
          , IssueName               =  iss.IssueName
          , ShortName               =  shn.LegacyValue
          , IssueStatus             =  ISNULL( sta.LegacyValue, '' )
          , cusip6                  =  iss.Cusip6
          , IssueType               =  ist.LegacyValue
          , SaleType                =  CASE
                                            WHEN mos.LegacyValue <> ''                      THEN mos.LegacyValue
                                            WHEN iss.InitialOfferingDocumentID = 2          THEN 'N'
                                            WHEN iss.InitialOfferingDocumentID IN ( 5,6 )   THEN 'NN'
                                            WHEN iss.InitialOfferingDocumentID = 4          THEN 'NP'
                                            ELSE NULL
                                        END
          , TaxStatus               =  tsv.OldListValue
          , BondForm                =  ISNULL( NULLIF( bft.LegacyValue, 'BT,C' ), 'C' )
          , BankQualified           =  CASE iss.BankQualified WHEN 1 THEN 'Y' ELSE 'N' END
          , SecurityType            =  sct.LegacyValue
          , SaleDate                =  iss.SaleDate
          , SaleTime                =  iss.SaleTime
          , SettlementDate          =  iss.SettlementDate
          , FirstCouponDate         =  iss.FirstInterestDate
          , IntPmtFreq              =  ipf.LegacyValue
          , IntCalcMeth             =  icm.LegacyValue
          , CouponType              =  itt.LegacyValue
          , CallFrequency           =  clf.LegacyValue
          , DisclosureType          =  dst.LegacyValue
          , PurchasePrice           =  iss.PurchasePrice
          , Notes                   =  iss.Notes
          , NotesRefundedBy         =  iss.RefundedByNote
          , NotesRefunds            =  iss.RefundsNote
          , ArbitrageYield          =  iss.ArbitrageYield
          , QualityControlDate      =  iss.QCDate
          , Purpose                 =  iss.LongDescription
          , ChangeDate              =  iss.ModifiedDate
          , ChangeBy                =  iss.ModifiedUser
          , ObligorClientID         =  iss.ObligorClientID
          , EIPInvest               =  iss.IsEIPInvest
      FROM  dbo.Issue               AS iss
 LEFT JOIN  dbo.IssueShortName      AS shn ON shn.IssueShortNameID      = iss.IssueShortNameID
 LEFT JOIN  dbo.IssueStatus         AS sta ON sta.IssueStatusID         = iss.IssueStatusID
 LEFT JOIN  dbo.IssueType           AS ist ON ist.IssueTypeID           = iss.IssueTypeID
 LEFT JOIN  dbo.MethodOfSale        AS mos ON mos.MethodOfSaleID        = iss.MethodOfSaleID
 LEFT JOIN  dbo.BondFormType        AS bft ON bft.BondFormTypeID        = iss.BondFormTypeID
 LEFT JOIN  dbo.SecurityType        AS sct ON sct.SecurityTypeID        = iss.SecurityTypeID
 LEFT JOIN  dbo.InterestPaymentFreq AS ipf ON ipf.InterestPaymentFreqID = iss.InterestPaymentFreqID
 LEFT JOIN  dbo.InterestCalcMethod  AS icm ON icm.InterestCalcMethodID  = iss.InterestCalcMethodID
 LEFT JOIN  dbo.InterestType        AS itt ON itt.InterestTypeID        = iss.InterestTypeID
 LEFT JOIN  dbo.CallFrequency       AS clf ON clf.CallFrequencyID       = iss.CallFrequencyID
 LEFT JOIN  dbo.DisclosureType      AS dst ON dst.DisclosureTypeID      = iss.DisclosureTypeID
 LEFT JOIN  taxStatusValue          AS tsv ON tsv.DisplayValue          = iss.TaxStatus
