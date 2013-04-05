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
    5)  Exit procedure if there are no changes on edata.Issues
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
BEGIN TRY
    SET NOCOUNT ON ;


    DECLARE @fromConversion AS VARBINARY (128) = CAST( 'fromConversion' AS VARBINARY (128) ) ;
          , @processStartTime       AS VARCHAR (30)     = CONVERT( VARCHAR(30), GETDATE(), 121 )
          , @processEndTime         AS VARCHAR (30)     = NULL
          , @processElapsedTime     AS INT              = 0 ;


    DECLARE @codeBlockDesc01        AS SYSNAME    = 'SET CONTEXT_INFO, to inhibit triggers that would ordinarily fire'
          , @codeBlockDesc02        AS SYSNAME    = 'SELECT initial control counts'
          , @codeBlockDesc03        AS SYSNAME    = 'INSERT changed recordIDs into temp storage'
          , @codeBlockDesc04        AS SYSNAME    = 'Stop processing if there are no data changes'
          , @codeBlockDesc05        AS SYSNAME    = 'INSERT new data into temp storage'
          , @codeBlockDesc06        AS SYSNAME    = 'INSERT updated data into temp storage'
          , @codeBlockDesc07        AS SYSNAME    = 'UPDATE changed data to remove invalid ObligorClientID'
          , @codeBlockDesc08        AS SYSNAME    = 'MERGE temp storage into dbo.Issues'
          , @codeBlockDesc09        AS SYSNAME    = 'SELECT final control counts'
          , @codeBlockDesc10        AS SYSNAME    = 'Control Total Validation'
          , @codeBlockDesc11        AS SYSNAME    = 'Reset CONTEXT_INFO to remove restrictions on triggers'
          , @codeBlockDesc12        AS SYSNAME    = 'Print control totals' ;


    DECLARE @codeBlockNum           AS INT
          , @codeBlockDesc          AS SYSNAME
          , @errorTypeID            AS INT
          , @errorSeverity          AS INT
          , @errorState             AS INT
          , @errorNumber            AS INT
          , @errorLine              AS INT
          , @errorProcedure         AS SYSNAME
          , @errorMessage           AS VARCHAR (MAX) = NULL
          , @errorData              AS VARCHAR (MAX) = NULL ;


    DECLARE @changesCount       AS INT = 0
          , @convertedActual    AS INT = 0
          , @convertedCount     AS INT = 0
          , @legacyCount        AS INT = 0
          , @newCount           AS INT = 0
          , @recordINSERTs      AS INT = 0
          , @recordMERGEs       AS INT = 0
          , @recordUPDATEs      AS INT = 0
          , @total              AS INT = 0
          
          , @updatedCount       AS INT = 0 ;


    DECLARE @controlTotalsError     AS VARCHAR (200)    = N'Control Total Failure:  %s = %d, %s = %d' ;



    DECLARE @changedIssueIDs    AS  TABLE ( IssueID             INT
                                          , legacyChecksum      VARBINARY (128)
                                          , convertedChecksum   VARBINARY (128) ) ;

    DECLARE @issueMergeResults  AS  TABLE ( Action    NVARCHAR (10)
                                          , IssueID   INT ) ;

    DECLARE @changedIssueData   AS  TABLE ( IssueID                     INT     NOT NULL PRIMARY KEY CLUSTERED
                                          , DatedDate                   DATE
                                          , Amount                      DECIMAL (15,2)
                                          , ClientID                    INT
                                          , IssueName                   VARCHAR (150)
                                          , ShortName                   INT
                                          , IssueStatus                 INT
                                          , cusip6                      VARCHAR (6)
                                          , IssueType                   INT
                                          , SaleType                    INT
                                          , InitialOfferingDocument     INT
                                          , TaxStatus                   VARCHAR(20)
                                          , BondForm                    INT
                                          , BankQualified               BIT
                                          , SecurityType                INT
                                          , SaleDate                    DATE
                                          , SaleTime                    TIME (7)
                                          , SettlementDate              DATE
                                          , FirstCouponDate             DATE
                                          , IntPmtFreq                  INT
                                          , IntCalcMeth                 INT
                                          , CouponType                  INT
                                          , Callable                    BIT
                                          , CallFrequency               INT
                                          , DisclosureType              INT
                                          , PurchasePrice               DECIMAL (15,2)
                                          , Notes                       VARCHAR (MAX)
                                          , NotesRefundedBy             VARCHAR (MAX)
                                          , NotesRefunds                VARCHAR (MAX)
                                          , ArbitrageYield              DECIMAL (11,8)
                                          , QualityControlDate          DATETIME
                                          , Purpose                     VARCHAR (MAX)
                                          , ChangeDate                  DATETIME
                                          , ChangeBy                    VARCHAR(20)
                                          , ObligorClientID             INT
                                          , EIPInvest                   BIT ) ;



/**/SELECT  @codeBlockNum   = 1
/**/      , @codeBlockDesc  = @codeBlockDesc01 ; -- SET CONTEXT_INFO, to inhibit triggers that would ordinarily fire

    SET CONTEXT_INFO @processIssues ;


/**/SELECT  @codeBlockNum   = 2
/**/      , @codeBlockDesc  = @codeBlockDesc02 ; -- SELECT initial control counts

    SELECT  @legacyCount        = COUNT(*) FROM Conversion.vw_LegacyIssues ;
    SELECT  @convertedCount     = COUNT(*) FROM Conversion.vw_ConvertedIssues ;
    SELECT  @convertedActual    = @convertedCount ;


/**/SELECT  @codeBlockNum   = 3
/**/      , @codeBlockDesc  = @codeBlockDesc03 ; -- INSERT changed recordIDs into temp storage

    INSERT  @changedIssueIDs
    SELECT  IssueID           = a.IssueID
          , legacyChecksum    = a.IssueChecksum
          , convertedChecksum = b.IssueChecksum
      FROM  Conversion.tvf_IssueChecksum( 'Legacy' )    AS a
 LEFT JOIN  Conversion.tvf_IssueChecksum( 'Converted' ) AS b
        ON  a.IssueID = b.IssueID
     WHERE  b.IssueChecksum IS NULL OR a.IssueChecksum <> b.IssueChecksum ;
    SELECT  @changesCount = @@ROWCOUNT ;


/**/SELECT  @codeBlockNum   = 4
/**/      , @codeBlockDesc  = @codeBlockDesc04 ; -- Stop processing if there are no data changes

    IF  ( @changesCount = 0 )
        GOTO  endOfProc ;


/**/SELECT  @codeBlockNum   = 5
/**/      , @codeBlockDesc  = @codeBlockDesc05 ; -- INSERT new data into temp storage

    INSERT  @changedIssueData
    SELECT  IssueID, DatedDate, Amount, ClientID, IssueName, ShortName, IssueStatus, cusip6, IssueType, SaleType
                , InitialOfferingDocument, TaxStatus, BondForm, BankQualified, SecurityType, SaleDate, SaleTime
                , SettlementDate, FirstCouponDate, IntPmtFreq, IntCalcMeth, CouponType, Callable, CallFrequency
                , DisclosureType, PurchasePrice, Notes, NotesRefundedBy, NotesRefunds, ArbitrageYield
                , QualityControlDate, Purpose, ChangeDate, ChangeBy, ObligorClientID, EIPInvest
      FROM  Conversion.vw_LegacyIssues AS a
     WHERE  EXISTS ( SELECT 1 FROM @changedIssueIDs AS b
                      WHERE a.IssueID = b.IssueID AND b.convertedChecksum IS NULL ) ;
    SELECT  @newCount = @@ROWCOUNT ;


/**/SELECT  @codeBlockNum   = 6
/**/      , @codeBlockDesc  = @codeBlockDesc06 ; -- INSERT updated data into temp storage

    INSERT  @changedIssueData
    SELECT  IssueID, DatedDate, Amount, ClientID, IssueName, ShortName, IssueStatus, cusip6, IssueType, SaleType
                , InitialOfferingDocument, TaxStatus, BondForm, BankQualified, SecurityType, SaleDate, SaleTime
                , SettlementDate, FirstCouponDate, IntPmtFreq, IntCalcMeth, CouponType, Callable, CallFrequency
                , DisclosureType, PurchasePrice, Notes, NotesRefundedBy, NotesRefunds, ArbitrageYield
                , QualityControlDate, Purpose, ChangeDate, ChangeBy, ObligorClientID, EIPInvest
      FROM  Conversion.vw_LegacyIssues AS a
     WHERE  EXISTS ( SELECT 1 FROM @changedIssueIDs AS b
                      WHERE a.IssueID = b.IssueID AND b.legacyChecksum <> b.convertedChecksum ) ;
    SELECT  @updatedCount = @@ROWCOUNT ;


/**/SELECT  @codeBlockNum   = 7
/**/      , @codeBlockDesc  = @codeBlockDesc07 ; -- UPDATE changed data to remove invalid ObligorClientID

    UPDATE  @changedIssueData
       SET  ObligorClientID = NULL
      FROM  @changedIssueData AS a
     WHERE  NOT EXISTS ( SELECT 1 FROM edata.Clients AS b WHERE b.ClientID = a.ObligorClientID ) ;


/**/SELECT  @codeBlockNum   = 8
/**/      , @codeBlockDesc  = @codeBlockDesc08 ; -- MERGE temp storage into dbo.Issues

    BEGIN TRANSACTION ;

    SET IDENTITY_INSERT dbo.Issue ON ;

     MERGE  dbo.Issue           AS tgt
     USING  @changedIssueData   AS src ON tgt.IssueID = src.IssueID
      WHEN  MATCHED THEN
            UPDATE SET  DatedDate                   = src.DatedDate
                      , IssueAmount                 = src.Amount
                      , ClientID                    = src.ClientID
                      , IssueName                   = src.IssueName
                      , IssueShortNameID            = src.ShortName
                      , IssueStatusID               = src.IssueStatus
                      , Cusip6                      = src.cusip6
                      , IssueTypeID                 = src.IssueType
                      , MethodOfSaleID              = src.SaleType
                      , InitialOfferingDocumentID   = src.InitialOfferingDocument
                      , TaxStatus                   = src.TaxStatus
                      , BondFormTypeID              = src.BondForm
                      , BankQualified               = src.BankQualified
                      , SecurityTypeID              = src.SecurityType
                      , SaleDate                    = src.SaleDate
                      , SaleTime                    = src.SaleTime
                      , SettlementDate              = src.SettlementDate
                      , FirstInterestDate           = src.FirstCouponDate
                      , InterestPaymentFreqID       = src.IntPmtFreq
                      , InterestCalcMethodID        = src.IntCalcMeth
                      , InterestTypeID              = src.CouponType
                      , Callable                    = src.Callable
                      , CallFrequencyID             = src.CallFrequency
                      , DisclosureTypeID            = src.DisclosureType
                      , PurchasePrice               = src.PurchasePrice
                      , Notes                       = src.Notes
                      , RefundedByNote              = src.NotesRefundedBy
                      , RefundsNote                 = src.NotesRefunds
                      , ArbitrageYield              = src.ArbitrageYield
                      , QCDate                      = src.QualityControlDate
                      , LongDescription             = src.Purpose
                      , ObligorClientID             = src.ObligorClientID
                      , IsEIPInvest                 = src.EIPInvest
                      , ModifiedDate                = src.ChangeDate
                      , ModifiedUser                = src.ChangeBy

      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( IssueID, DatedDate, IssueAmount, ClientID
                        , IssueName, IssueShortNameID, IssueStatusID, Cusip6
                        , IssueTypeID, MethodOfSaleID, InitialOfferingDocumentID, TaxStatus, BondFormTypeID
                        , BankQualified, SecurityTypeID, SaleDate, SaleTime
                        , SettlementDate, FirstInterestDate, InterestPaymentFreqID
                        , InterestCalcMethodID, InterestTypeID, Callable, CallFrequencyID, DisclosureTypeID
                        , PurchasePrice, Notes, RefundedByNote, RefundsNote
                        , ArbitrageYield, QCDate, LongDescription, ObligorClientID
                        , IsEIPInvest, ModifiedDate, ModifiedUser )
            VALUES ( src.IssueID, src.DatedDate, src.Amount, src.ClientID
                        , src.IssueName, src.ShortName, src.IssueStatus, src.cusip6
                        , src.IssueType, src.SaleType, src.InitialOfferingDocument, src.TaxStatus, src.BondForm
                        , src.BankQualified, src.SecurityType, src.SaleDate, src.SaleTime
                        , src.SettlementDate, src.FirstCouponDate, src.IntPmtFreq
                        , src.IntCalcMeth, src.CouponType, src.Callable, src.CallFrequency, src.DisclosureType
                        , src.PurchasePrice, src.Notes, src.NotesRefundedBy, src.NotesRefunds
                        , src.ArbitrageYield, src.QualityControlDate, src.Purpose, src.ObligorClientID
                        , src.EIPInvest, src.ChangeDate, src.ChangeBy )
    OUTPUT  $action, inserted.IssueID INTO @issueMergeResults ;
    SELECT  @recordMERGEs = @@ROWCOUNT ;

    SET IDENTITY_INSERT dbo.Issue OFF ;


/**/SELECT  @codeBlockNum   = 9
/**/      , @codeBlockDesc  = @codeBlockDesc09 ; -- SELECT final control counts

    SELECT  @recordINSERTs   = COUNT(*) FROM @issueMergeResults WHERE  Action = 'INSERT' ;
    SELECT  @recordUPDATEs   = COUNT(*) FROM @issueMergeResults WHERE  Action = 'UPDATE' ;
    SELECT  @convertedActual = COUNT(*) FROM Conversion.vw_ConvertedIssues ;



/**/SELECT  @codeBlockNum   = 10
/**/      , @codeBlockDesc  = @codeBlockDesc10 ; -- Control Total Validation

    SELECT @total =  @convertedCount + @recordINSERTs
    IF  ( @convertedActual <> ( @convertedCount + @recordINSERTs ) )
        RAISERROR( @controlTotalsError, 16, 1, 'Converted Issues', @convertedActual, 'Existing Issues + Inserted Issues', @total ) ;

    IF  ( @convertedActual <> @legacyCount )
        RAISERROR( @controlTotalsError, 16, 1, 'Converted Issues', @convertedActual, 'Legacy Issues', @legacyCount ) ;

    IF  ( @recordINSERTs <> @newCount )
        RAISERROR( @controlTotalsError, 16, 1, 'Inserted Issues', @recordINSERTs,  'Expected Inserts', @newCount ) ;

    IF  ( @recordUPDATEs <> @updatedCount )
        RAISERROR( @controlTotalsError, 16, 1, 'Updated Issues', @recordUPDATEs,  'Expected Updates', @updatedCount ) ;

    IF  ( @recordMERGEs <> @changesCount )
        RAISERROR( @controlTotalsError, 16, 1, 'Changed Issues', @recordMERGEs,  'Expected Changes', @changesCount ) ;


    COMMIT TRANSACTION ;


endOfProc:
/**/SELECT  @codeBlockNum   = 11
/**/      , @codeBlockDesc  = @codeBlockDesc11 ; -- Reset CONTEXT_INFO to remove restrictions on triggers

    SET CONTEXT_INFO 0x0 ;



/**/SELECT  @codeBlockNum   = 12
/**/      , @codeBlockDesc  = @codeBlockDesc12 ; -- Print control totals

    SELECT  @processEndTime     = CONVERT( VARCHAR(30), GETDATE(), 121 )
          , @processElapsedTime = DATEDIFF( ms, CAST( @processStartTime AS DATETIME ), CAST( @processEndTime AS DATETIME ) ) ;

    RAISERROR( 'Conversion.processIssues CONTROL TOTALS ', 0, 0 ) ;
    RAISERROR( 'Issues on legacy system                 = % 8d', 0, 0, @legacyCount ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( 'Existing Issues on converted system     = % 8d', 0, 0, @convertedCount ) ;
    RAISERROR( '     + new records                      = % 8d', 0, 0, @newCount ) ;
    RAISERROR( '                                           ======= ', 0, 0 ) ;
    RAISERROR( 'Total Issues on converted system        = % 8d', 0, 0, @convertedActual ) ;
    RAISERROR( 'Changed records already counted         = % 8d', 0, 0, @updatedCount ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( 'Database Change Details', 0, 0 ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( '     Total INSERTs dbo.Issues           = % 8d', 0, 0, @recordINSERTs ) ;
    RAISERROR( '     Total UPDATEs dbo.Issues           = % 8d', 0, 0, @recordUPDATEs ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( '     TOTAL changes on dbo.Issues        = % 8d', 0, 0, @recordMERGEs ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( 'processIssues START : %s', 0, 0, @processStartTime ) ;
    RAISERROR( 'processIssues   END : %s', 0, 0, @processEndTime ) ;
    RAISERROR( '       Elapsed Time : %d ms', 0, 0, @processElapsedTime ) ;


END TRY
BEGIN CATCH

    IF  @@TRANCOUNT > 0
        ROLLBACK TRANSACTION ;

    EXECUTE dbo.processEhlersError ;

--    SELECT  @errorTypeID    = 1
--          , @errorSeverity  = ERROR_SEVERITY()
--          , @errorState     = ERROR_STATE()
--          , @errorNumber    = ERROR_NUMBER()
--          , @errorLine      = ERROR_LINE()
--          , @errorProcedure = ISNULL( ERROR_PROCEDURE(), '-' )
--
--    IF  @errorMessage IS NULL
--    BEGIN
--        SELECT  @errorMessage = N'Error occurred in Code Block %d, %s ' + CHAR(13)
--                              + N'Error %d, Level %d, State %d, Procedure %s, Line %d, Message: ' + ERROR_MESSAGE() ;
--
--        RAISERROR( @errorMessage, @errorSeverity, 1
--                 , @codeBlockNum
--                 , @codeBlockDesc
--                 , @errorNumber
--                 , @errorSeverity
--                 , @errorState
--                 , @errorProcedure
--                 , @errorLine ) ;
--
--        SELECT  @errorMessage = ERROR_MESSAGE() ;
--
--        EXECUTE dbo.processEhlersError  @errorTypeID
--                                      , @codeBlockNum
--                                      , @codeBlockDesc
--                                      , @errorNumber
--                                      , @errorSeverity
--                                      , @errorState
--                                      , @errorProcedure
--                                      , @errorLine
--                                      , @errorMessage
--                                      , @errorData ;
--
--    END
--        ELSE
--    BEGIN
--        SELECT  @errorSeverity  = ERROR_SEVERITY()
--              , @errorState     = ERROR_STATE()
--
--        RAISERROR( @errorMessage, @errorSeverity, @errorState ) ;
--    END

END CATCH
END
