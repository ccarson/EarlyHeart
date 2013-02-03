CREATE PROCEDURE Conversion.processIssues
AS
/*
************************************************************************************************************************************

  Procedure:    Conversion.processIssues
     Author:    Chris Carson
    Purpose:    converts legacy Issues data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  SET CONTEXT_INFO prevents related converted tables from firing triggers caused by changes from proc
    2)  Create temp storage for changed data from source tables
    3)  SELECT initial control counts
    4)  INSERT changed Issues data into @changedIssueIDs
    5)  Exit procedure if there are no changes on edata.dbo.Issues
    6)  INSERT new issues data into #convertingIssues
    7)  INSERT updated issues data into #convertingIssues
    8)  Remove ObligorClientID data if the Client does not exist in legacy System
    9)  MERGE #convertingIssues with dbo.Issue
   10)  SELECT control counts and validate
   11)  Reset CONTEXT_INFO to re-enable triggering on converted tables
   12)  Print control totals


    Notes:

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;


    DECLARE @processName        AS VARCHAR (100)    = 'processIssues'
          , @errorMessage       AS VARCHAR (MAX)    = NULL
          , @errorQuery         AS VARCHAR (MAX)    = NULL
          , @processIssues      AS VARBINARY (128)  = CAST( 'processIssues' AS VARBINARY(128) )
          , @processStartTime   AS DATETIME         = GETDATE()
          , @processEndTime     AS DATETIME         = NULL
          , @processElapsedTime AS INT              = 0 ;

    DECLARE @changesCount       AS INT = 0
          , @convertedActual    AS INT = 0
          , @convertedCount     AS INT = 0
          , @legacyCount        AS INT = 0
          , @newCount           AS INT = 0
          , @recordINSERTs      AS INT = 0
          , @recordMERGEs       AS INT = 0
          , @recordUPDATEs      AS INT = 0
          , @updatedCount       AS INT = 0 ;


    DECLARE @changedIssueIDs    AS  TABLE ( IssueID             INT
                                          , legacyChecksum      VARBINARY (128)
                                          , convertedChecksum   VARBINARY (128) ) ;

    DECLARE @issueMergeResults  AS  TABLE ( Action    NVARCHAR (10)
                                          , IssueID   INT ) ;


--  1)  SET CONTEXT_INFO prevents related converted tables from firing triggers caused by changes from proc
BEGIN TRY
    SET CONTEXT_INFO @processIssues ;


--  2)  Create temp storage for changed data from source tables
    IF  OBJECT_ID('tempdb..#convertingIssues') IS NOT NULL
        DROP TABLE  #convertingIssues ;
    CREATE TABLE    #convertingIssues (
        IssueID             INT     NOT NULL PRIMARY KEY CLUSTERED
      , DatedDate           DATE
      , Amount              DECIMAL (15,2)
      , ClientID            INT
      , IssueName           VARCHAR (150)
      , ShortName           INT
      , IssueStatus         INT
      , cusip6              VARCHAR (6)
      , IssueType           INT
      , SaleType            INT
      , TaxStatus           VARCHAR(20)
      , AltMinimumTax       BIT
      , BondForm            INT
      , BankQualified       BIT
      , SecurityType        INT
      , SaleDate            DATE
      , SaleTime            TIME (7)
      , SettlementDate      DATE
      , FirstCouponDate     DATE
      , IntPmtFreq          INT
      , IntCalcMeth         INT
      , CouponType          INT
      , CallFrequency       INT
      , DisclosureType      INT
      , PurchasePrice       DECIMAL (15,2)
      , Notes               VARCHAR (MAX)
      , NotesRefundedBy     VARCHAR (MAX)
      , NotesRefunds        VARCHAR (MAX)
      , ArbitrageYield      DECIMAL (11,8)
      , QualityControlDate  DATETIME
      , Purpose             VARCHAR (MAX)
      , ChangeDate          DATETIME
      , ChangeBy            VARCHAR(20)
      , ObligorClientID     INT
      , EIPInvest           BIT ) ;


--  3)  SELECT initial control counts
    SELECT  @legacyCount        = COUNT(*) FROM Conversion.vw_LegacyIssues ;
    SELECT  @convertedCount     = COUNT(*) FROM Conversion.vw_ConvertedIssues ;
    SELECT  @convertedActual    = @convertedCount ;


--  4)  INSERT changed Issues data into @changedIssueIDs
    INSERT  @changedIssueIDs
    SELECT  IssueID           = a.IssueID
          , legacyChecksum    = a.IssueChecksum
          , convertedChecksum = b.IssueChecksum
      FROM  Conversion.tvf_IssueChecksum( 'Legacy' )    AS a
 LEFT JOIN  Conversion.tvf_IssueChecksum( 'Converted' ) AS b
        ON  a.IssueID = b.IssueID
     WHERE  b.IssueChecksum IS NULL OR a.IssueChecksum <> b.IssueChecksum ;
    SELECT  @changesCount = @@ROWCOUNT ;


--  5)  Exit procedure if there are no changes on edata.dbo.Issues
    IF  ( @changesCount = 0 )
        GOTO  endOfProc ;


--  6)  INSERT new issues data into #convertingIssues
    INSERT  #convertingIssues
    SELECT  IssueID, DatedDate, Amount, ClientID, IssueName, ShortName, IssueStatus, cusip6, IssueType, SaleType
                , TaxStatus, AltMinimumTax, BondForm, BankQualified, SecurityType, SaleDate, SaleTime
                , SettlementDate, FirstCouponDate, IntPmtFreq, IntCalcMeth, CouponType, CallFrequency
                , DisclosureType, PurchasePrice, Notes, NotesRefundedBy, NotesRefunds, ArbitrageYield
                , QualityControlDate, Purpose, ChangeDate, ChangeBy, ObligorClientID, EIPInvest
      FROM  Conversion.vw_LegacyIssues AS a
     WHERE  EXISTS ( SELECT 1 FROM @changedIssueIDs AS b
                      WHERE a.IssueID = b.IssueID AND b.convertedChecksum IS NULL ) ;
    SELECT  @newCount = @@ROWCOUNT ;


--  7)  INSERT updated issues data into #convertingIssues
    INSERT  #convertingIssues
    SELECT  IssueID, DatedDate, Amount, ClientID, IssueName, ShortName, IssueStatus, cusip6, IssueType, SaleType
                , TaxStatus, AltMinimumTax, BondForm, BankQualified, SecurityType, SaleDate, SaleTime
                , SettlementDate, FirstCouponDate, IntPmtFreq, IntCalcMeth, CouponType, CallFrequency
                , DisclosureType, PurchasePrice, Notes, NotesRefundedBy, NotesRefunds, ArbitrageYield
                , QualityControlDate, Purpose, ChangeDate, ChangeBy, ObligorClientID, EIPInvest
      FROM  Conversion.vw_LegacyIssues AS a
     WHERE  EXISTS ( SELECT 1 FROM @changedIssueIDs AS b
                      WHERE a.IssueID = b.IssueID AND b.legacyChecksum <> b.convertedChecksum ) ;
    SELECT  @updatedCount = @@ROWCOUNT ;


--  8)  Remove ObligorClientID data if the Client does not exist in legacy System
    UPDATE  #convertingIssues
       SET  ObligorClientID = NULL
      FROM  #convertingIssues AS a
     WHERE  NOT EXISTS ( SELECT 1 FROM edata.dbo.Clients AS b WHERE b.ClientID = a.ObligorClientID ) ;


--  9)  MERGE #convertingIssues with dbo.Issue
    SET IDENTITY_INSERT dbo.Issue ON ;

     MERGE  dbo.Issue           AS tgt
     USING  #convertingIssues   AS src ON tgt.IssueID = src.IssueID
      WHEN  MATCHED THEN
            UPDATE SET  DatedDate              = src.DatedDate
                      , IssueAmount            = src.Amount
                      , ClientID               = src.ClientID
                      , IssueName              = src.IssueName
                      , IssueShortNameID       = src.ShortName
                      , IssueStatusID          = src.IssueStatus
                      , Cusip6                 = src.cusip6
                      , IssueTypeID            = src.IssueType
                      , MethodOfSaleID         = src.SaleType
                      , TaxStatus              = src.TaxStatus
                      , AltMinimumTax          = src.AltMinimumTax
                      , BondFormTypeID         = src.BondForm
                      , BankQualified          = src.BankQualified
                      , SecurityTypeID         = src.SecurityType
                      , SaleDate               = src.SaleDate
                      , SaleTime               = src.SaleTime
                      , SettlementDate         = src.SettlementDate
                      , FirstInterestDate      = src.FirstCouponDate
                      , InterestPaymentFreqID  = src.IntPmtFreq
                      , InterestCalcMethodID   = src.IntCalcMeth
                      , InterestTypeID         = src.CouponType
                      , CallFrequencyID        = src.CallFrequency
                      , DisclosureTypeID       = src.DisclosureType
                      , PurchasePrice          = src.PurchasePrice
                      , Notes                  = src.Notes
                      , RefundedByNote         = src.NotesRefundedBy
                      , RefundsNote            = src.NotesRefunds
                      , ArbitrageYield         = src.ArbitrageYield
                      , QCDate                 = src.QualityControlDate
                      , LongDescription        = src.Purpose
                      , ObligorClientID        = src.ObligorClientID
                      , IsEIPInvest            = src.EIPInvest
                      , ModifiedDate           = src.ChangeDate
                      , ModifiedUser           = src.ChangeBy

      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( IssueID, DatedDate, IssueAmount, ClientID
                        , IssueName, IssueShortNameID, IssueStatusID, Cusip6
                        , IssueTypeID, MethodOfSaleID, TaxStatus, AltMinimumTax
                        , BondFormTypeID, BankQualified, SecurityTypeID, SaleDate
                        , SaleTime, SettlementDate, FirstInterestDate, InterestPaymentFreqID
                        , InterestCalcMethodID, InterestTypeID, CallFrequencyID, DisclosureTypeID
                        , PurchasePrice, Notes, RefundedByNote, RefundsNote
                        , ArbitrageYield, QCDate, LongDescription, ObligorClientID
                        , IsEIPInvest, ModifiedDate, ModifiedUser )
            VALUES ( src.IssueID, src.DatedDate, src.Amount, src.ClientID
                        , src.IssueName, src.ShortName, src.IssueStatus, src.cusip6
                        , src.IssueType, src.SaleType, src.TaxStatus, src.AltMinimumTax
                        , src.BondForm, src.BankQualified, src.SecurityType, src.SaleDate
                        , src.SaleTime, src.SettlementDate, src.FirstCouponDate, src.IntPmtFreq
                        , src.IntCalcMeth, src.CouponType, src.CallFrequency, src.DisclosureType
                        , src.PurchasePrice, src.Notes, src.NotesRefundedBy, src.NotesRefunds
                        , src.ArbitrageYield, src.QualityControlDate, src.Purpose, src.ObligorClientID
                        , src.EIPInvest, src.ChangeDate, src.ChangeBy )
    OUTPUT  $action, inserted.IssueID INTO @issueMergeResults ;
    SELECT  @recordMERGEs = @@ROWCOUNT ;

    SET IDENTITY_INSERT dbo.Issue OFF ;


-- 10)  SELECT control counts and validate
    SELECT  @recordINSERTs   = COUNT(*) FROM @issueMergeResults WHERE Action = 'INSERT' ;
    SELECT  @recordUPDATEs   = COUNT(*) FROM @issueMergeResults WHERE Action = 'UPDATE' ;
    SELECT  @convertedActual = COUNT(*) FROM Conversion.vw_ConvertedIssues ;

    IF  ( @convertedActual <> ( @convertedCount + @recordINSERTs ) )
        OR
        ( @convertedActual <> @legacyCount )
        OR
        ( @recordINSERTs <> @newCount )
        OR
        ( @recordUPDATEs <> @updatedCount )
        OR
        ( @recordMERGEs <> @changesCount )
        OR
        ( @changesCount <> ( @recordINSERTs + @recordUPDATEs ) )
    BEGIN
        PRINT 'Control Totals Error!  Please review counts and processing!' ;
        PRINT '' ;
        PRINT '@convertedActual = ' + STR( @convertedActual, 8 ) ;
        PRINT '@convertedCount  = ' + STR( @convertedCount, 8 ) ;
        PRINT '@recordINSERTs   = ' + STR( @recordINSERTs, 8 ) ;
        PRINT '' ;
        PRINT '@convertedActual = ' + STR( @convertedActual, 8 ) ;
        PRINT '@legacyCount     = ' + STR( @legacyCount, 8 ) ;
        PRINT '' ;
        PRINT '@recordINSERTs   = ' + STR( @recordINSERTs, 8 ) ;
        PRINT '@newCount        = ' + STR( @newCount, 8 ) ;
        PRINT '' ;
        PRINT '@recordUPDATEs   = ' + STR( @recordUPDATEs, 8 ) ;
        PRINT '@updatedCount    = ' + STR( @updatedCount, 8 ) ;
        PRINT '' ;
        PRINT '@recordMERGEs    = ' + STR( @recordMERGEs, 8 ) ;
        PRINT '@changesCount    = ' + STR( @changesCount, 8 ) ;
        PRINT '' ;
        PRINT '@changesCount    = ' + STR( @changesCount, 8 ) ;
        PRINT '@recordINSERTs   = ' + STR( @recordINSERTs, 8 ) ;
        PRINT '@recordUPDATEs   = ' + STR( @recordUPDATEs, 8 ) ;
    END


END TRY
BEGIN CATCH
    EXECUTE dbo.processEhlersError ;
END CATCH


endOfProc:

-- 11)  Reset CONTEXT_INFO to re-enable triggering on converted tables
    SET CONTEXT_INFO 0x0 ;


-- 12)  Print control totals
    SELECT  @processEndTime     = GETDATE()
          , @processElapsedTime = DATEDIFF( ms, @processStartTime, @processEndTime ) ;

    PRINT   'Conversion.processIssues CONTROL TOTALS ' ;
    PRINT   'Issues on legacy system                 = ' + STR( @legacyCount, 8 ) ;
    PRINT   '' ;
    PRINT   'Existing Issues on converted system     = ' + STR( @convertedCount, 8 ) ;
    PRINT   '     + new records                      = ' + STR( @newCount, 8 ) ;
    PRINT   '                                           ======= ' ;
    PRINT   'Total Issuse on converted system        = ' + STR( @convertedActual, 8 ) ;
    PRINT   'Changed records already counted         = ' + STR( @updatedCount, 8 ) ;
    PRINT   '' ;
    PRINT   '' ;
    PRINT   'Database Change Details ' ;
    PRINT   '' ;
    PRINT   '     Total INSERTs dbo.Issue            = ' + STR( @recordINSERTs, 8 ) ;
    PRINT   '     Total UPDATEs dbo.Issue            = ' + STR( @recordUPDATEs, 8 ) ;
    PRINT   '' ;
    PRINT   '     TOTAL changes on dbo.Issue         = ' + STR( @recordMERGEs, 8 ) ;
    PRINT   '' ;
    PRINT   'processIssues START : ' + CONVERT( VARCHAR (30), @processStartTime, 121 ) ;
    PRINT   'processIssues   END : ' + CONVERT( VARCHAR (30), @processEndTime, 121 ) ;
    PRINT   '       Elapsed Time : ' + CAST ( @processElapsedTime AS VARCHAR (20) ) + 'ms' ;


END
GO

