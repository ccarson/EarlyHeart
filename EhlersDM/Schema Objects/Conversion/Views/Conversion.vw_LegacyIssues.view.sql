CREATE VIEW Conversion.vw_LegacyIssues
/*
************************************************************************************************************************************

       View:    Conversion.vw_LegacyIssues
     Author:    Chris Carson
    Purpose:    shows "scrubbed" version of edata.Issues


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Notes:

************************************************************************************************************************************
*/
AS
    SELECT  IssueID                 =  i.IssueID
          , DatedDate               =  i.DatedDate
          , Amount                  =  ISNULL( i.Amount, 0.00 )
          , ClientID                =  i.ClientID
          , IssueName               =  ISNULL( i.IssueName,'' )
          , ShortName               =  shn.IssueShortNameID
          , IssueStatus             =  sta.IssueStatusID
          , cusip6                  =  CAST( i.cusip6 AS VARCHAR(6) )
          , IssueType               =  ist.IssueTypeID
          , SaleType                =  mos.MethodOfSaleID
          , TaxStatus               =  ISNULL( i.TaxStatus,'' )
          , AltMinimumTax           =  CASE i.TaxStatus WHEN 'A' THEN 1 ELSE 0 END
          , BondForm                =  bft.BondFormTypeID
          , BankQualified           =  CASE i.BankQualified WHEN 'Y' THEN 1 ELSE 0 END
          , SecurityType            =  sct.SecurityTypeID
          , SaleDate                =  i.SaleDate
          , SaleTime                =  i.SaleTime
          , SettlementDate          =  i.SettlementDate
          , FirstCouponDate         =  i.FirstCouponDate
          , IntPmtFreq              =  ipf.InterestPaymentFreqID
          , IntCalcMeth             =  icm.InterestCalcMethodID
          , CouponType              =  itt.InterestTypeID
          , CallFrequency           =  clf.CallFrequencyID
          , DisclosureType          =  dst.DisclosureTypeID
    --    , FinanceType             =  FinanceType
    --    , UseProceeds             =  UseProceeds
          , PurchasePrice           =  ISNULL( i.PurchasePrice, 0.00 )
          , Notes                   =  CAST( ISNULL( i.Notes, '' ) AS VARCHAR(MAX) ) 
          , NotesRefundedBy         =  CAST( ISNULL( i.NotesRefundedBy, '' ) AS VARCHAR(MAX) )
          , NotesRefunds            =  CAST( ISNULL( i.NotesRefunds, '' ) AS VARCHAR(MAX) )
          , ArbitrageYield          =  ISNULL( i.ArbitrageYield, 0.00 )
          , QualityControlDate      =  i.QualityControlDate
          , Purpose                 =  CAST( ISNULL( i.Purpose, '' ) AS VARCHAR(MAX) )
          , ChangeDate              =  ISNULL( i.ChangeDate, GETDATE() )
          , ChangeBy                =  ISNULL( NULLIF( i.ChangeBy, '' ), 'processIssues' )
          , ObligorClientID         =  oc.ClientID
          , EIPInvest               =  ISNULL( i.EIPInvest, 0 )
      FROM  edata.Issues        AS i
INNER JOIN  edata.Clients       AS c   ON c.ClientID      = i.ClientID
 LEFT JOIN  edata.Clients       AS oc  ON oc.ClientID     = i.ObligorClientID
 LEFT JOIN  dbo.IssueShortName      AS shn ON shn.LegacyValue = i.ShortName
 LEFT JOIN  dbo.IssueStatus         AS sta ON sta.LegacyValue = i.IssueStatus
 LEFT JOIN  dbo.IssueType           AS ist ON ist.LegacyValue = i.IssueType
 LEFT JOIN  dbo.MethodOfSale        AS mos ON mos.LegacyValue = i.SaleType
 LEFT JOIN  dbo.BondFormType        AS bft ON bft.LegacyValue = i.BondForm
 LEFT JOIN  dbo.SecurityType        AS sct ON sct.LegacyValue = i.SecurityType
 LEFT JOIN  dbo.InterestPaymentFreq AS ipf ON ipf.LegacyValue = i.IntPmtFreq
 LEFT JOIN  dbo.InterestCalcMethod  AS icm ON icm.LegacyValue = i.IntCalcMeth
 LEFT JOIN  dbo.InterestType        AS itt ON itt.LegacyValue = i.CouponType
 LEFT JOIN  dbo.CallFrequency       AS clf ON clf.LegacyValue = i.CallFrequency
 LEFT JOIN  dbo.DisclosureType      AS dst ON dst.LegacyValue = i.DisclosureType ;
