CREATE VIEW Conversion.vw_LegacyIssues
/*
************************************************************************************************************************************

       View:    Conversion.vw_LegacyIssues
     Author:    Chris Carson
    Purpose:    shows "scrubbed" version of edata.Issues


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         ###DATE###          created -- Issues Conversion

    Notes:

************************************************************************************************************************************
*/
AS
      WITH  bondFormType AS (
            SELECT  BondFormTypeID, LegacyValue = x.Item
              FROM  dbo.BondFormType
       CROSS APPLY  dbo.tvf_CSVSplit( LegacyValue, ',') AS x ) ,

            taxStatusValue AS (
            SELECT  OldListValue
                  , DisplayValue
              FROM  dbo.StaticList
             WHERE  ListCategoryID = 279 )

    SELECT  IssueID                 =  iss.IssueID
          , DatedDate               =  iss.DatedDate
          , Amount                  =  ISNULL( iss.Amount, 0.00 )
          , ClientID                =  iss.ClientID
          , IssueName               =  ISNULL( iss.IssueName,'' )
          , ShortName               =  shn.IssueShortNameID
          , IssueStatus             =  sta.IssueStatusID
          , cusip6                  =  CAST( iss.cusip6 AS VARCHAR(6) )
          , IssueType               =  ist.IssueTypeID
          , SaleType                =  mos.MethodOfSaleID
          , TaxStatus               =  ISNULL( tsv.DisplayValue, '' )
          , BondForm                =  bft.BondFormTypeID
          , BankQualified           =  CASE iss.BankQualified WHEN 'Y' THEN 1 ELSE 0 END
          , SecurityType            =  sct.SecurityTypeID
          , SaleDate                =  iss.SaleDate
          , SaleTime                =  iss.SaleTime
          , SettlementDate          =  iss.SettlementDate
          , FirstCouponDate         =  iss.FirstCouponDate
          , IntPmtFreq              =  ipf.InterestPaymentFreqID
          , IntCalcMeth             =  icm.InterestCalcMethodID
          , CouponType              =  itt.InterestTypeID
          , Callable                =  CASE clf.CallFrequencyID WHEN 8 THEN 0 ELSE 1 END
          , CallFrequency           =  clf.CallFrequencyID
          , DisclosureType          =  dst.DisclosureTypeID
          , PurchasePrice           =  ISNULL( iss.PurchasePrice, 0.00 )
          , Notes                   =  CAST( ISNULL( iss.Notes, '' ) AS VARCHAR(MAX) )
          , NotesRefundedBy         =  CAST( ISNULL( iss.NotesRefundedBy, '' ) AS VARCHAR(MAX) )
          , NotesRefunds            =  CAST( ISNULL( iss.NotesRefunds, '' ) AS VARCHAR(MAX) )
          , ArbitrageYield          =  ISNULL( iss.ArbitrageYield, 0.00 )
          , QualityControlDate      =  iss.QualityControlDate
          , Purpose                 =  CAST( ISNULL( iss.Purpose, '' ) AS VARCHAR(MAX) )
          , ChangeDate              =  ISNULL( iss.ChangeDate, GETDATE() )
          , ChangeBy                =  ISNULL( NULLIF( iss.ChangeBy, '' ), 'processIssues' )
          , ObligorClientID         =  obc.ClientID
          , EIPInvest               =  ISNULL( iss.EIPInvest, 0 )
      FROM  edata.Issues            AS iss
 LEFT JOIN  edata.Clients           AS obc ON obc.ClientID     = iss.ObligorClientID
 LEFT JOIN  dbo.IssueShortName      AS shn ON shn.LegacyValue  = iss.ShortName
 LEFT JOIN  dbo.IssueStatus         AS sta ON sta.LegacyValue  = iss.IssueStatus
 LEFT JOIN  dbo.IssueType           AS ist ON ist.LegacyValue  = iss.IssueType
 LEFT JOIN  dbo.MethodOfSale        AS mos ON mos.LegacyValue  = iss.SaleType
 LEFT JOIN  dbo.SecurityType        AS sct ON sct.LegacyValue  = iss.SecurityType
 LEFT JOIN  dbo.InterestPaymentFreq AS ipf ON ipf.LegacyValue  = iss.IntPmtFreq
 LEFT JOIN  dbo.InterestCalcMethod  AS icm ON icm.LegacyValue  = iss.IntCalcMeth
 LEFT JOIN  dbo.InterestType        AS itt ON itt.LegacyValue  = iss.CouponType
 LEFT JOIN  dbo.CallFrequency       AS clf ON clf.LegacyValue  = iss.CallFrequency
 LEFT JOIN  dbo.DisclosureType      AS dst ON dst.LegacyValue  = iss.DisclosureType
 LEFT JOIN  bondFormType            AS bft ON bft.LegacyValue  = iss.BondForm
 LEFT JOIN  taxStatusValue          AS tsv ON tsv.OldListValue = iss.TaxStatus 
     WHERE  iss.ClientID IN ( SELECT ClientID FROM edata.Clients ) ; 
;
