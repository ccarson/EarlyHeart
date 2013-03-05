CREATE PROCEDURE Conversion.processBiddingParameters
AS
/*
************************************************************************************************************************************

  Procedure:    Conversion.processBiddingParameters
     Author:    Chris Carson
    Purpose:    converts legacy data from edata.Issues into dbo.BiddingParameter


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Set CONTEXT_INFO to prevent converted tables from triggering changes
    2)  Create temp storage for changed bidding parameter data
    3)  Check for BiddingParameter changes, and exit if none
    4)  load records where BiddingParameterID is 0, these are INSERTs
    5)  load records where BiddingParameterID != 0, these are UPDATEs
    6)  Throw error if no records are loaded
    7)  MERGE #processData with dbo.BiddingParameter
    8)  Reset CONTEXT_INFO to re-enable converted table triggers
    9)  Print control totals

    Notes:

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;

    DECLARE @totalRecords               AS INT = 0
          , @currentBiddingParameterID  AS INT = 0
          , @rc                         AS INT = 0
          , @recordsDELETEd             AS INT = 0
          , @recordsINSERTed            AS INT = 0
          , @recordsMERGEd              AS INT = 0
          , @recordsToDelete            AS INT = 0
          , @recordsToInsert            AS INT = 0
          , @recordsToUpdate            AS INT = 0
          , @recordsUPDATEd             AS INT = 0
          , @processBiddingParameters   AS VARBINARY(128) = CAST( 'processBiddingParameters' AS VARBINARY(128) ) ;


--  1)  Set CONTEXT_INFO to prevent converted tables from triggering changes
    SET CONTEXT_INFO @processBiddingParameters ;


--  2)  Create temp storage for changed bidding parameter data
    IF  OBJECT_ID('tempdb..#processData') IS NOT NULL
        DROP TABLE #processData ;
    CREATE TABLE #processData ( BiddingParameterID      INT     NOT NULL PRIMARY KEY CLUSTERED
                              , IssueID                 INT
                              , MinimumBid              DECIMAL(6,2)
                              , MaximumBid              DECIMAL(6,2)
                              , AllowDecrease           BIT
                              , TermBonds               BIT
                              , AdjustIssue             BIT
                              , PctInterest             BIT
                              , MaximumDecrease         DECIMAL(6,2)
                              , DateDecrease            DATE
                              , AwardBasis              VARCHAR(3)
                              , InternetSale            INT
                              , ChangeDate              DATETIME
                              , ChangeBy                VARCHAR(20) ) ;

    IF  OBJECT_ID('tempdb..#changedData') IS NOT NULL
        DROP TABLE #changedData
    CREATE TABLE #changedData ( BiddingParameterID          INT
                              , IssueID                     INT
                              , BiddingParameterChecksum    VARBINARY(128) ) ;


--  3)  Check for BiddingParameter changes, and exit if none
    INSERT  #changedData
    SELECT  BiddingParameterID, IssueID, BiddingParameterChecksum FROM Conversion.tvf_BiddingParameterChecksum( 'Legacy' )
        EXCEPT
    SELECT  BiddingParameterID, IssueID, BiddingParameterChecksum FROM Conversion.tvf_BiddingParameterChecksum( 'Converted' )
    SELECT  @totalRecords = @@ROWCOUNT ;

    IF  ( @totalRecords = 0  )
        BEGIN
            PRINT 'No BiddingParameter data changes, exiting processBiddingParameters' ;
            GOTO endOfProc ;
        END
    ELSE
        PRINT 'Migrating legacy Address data' ;


--  4)  load records where BiddingParameterID is 0, these are INSERTs
    SELECT  @currentBiddingParameterID = ISNULL( IDENT_CURRENT('dbo.BiddingParameters'), 0 ) ;

    INSERT  #processData
    SELECT  BiddingParameterID      = @currentBiddingParameterID
                                    + ROW_NUMBER() OVER ( ORDER BY (SELECT NULL) )
          , IssueID                 = bp.IssueID
          , MinimumBid              = bp.MinimumBid
          , MaximumBid              = bp.MaximumBid
          , AllowDecrease           = bp.AllowDecrease
          , TermBonds               = bp.TermBonds
          , AdjustIssue             = bp.AdjustIssue
          , PctInterest             = bp.PctInterest
          , MaximumDecrease         = bp.MaximumDecrease
          , DateDecrease            = bp.DateDecrease
          , AwardBasis              = bp.AwardBasis
          , InternetSale            = bp.InternetSale
          , ChangeDate              = bp.ChangeDate
          , ChangeBy                = bp.ChangeBy
      FROM  Conversion.vw_LegacyBiddingParameter AS bp
     WHERE  BiddingParameterID = 0 ;
    SELECT  @recordsToInsert = @@ROWCOUNT ;


--  5)  load records where BiddingParameterID != 0, these are UPDATEs
    INSERT  #processData
    SELECT  BiddingParameterID      = bp.BiddingParameterID
          , IssueID                 = bp.IssueID
          , MinimumBid              = bp.MinimumBid
          , MaximumBid              = bp.MaximumBid
          , AllowDecrease           = bp.AllowDecrease
          , TermBonds               = bp.TermBonds
          , AdjustIssue             = bp.AdjustIssue
          , PctInterest             = bp.PctInterest
          , MaximumDecrease         = bp.MaximumDecrease
          , DateDecrease            = bp.DateDecrease
          , AwardBasis              = bp.AwardBasis
          , InternetSale            = bp.InternetSale
          , ChangeDate              = bp.ChangeDate
          , ChangeBy                = bp.ChangeBy
      FROM  Conversion.vw_LegacyBiddingParameter AS bp
     WHERE  bp.BiddingParameterID > 0
            AND EXISTS ( SELECT 1 FROM #changedData AS cd
                          WHERE cd.BiddingParameterID = bp.BiddingParameterID ) ;
    SELECT  @recordsToUpdate = @@ROWCOUNT ;


--  6)  Throw error if no records are loaded
    SELECT  @totalRecords = @recordsToInsert + @recordsToUpdate ;
    IF  @totalRecords = 0
    BEGIN
        PRINT   'Error:  changes detected but not captured' ;
        SELECT  @rc = 16 ;
        GOTO    endOfProc ;
    END


--  7)  MERGE #processData with dbo.BiddingParameter
    DECLARE @SummaryOfChanges AS TABLE( Change NVARCHAR(10) ) ;

    SET IDENTITY_INSERT dbo.BiddingParameter ON ;

     MERGE  dbo.BiddingParameter AS tgt
     USING  #processData         AS src
        ON  tgt.BiddingParameterID = src.BiddingParameterID
      WHEN  MATCHED THEN
            UPDATE
               SET  IssueID                 = src.IssueID
                  , MinimumBidPercent       = src.MinimumBid
                  , MaximumBidPercent       = src.MaximumBid
                  , AllowDescendingRate     = src.AllowDecrease
                  , AllowTerm               = src.TermBonds
                  , AllowParAdjustment      = src.AdjustIssue
                  , AllowPercentIncrement   = src.PctInterest
                  , DescMaxPct              = src.MaximumDecrease
                  , DescRateDate            = src.DateDecrease
                  , AwardBasis              = src.AwardBasis
                  , InternetBiddingTypeID   = src.InternetSale
                  , ModifiedDate            = src.ChangeDate
                  , ModifiedUser            = src.ChangeBy
      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( BiddingParameterID, IssueID
                        , MinimumBidPercent, MaximumBidPercent
                        , AllowDescendingRate, AllowTerm, AllowParAdjustment
                        , AllowPercentIncrement, DescMaxPct, DescRateDate
                        , AwardBasis, InternetBiddingTypeID
                        , ModifiedDate, ModifiedUser )
            VALUES ( src.BiddingParameterID
                   , src.IssueID
                   , src.MinimumBid
                   , src.MaximumBid
                   , src.AllowDecrease
                   , src.TermBonds
                   , src.AdjustIssue
                   , src.PctInterest
                   , src.MaximumDecrease
                   , src.DateDecrease
                   , src.AwardBasis
                   , src.InternetSale
                   , src.ChangeDate
                   , src.ChangeBy )
    OUTPUT  $action INTO @SummaryOfChanges ;
    SELECT  @recordsMERGEd = @@ROWCOUNT    ;

    SET IDENTITY_INSERT dbo.BiddingParameter OFF ;

    IF  @recordsMERGEd <> @totalRecords
    BEGIN
        PRINT   'Processing Error: @totalRecords  = ' + CAST( @totalRecords AS VARCHAR(20) )
              + '                  @recordsMERGEd = ' + CAST( @recordsMERGEd AS VARCHAR(20) ) + ' .' ;
        SELECT  @rc = 16 ;
    END


    SELECT  @recordsINSERTed = COUNT(*) FROM @SummaryOfChanges WHERE Change = 'INSERT' ;
    IF  @recordsINSERTed <> @recordsToInsert
    BEGIN
        PRINT   'Error ON INSERT:  @recordsToInsert = ' + CAST( @recordsToInsert AS VARCHAR(20) )
              + '                  @recordsINSERTed = ' + CAST( @recordsINSERTed AS VARCHAR(20) ) + ' .' ;
        SELECT  @rc = 16 ;
    END

    SELECT  @recordsUPDATEd = COUNT(*) FROM @SummaryOfChanges WHERE Change = 'UPDATE' ;
    IF  @recordsUPDATEd <> @recordsToUpdate
    BEGIN
        PRINT   'Error ON UPDATE:  @recordsToUpdate = ' + CAST( @recordsToUpdate AS VARCHAR(20) )
              + '                  @recordsUPDATEd  = ' + CAST( @recordsUPDATEd AS VARCHAR(20) ) + ' .' ;
        SELECT  @rc = 16 ;
    END

    SELECT  @recordsDELETEd = COUNT(*) FROM @SummaryOfChanges WHERE Change = 'DELETE' ;
    IF  @recordsDELETEd <> @recordsToDelete
    BEGIN
        PRINT   'Error ON UPDATE:  @recordsToDelete = ' + CAST( @recordsToDelete AS VARCHAR(20) )
              + '                  @recordsDELETEd  = ' + CAST( @recordsDELETEd AS VARCHAR(20) ) + ' .' ;
        SELECT  @rc = 16 ;
    END

    IF  @rc = 16    GOTO endOfProc ;


--  8)  Reset CONTEXT_INFO to re-enable converted table triggers
endOfProc:
    SET CONTEXT_INFO 0x0 ;


--  9)  Print control totals
    PRINT 'CONTROL TOTALS ' ;
    PRINT '    Changed records                          = ' + CAST( @totalRecords    AS VARCHAR(20) ) ;
    PRINT '         new records                         = ' + CAST( @recordsToInsert AS VARCHAR(20) ) ;
    PRINT '         modified records                    = ' + CAST( @recordsToUpdate AS VARCHAR(20) ) ;
    PRINT '         deleted records                     = ' + CAST( @recordsToDelete AS VARCHAR(20) ) ;
    PRINT '' ;
    PRINT '    Processed records                        = ' + CAST( @recordsMERGEd   AS VARCHAR(20) ) ;
    PRINT '         INSERTs to   dbo.BiddingParameter   = ' + CAST( @recordsINSERTed AS VARCHAR(20) ) ;
    PRINT '         UPDATEs to   dbo.BiddingParameter   = ' + CAST( @recordsUPDATEd  AS VARCHAR(20) ) ;
    PRINT '         DELETEs from dbo.BiddingParameter   = ' + CAST( @recordsDELETEd  AS VARCHAR(20) ) ;
    PRINT '' ;
END
