CREATE VIEW Conversion.vw_ConvertedIssues
/*
************************************************************************************************************************************

       View:    Conversion.vw_ConvertedIssues
     Author:    Chris Carson
    Purpose:    shows legacy view of converted dbo.Issue table


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Notes:

************************************************************************************************************************************
*/
AS
    SELECT  IssueID                 =  i.IssueID
          , DatedDate               =  i.DatedDate
          , Amount                  =  i.IssueAmount
          , ClientID                =  i.ClientID
          , IssueName               =  i.IssueName
          , ShortName               =  shn.LegacyValue
          , IssueStatus             =  sta.LegacyValue
          , cusip6                  =  i.Cusip6
          , IssueType               =  ist.LegacyValue
          , SaleType                =  mos.LegacyValue
          , TaxStatus               =  i.TaxStatus
          , AltMinimumTax           =  i.AltMinimumTax
          , BondForm                =  bft.LegacyValue
          , BankQualified           =  CASE i.BankQualified WHEN 1 THEN 'Y' ELSE 'N' END
          , SecurityType            =  sct.LegacyValue
          , SaleDate                =  i.SaleDate
          , SaleTime                =  i.SaleTime
          , SettlementDate          =  i.SettlementDate
          , FirstCouponDate         =  i.FirstInterestDate
          , IntPmtFreq              =  ipf.LegacyValue
          , IntCalcMeth             =  icm.LegacyValue
          , CouponType              =  itt.LegacyValue
          , CallFrequency           =  clf.LegacyValue
          , DisclosureType          =  dst.LegacyValue
    --    , FinanceType             =  FinanceType
    --    , UseProceeds             =  UseProceeds
          , PurchasePrice           =  i.PurchasePrice
          , Notes                   =  i.Notes
          , NotesRefundedBy         =  i.RefundedByNote
          , NotesRefunds            =  i.RefundsNote
          , ArbitrageYield          =  i.ArbitrageYield
          , QualityControlDate      =  i.QCDate
          , Purpose                 =  i.LongDescription
          , ChangeDate              =  i.ModifiedDate
          , ChangeBy                =  i.ModifiedUser
          , ObligorClientID         =  i.ObligorClientID
          , EIPInvest               =  i.isEIPInvest
      FROM  dbo.Issue               AS i
 LEFT JOIN  dbo.IssueShortName      AS shn ON shn.IssueShortNameID      = i.IssueShortNameID
 LEFT JOIN  dbo.IssueStatus         AS sta on sta.IssueStatusID         = i.IssueStatusID
 LEFT JOIN  dbo.IssueType           AS ist on ist.IssueTypeID           = i.IssueTypeID
 LEFT JOIN  dbo.MethodOfSale        AS mos on mos.MethodOfSaleID        = i.MethodOfSaleID
 LEFT JOIN  dbo.BondFormType        AS bft on bft.BondFormTypeID        = i.BondFormTypeID
 LEFT JOIN  dbo.SecurityType        AS sct on sct.SecurityTypeID        = i.SecurityTypeID
 LEFT JOIN  dbo.InterestPaymentFreq AS ipf on ipf.InterestPaymentFreqID = i.InterestPaymentFreqID
 LEFT JOIN  dbo.InterestCalcMethod  AS icm on icm.InterestCalcMethodID  = i.InterestCalcMethodID
 LEFT JOIN  dbo.InterestType        AS itt on itt.InterestTypeID        = i.InterestTypeID
 LEFT JOIN  dbo.CallFrequency       AS clf on clf.CallFrequencyID       = i.CallFrequencyID
 LEFT JOIN  dbo.DisclosureType      AS dst on dst.DisclosureTypeID      = i.DisclosureTypeID ;
