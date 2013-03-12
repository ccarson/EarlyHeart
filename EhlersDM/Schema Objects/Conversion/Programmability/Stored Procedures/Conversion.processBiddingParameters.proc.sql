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
    ccarson         ###DATE###          updated for Issues Conversion

    Logic Summary:
    1)  SET CONTEXT_INFO, inhibiting triggers when invoked
    2)  SELECT initial control counts
    3)  Stop processing if there are no data changes
    4)  INSERT new records into temp storage
    5)  INSERT changed records into temp storage
    6)  MERGE temporary storage into dbo.BiddingParameter
    7)  INSERT updated data into temp storage
    8)  SELECT final control counts
    9)  Control Total Validation
   10)  Reset CONTEXT_INFO, allowing triggers to fire when invoked

    Notes:

************************************************************************************************************************************
*/
BEGIN
BEGIN TRY
    SET NOCOUNT ON ;


    DECLARE @processBiddingParameters   AS VARBINARY (128)  = CAST( 'processBiddingParameters' AS VARBINARY(128) )
          , @processStartTime           AS VARCHAR (30)     = CONVERT( VARCHAR(30), GETDATE(), 121 )
          , @processEndTime             AS VARCHAR (30)     = NULL
          , @processElapsedTime         AS INT              = 0 ;


    DECLARE @codeBlockDesc01            AS VARCHAR (128)    = 'SET CONTEXT_INFO, inhibiting triggers when invoked'
          , @codeBlockDesc02            AS VARCHAR (128)    = 'SELECT initial control counts'
          , @codeBlockDesc03            AS VARCHAR (128)    = 'Stop processing if there are no data changes'
          , @codeBlockDesc04            AS VARCHAR (128)    = 'INSERT new records into temp storage'
          , @codeBlockDesc05            AS VARCHAR (128)    = 'INSERT changed records into temp storage'
          , @codeBlockDesc06            AS VARCHAR (128)    = 'MERGE temporary storage into dbo.BiddingParameter'
          , @codeBlockDesc07            AS VARCHAR (128)    = 'INSERT updated data into temp storage'
          , @codeBlockDesc08            AS VARCHAR (128)    = 'SELECT final control counts'
          , @codeBlockDesc09            AS VARCHAR (128)    = 'Control Total Validation'
          , @codeBlockDesc10            AS VARCHAR (128)    = 'Reset CONTEXT_INFO, allowing triggers to fire when invoked' ;


    DECLARE @codeBlockNum               AS INT
          , @codeBlockDesc              AS VARCHAR (128)
          , @errorTypeID                AS INT
          , @errorSeverity              AS INT
          , @errorState                 AS INT
          , @errorNumber                AS INT
          , @errorLine                  AS INT
          , @errorProcedure             AS VARCHAR (128)
          , @errorMessage               AS VARCHAR (MAX)    = NULL
          , @errorData                  AS VARCHAR (MAX)    = NULL ;

    DECLARE @controlTotalsError         AS VARCHAR (200)    = N'Control Total Failure:  %s = %d, %s = %d' ;


    DECLARE @changesCount               AS INT = 0
          , @convertedActual            AS INT = 0
          , @convertedCount             AS INT = 0
          , @currentBiddingParameterID  AS INT = 0
          , @legacyCount                AS INT = 0
          , @newCount                   AS INT = 0
          , @recordINSERTs              AS INT = 0
          , @recordMERGEs               AS INT = 0
          , @recordUPDATEs              AS INT = 0
          , @total                      AS INT = 0
          , @updatedCount               AS INT = 0 ;

    DECLARE @biddingParameterData       AS TABLE ( BiddingParameterID       INT NOT NULL PRIMARY KEY CLUSTERED
                                                 , IssueID                  INT
                                                 , MinimumBid               DECIMAL (6,2)
                                                 , MaximumBid               DECIMAL (6,2)
                                                 , AllowDecrease            BIT
                                                 , TermBonds                BIT
                                                 , AdjustIssue              BIT
                                                 , PctInterest              BIT
                                                 , MaximumDecrease          DECIMAL (6,2)
                                                 , DateDecrease             DATE
                                                 , AwardBasis               VARCHAR (3)
                                                 , InternetSale             INT
                                                 , ChangeDate               DATETIME
                                                 , ChangeBy                 VARCHAR (20) ) ;

    DECLARE @changedData                AS TABLE ( BiddingParameterID       INT
                                                 , IssueID                  INT
                                                 , BiddingParameterChecksum VARBINARY(128) ) ;

    DECLARE @mergeResults               AS TABLE ( action                   NVARCHAR (10) ) ;


/**/SELECT  @codeBlockNum   = 1
/**/      , @codeBlockDesc  = @codeBlockDesc01 ; -- SET CONTEXT_INFO, inhibiting triggers when invoked

    SET CONTEXT_INFO @processBiddingParameters ;


/**/SELECT  @codeBlockNum   = 2
/**/      , @codeBlockDesc  = @codeBlockDesc02 ; -- SELECT initial control counts

    SELECT  @legacyCount        = COUNT(*) FROM Conversion.vw_LegacyBiddingParameter WHERE BiddingParameterID > 0 ;
    SELECT  @convertedCount     = COUNT(*) FROM Conversion.vw_ConvertedBiddingParameter ;
    SELECT  @convertedActual    = @convertedCount ;


/**/SELECT  @codeBlockNum   = 3
/**/      , @codeBlockDesc  = @codeBlockDesc03 ; -- Stop processing if there are no data changes

    INSERT  @changedData
    SELECT  BiddingParameterID, IssueID, BiddingParameterChecksum FROM Conversion.tvf_BiddingParameterChecksum( 'Legacy' )
        EXCEPT
    SELECT  BiddingParameterID, IssueID, BiddingParameterChecksum FROM Conversion.tvf_BiddingParameterChecksum( 'Converted' )
    SELECT  @changesCount = @@ROWCOUNT ;

    IF  @changesCount = 0 GOTO endOfProc ;


/**/SELECT  @codeBlockNum   = 4
/**/      , @codeBlockDesc  = @codeBlockDesc04 ; -- INSERT new records into temp storage

    SELECT  @currentBiddingParameterID = COALESCE( MAX( BiddingParameterID ), 0 ) FROM dbo.BiddingParameter ;

    INSERT  @biddingParameterData
    SELECT  BiddingParameterID      = @currentBiddingParameterID
                                    + ROW_NUMBER() OVER ( ORDER BY (SELECT NULL) )
          , IssueID                 = bdp.IssueID
          , MinimumBid              = bdp.MinimumBid
          , MaximumBid              = bdp.MaximumBid
          , AllowDecrease           = bdp.AllowDecrease
          , TermBonds               = bdp.TermBonds
          , AdjustIssue             = bdp.AdjustIssue
          , PctInterest             = bdp.PctInterest
          , MaximumDecrease         = bdp.MaximumDecrease
          , DateDecrease            = bdp.DateDecrease
          , AwardBasis              = bdp.AwardBasis
          , InternetSale            = bdp.InternetSale
          , ChangeDate              = bdp.ChangeDate
          , ChangeBy                = bdp.ChangeBy
      FROM  Conversion.vw_LegacyBiddingParameter AS bdp
     WHERE  bdp.BiddingParameterID = 0 ;
    SELECT  @newCount = @@ROWCOUNT ;


/**/SELECT  @codeBlockNum   = 5
/**/      , @codeBlockDesc  = @codeBlockDesc05 ; -- INSERT changed records into temp storage

    INSERT  @biddingParameterData
    SELECT  BiddingParameterID      = bdp.BiddingParameterID
          , IssueID                 = bdp.IssueID
          , MinimumBid              = bdp.MinimumBid
          , MaximumBid              = bdp.MaximumBid
          , AllowDecrease           = bdp.AllowDecrease
          , TermBonds               = bdp.TermBonds
          , AdjustIssue             = bdp.AdjustIssue
          , PctInterest             = bdp.PctInterest
          , MaximumDecrease         = bdp.MaximumDecrease
          , DateDecrease            = bdp.DateDecrease
          , AwardBasis              = bdp.AwardBasis
          , InternetSale            = bdp.InternetSale
          , ChangeDate              = bdp.ChangeDate
          , ChangeBy                = bdp.ChangeBy
      FROM  Conversion.vw_LegacyBiddingParameter AS bdp
INNER JOIN  @changedData                         AS chg ON chg.BiddingParameterID = bdp.BiddingParameterID
     WHERE  bdp.BiddingParameterID > 0 ;
    SELECT  @updatedCount = @@ROWCOUNT ;


/**/SELECT  @codeBlockNum   = 6
/**/      , @codeBlockDesc  = @codeBlockDesc06 ; -- MERGE temporary storage into dbo.BiddingParameter

    BEGIN TRANSACTION ;

    SET IDENTITY_INSERT dbo.BiddingParameter ON ;

     MERGE  dbo.BiddingParameter    AS tgt
     USING  @biddingParameterData   AS src ON tgt.BiddingParameterID = src.BiddingParameterID
      WHEN  MATCHED THEN
            UPDATE  SET IssueID                 = src.IssueID
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
            INSERT ( BiddingParameterID, IssueID, MinimumBidPercent, MaximumBidPercent
                        , AllowDescendingRate, AllowTerm, AllowParAdjustment
                        , AllowPercentIncrement, DescMaxPct, DescRateDate
                        , AwardBasis, InternetBiddingTypeID, ModifiedDate, ModifiedUser )
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
    OUTPUT  $action INTO @mergeResults ;
    SELECT  @recordMERGEs = @@ROWCOUNT    ;

    SET IDENTITY_INSERT dbo.BiddingParameter OFF ;


/**/SELECT  @codeBlockNum   = 7
/**/      , @codeBlockDesc  = @codeBlockDesc07 ; -- SELECT final control counts

    SELECT  @recordINSERTs   = COUNT(*) FROM @mergeResults WHERE  Action = 'INSERT' ;
    SELECT  @recordUPDATEs   = COUNT(*) FROM @mergeResults WHERE  Action = 'UPDATE' ;
    SELECT  @convertedActual = COUNT(*) FROM Conversion.vw_ConvertedBiddingParameter ;



/**/SELECT  @codeBlockNum   = 8
/**/      , @codeBlockDesc  = @codeBlockDesc08 ; -- Control Total Validation

    SELECT @total =  @convertedCount + @recordINSERTs
    IF  ( @convertedActual <> ( @convertedCount + @recordINSERTs ) )
        RAISERROR( @controlTotalsError, 16, 1, 'Converted Bidding Parameters', @convertedActual, 'Existing BPs + Inserted BPs', @total ) ;

    IF  ( @convertedActual <> @legacyCount )
        RAISERROR( @controlTotalsError, 16, 1, 'Converted Bidding Parameters', @convertedActual, 'Legacy BPs', @legacyCount ) ;

    IF  ( @recordINSERTs <> @newCount )
        RAISERROR( @controlTotalsError, 16, 1, 'Inserted Bidding Parameters', @recordINSERTs,  'Expected Inserts', @newCount ) ;

    IF  ( @recordUPDATEs <> @updatedCount )
        RAISERROR( @controlTotalsError, 16, 1, 'Updated Bidding Parameters', @recordUPDATEs,  'Expected Updates', @updatedCount ) ;

    IF  ( @recordMERGEs <> @changesCount )
        RAISERROR( @controlTotalsError, 16, 1, 'Changed Bidding Parameters', @recordMERGEs,  'Expected Changes', @changesCount ) ;


    COMMIT TRANSACTION ;


endOfProc:
/**/SELECT  @codeBlockNum   = 9
/**/      , @codeBlockDesc  = @codeBlockDesc09 ; -- Reset CONTEXT_INFO, allowing triggers to fire when invoked
    SET CONTEXT_INFO 0x0 ;


/**/SELECT  @codeBlockNum   = 10
/**/      , @codeBlockDesc  = @codeBlockDesc10 ; -- Print control totals

    SELECT  @processEndTime     = CONVERT( VARCHAR(30), GETDATE(), 121 )
          , @processElapsedTime = DATEDIFF( ms, CAST( @processStartTime AS DATETIME ), CAST( @processEndTime AS DATETIME ) ) ;

    RAISERROR( 'Conversion.processBiddingParameters CONTROL TOTALS ', 0, 0 ) ;
    RAISERROR( 'Legacy Bidding Parameters ( BPs )       = % 8d', 0, 0, @legacyCount ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( 'Existing BPs on converted system        = % 8d', 0, 0, @convertedCount ) ;
    RAISERROR( '     + new records                      = % 8d', 0, 0, @newCount ) ;
    RAISERROR( '                                           ======= ', 0, 0 ) ;
    RAISERROR( 'Total BPs on converted system           = % 8d', 0, 0, @convertedActual ) ;
    RAISERROR( 'Changed records already counted         = % 8d', 0, 0, @updatedCount ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( 'Database Change Details', 0, 0 ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( '     Total INSERTs dbo.BiddingParameter = % 8d', 0, 0, @recordINSERTs ) ;
    RAISERROR( '     Total UPDATEs dbo.BiddingParameter = % 8d', 0, 0, @recordUPDATEs ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( '     TOTAL database changes             = % 8d', 0, 0, @recordMERGEs ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( 'processBiddingParameters   START : %s', 0, 0, @processStartTime ) ;
    RAISERROR( 'processBiddingParameters     END : %s', 0, 0, @processEndTime ) ;
    RAISERROR( '                    Elapsed Time : %d ms', 0, 0, @processElapsedTime ) ;


END TRY
BEGIN CATCH

    IF  @@TRANCOUNT > 0 ROLLBACK TRANSACTION ;
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
