CREATE TRIGGER  tr_Issue
            ON  dbo.Issue
AFTER INSERT, UPDATE
AS
/*
************************************************************************************************************************************

    Trigger:    tr_Issue
     Author:    Chris Carson
    Purpose:    Synchronizes Issues data back to legacy systems

    revisor         date                description
    ---------       ----------          ----------------------------
    ccarson         2013-01-24          created
    ccarson         ###DATE###          Issues Conversion changes


    Logic Summary:
    1)  UPDATE dbo.Issue.GoodFaithPercent to 2% of the IssueAmount on Issue Creation
    2)  INSERT IssueFeeCounty for each CountyClient record that exists
    3)  Stop processing when trigger is invoked by Conversion.processIssues procedure
    4)  Stop processing unless Issue data has actually changed
    5)  Update edata.dbo.Issues with relevant data from dbo.Issue

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @fromConversion AS VARBINARY (128) = CAST( 'fromConversion' AS VARBINARY (128) ) ;
          , @legacyChecksum     AS INT = 0
          , @convertedChecksum  AS INT = 0 ;

BEGIN TRY
--  1)  UPDATE dbo.Issue.GoodFaithPercent to 2% of the IssueAmount when new
    UPDATE  dbo.Issue
       SET  GoodFaithPercent = 2.0
      FROM  dbo.Issue AS a
     WHERE  EXISTS ( SELECT 1 FROM inserted AS b
                      WHERE a.IssueID = b.IssueID AND DATEDIFF( dd, GETDATE(), b.SaleDate ) > 0 AND b.MethodOfSaleID = 1 )
       AND  NOT EXISTS ( SELECT 1 FROM deleted ) ;


--  2)  INSERT IssueFeeCounty for each CountyClient record that exists
      WITH  clientCounties AS (
            SELECT  IssueID         = ins.IssueID
                  , CountyClientID  = cov.OverlapClientID
                  , Ordinal         = cov.Ordinal
                  , ModifiedDate    = ins.ModifiedDate
                  , ModifiedUser    = ins.ModifiedUser
              FROM  dbo.ClientOverlap AS cov
        INNER JOIN  dbo.OverlapType   AS ovt ON ovt.OverlapTypeID = cov.OverlapTypeID AND ovt.Value = 'Counties'
        INNER JOIN  inserted          AS ins ON ins.ClientID = cov.ClientID
             WHERE  NOT EXISTS ( SELECT 1 FROM deleted AS del WHERE del.IssueID = ins.IssueID ) )

    INSERT  dbo.IssueFeeCounty (
            IssueID, CountyClientID, Ordinal, ModifiedDate, ModifiedUser )
    SELECT  IssueID, CountyClientID, Ordinal, ModifiedDate, ModifiedUser
      FROM  clientCounties
     ORDER  BY Ordinal ;


--  3)  Stop processing when trigger is invoked by Conversion.processIssues procedure
    IF  CONTEXT_INFO() = @fromConversion
        RETURN ;

--  4)  Stop processing unless Issue data has actually changed ( Some data on dbo.Issue does not write back to edata.dbo.Issues )
    SELECT  @legacyChecksum = CHECKSUM_AGG( CHECKSUM(*) ) FROM Conversion.tvf_IssueChecksum( 'Legacy' ) AS a
     WHERE  EXISTS ( SELECT 1 FROM inserted AS b WHERE a.IssueID = b.IssueID ) ;

    SELECT  @convertedChecksum = CHECKSUM_AGG( CHECKSUM(*) ) FROM Conversion.tvf_IssueChecksum( 'Converted' ) AS a
     WHERE  EXISTS ( SELECT 1 FROM inserted AS b WHERE a.IssueID = b.IssueID ) ;

    IF  ( @legacyChecksum = @convertedChecksum )
        RETURN ;

--  5)  Update edata.dbo.Issues with relevant data from dbo.Issue
      WITH  changedIssues AS (
            SELECT  IssueID, DatedDate, Amount, i.ClientID
                        , IssueName, ShortName, IssueStatus, cusip6
                        , IssueType, SaleType, TaxStatus, BondForm
                        , BankQualified, SecurityType, SaleDate, SaleTime
                        , SettlementDate, FirstCouponDate, IntPmtFreq
                        , IntCalcMeth, CouponType, CallFrequency, DisclosureType
                        , PurchasePrice, i.Notes, NotesRefundedBy, NotesRefunds
                        , ArbitrageYield, QualityControlDate, Purpose, i.ChangeDate
                        , i.ChangeBy, ObligorClientID, EIPInvest, c.ClientDescriptiveName
              FROM  Conversion.vw_ConvertedIssues AS i 
        INNER JOIN  Conversion.vw_ConvertedClients AS c ON c.ClientID = i.ClientID
             WHERE  IssueID IN ( SELECT IssueID FROM inserted ) )
     MERGE  edata.Issues    AS tgt
     USING  changedIssues   AS src
        ON  tgt.IssueID = src.IssueID
      WHEN  MATCHED THEN
            UPDATE
               SET  DatedDate           =  src.DatedDate
                  , Amount              =  src.Amount
                  , ClientID            =  src.ClientID
                  , IssueName           =  src.IssueName
                  , ShortName           =  src.ShortName
                  , IssueStatus         =  src.IssueStatus
                  , cusip6              =  src.cusip6
                  , IssueType           =  src.IssueType
                  , SaleType            =  src.SaleType
                  , TaxStatus           =  src.TaxStatus
                  , BondForm            =  src.BondForm
                  , BankQualified       =  src.BankQualified
                  , SecurityType        =  src.SecurityType
                  , SaleDate            =  src.SaleDate
                  , SaleTime            =  src.SaleTime
                  , SettlementDate      =  src.SettlementDate
                  , FirstCouponDate     =  src.FirstCouponDate
                  , IntPmtFreq          =  src.IntPmtFreq
                  , IntCalcMeth         =  src.IntCalcMeth
                  , CouponType          =  src.CouponType
                  , CallFrequency       =  src.CallFrequency
                  , DisclosureType      =  src.DisclosureType
                  , PurchasePrice       =  src.PurchasePrice
                  , Notes               =  src.Notes
                  , NotesRefundedBy     =  src.NotesRefundedBy
                  , NotesRefunds        =  src.NotesRefunds
                  , ArbitrageYield      =  src.ArbitrageYield
                  , QualityControlDate  =  src.QualityControlDate
                  , Purpose             =  src.Purpose
                  , ChangeDate          =  src.ChangeDate
                  , ChangeBy            =  src.ChangeBy
                  , ObligorClientID     =  src.ObligorClientID
                  , EIPInvest           =  src.EIPInvest
                  , issuername          =  src.ClientDescriptiveName
      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( IssueID, DatedDate, Amount, ClientID
                        , IssueName, ShortName, IssueStatus, cusip6
                        , IssueType, SaleType, TaxStatus, BondForm
                        , BankQualified, SecurityType, SaleDate, SaleTime
                        , SettlementDate, FirstCouponDate, IntPmtFreq
                        , IntCalcMeth, CouponType, CallFrequency, DisclosureType
                        , PurchasePrice, Notes, NotesRefundedBy, NotesRefunds
                        , ArbitrageYield, QualityControlDate, Purpose, ChangeDate
                        , ChangeBy, ObligorClientID, EIPInvest, issuername )
            VALUES ( src.IssueID, src.DatedDate, src.Amount, src.ClientID
                        , src.IssueName, src.ShortName, src.IssueStatus, src.cusip6
                        , src.IssueType, src.SaleType, src.TaxStatus, src.BondForm
                        , src.BankQualified, src.SecurityType, src.SaleDate, src.SaleTime
                        , src.SettlementDate, src.FirstCouponDate, src.IntPmtFreq
                        , src.IntCalcMeth, src.CouponType, src.CallFrequency, src.DisclosureType
                        , src.PurchasePrice, src.Notes, src.NotesRefundedBy, src.NotesRefunds
                        , src.ArbitrageYield, src.QualityControlDate, src.Purpose, src.ChangeDate
                        , src.ChangeBy, src.ObligorClientID, src.EIPInvest, src.ClientDescriptiveName ) ;

END TRY
BEGIN CATCH
    ROLLBACK ;
    EXECUTE dbo.processEhlersError ;
END CATCH

END
