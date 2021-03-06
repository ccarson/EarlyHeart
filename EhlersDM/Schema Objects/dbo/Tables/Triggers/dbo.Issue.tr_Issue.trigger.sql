﻿CREATE TRIGGER  tr_Issue
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

    Logic Summary:
    1)  UPDATE dbo.Issue.GoodFaithAmount to 20% of the IssueAmount unless after SaleDate
    2)  Stop processing when trigger is invoked by Conversion.processIssues procedure
    3)  Stop processing unless Issue data has actually changed
    4)  Update edata.dbo.Issues with relevant data from dbo.Issue

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON ;

    DECLARE @processIssues      AS VARBINARY(128) = CAST( 'processIssues' AS VARBINARY(128) )
          , @legacyChecksum     AS INT = 0
          , @convertedChecksum  AS INT = 0 ;

BEGIN TRY
--  1)  UPDATE dbo.Issue.GoodFaithAmount to 20% of the IssueAmount unless after SaleDate
    UPDATE  dbo.Issue
       SET  GoodFaithAmt = dbo.udf_GetGoodFaithAmount( IssueAmount )
      FROM  dbo.Issue AS a
     WHERE  EXISTS ( SELECT 1 FROM inserted AS b
                      WHERE a.IssueID = b.IssueID AND DATEDIFF( dd, GETDATE(), SaleDate ) > 0 ) ;

--  2)  Stop processing when trigger is invoked by Conversion.processIssues procedure
    IF  CONTEXT_INFO() = @processIssues
        RETURN ;

--  3)  Stop processing unless Issue data has actually changed ( Some data on dbo.Issue does not write back to edata.dbo.Issues )
    SELECT  @legacyChecksum = CHECKSUM_AGG( CHECKSUM(*) ) FROM Conversion.tvf_IssueChecksum( 'Legacy' ) AS a
     WHERE  EXISTS ( SELECT 1 FROM inserted AS b WHERE a.IssueID = b.IssueID ) ;

    SELECT  @convertedChecksum = CHECKSUM_AGG( CHECKSUM(*) ) FROM Conversion.tvf_IssueChecksum( 'Converted' ) AS a
     WHERE  EXISTS ( SELECT 1 FROM inserted AS b WHERE a.IssueID = b.IssueID ) ;

    IF  ( @legacyChecksum = @convertedChecksum )
        RETURN ;

--  4)  Update edata.dbo.Issues with relevant data from dbo.Issue
      WITH  changedIssues AS (
            SELECT  IssueID, DatedDate, Amount, ClientID
                        , IssueName, ShortName, IssueStatus, cusip6
                        , IssueType, SaleType, TaxStatus, BondForm
                        , BankQualified, SecurityType, SaleDate, SaleTime
                        , SettlementDate, FirstCouponDate, IntPmtFreq
                        , IntCalcMeth, CouponType, CallFrequency, DisclosureType
                        , PurchasePrice, Notes, NotesRefundedBy, NotesRefunds
                        , ArbitrageYield, QualityControlDate, Purpose, ChangeDate
                        , ChangeBy, ObligorClientID, EIPInvest
              FROM  Conversion.vw_ConvertedIssues
             WHERE  IssueID IN ( SELECT IssueID FROM inserted ) )
     MERGE  edata.dbo.Issues AS tgt
     USING  changedIssues    AS src
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
      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( IssueID, DatedDate, Amount, ClientID
                        , IssueName, ShortName, IssueStatus, cusip6
                        , IssueType, SaleType, TaxStatus, BondForm
                        , BankQualified, SecurityType, SaleDate, SaleTime
                        , SettlementDate, FirstCouponDate, IntPmtFreq
                        , IntCalcMeth, CouponType, CallFrequency, DisclosureType
                        , PurchasePrice, Notes, NotesRefundedBy, NotesRefunds
                        , ArbitrageYield, QualityControlDate, Purpose, ChangeDate
                        , ChangeBy, ObligorClientID, EIPInvest )
            VALUES ( src.IssueID, src.DatedDate, src.Amount, src.ClientID
                        , src.IssueName, src.ShortName, src.IssueStatus, src.cusip6
                        , src.IssueType, src.SaleType, src.TaxStatus, src.BondForm
                        , src.BankQualified, src.SecurityType, src.SaleDate, src.SaleTime
                        , src.SettlementDate, src.FirstCouponDate, src.IntPmtFreq
                        , src.IntCalcMeth, src.CouponType, src.CallFrequency, src.DisclosureType
                        , src.PurchasePrice, src.Notes, src.NotesRefundedBy, src.NotesRefunds
                        , src.ArbitrageYield, src.QualityControlDate, src.Purpose, src.ChangeDate
                        , src.ChangeBy, src.ObligorClientID, src.EIPInvest ) ;

END TRY
BEGIN CATCH
    ROLLBACK ;
    EXECUTE dbo.processEhlersError ;
END CATCH

END
