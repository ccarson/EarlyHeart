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
          , SaleType                =  mos.LegacyValue
          , TaxStatus               =  tsv.OldListValue
          , AltMinimumTax           =  iss.AltMinimumTax
          , BondForm                =  bft.LegacyValue
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
          , EIPInvest               =  iss.isEIPInvest
      FROM  dbo.Issue               AS iss
 LEFT JOIN  dbo.IssueShortName      AS shn ON shn.IssueShortNameID      = i.IssueShortNameID
 LEFT JOIN  dbo.IssueStatus         AS sta ON sta.IssueStatusID         = i.IssueStatusID
 LEFT JOIN  dbo.IssueType           AS ist ON ist.IssueTypeID           = i.IssueTypeID
 LEFT JOIN  dbo.MethodOfSale        AS mos ON mos.MethodOfSaleID        = i.MethodOfSaleID
 LEFT JOIN  dbo.BondFormType        AS bft ON bft.BondFormTypeID        = i.BondFormTypeID
 LEFT JOIN  dbo.SecurityType        AS sct ON sct.SecurityTypeID        = i.SecurityTypeID
 LEFT JOIN  dbo.InterestPaymentFreq AS ipf ON ipf.InterestPaymentFreqID = i.InterestPaymentFreqID
 LEFT JOIN  dbo.InterestCalcMethod  AS icm ON icm.InterestCalcMethodID  = i.InterestCalcMethodID
 LEFT JOIN  dbo.InterestType        AS itt ON itt.InterestTypeID        = i.InterestTypeID
 LEFT JOIN  dbo.CallFrequency       AS clf ON clf.CallFrequencyID       = i.CallFrequencyID
 LEFT JOIN  dbo.DisclosureType      AS dst ON dst.DisclosureTypeID      = i.DisclosureTypeID
 LEFT JOIN  taxStatusValue          AS tsv ON tsv.DisplayValue          = i.TaxStatus ;
