CREATE PROCEDURE Conversion.processIssuePostBond
AS
/*
************************************************************************************************************************************

  Procedure:    Conversion.processIssuePostBond
     Author:    Chris Carson
    Purpose:    converts legacy Issue Post Bond data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         ###DATE###          Issues Conversion

    Logic Summary:
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


    DECLARE @processStartTime       AS VARCHAR (30)     = CONVERT( VARCHAR(30), GETDATE(), 121 )
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

    DECLARE @changedIssueData   AS  TABLE ( IssueID         INT
                                          , AccruedInterest DECIMAL (15,2)
                                          , ArbitrageYield  DECIMAL (11,8)
                                          , NICAmount       DECIMAL (15,2)
                                          , NICPercent      DECIMAL (11,8)
                                          , TICPercent      DECIMAL (11,8)
                                          , AICPercent      DECIMAL (11,8)
                                          , ModifiedDate    DATETIME
                                          , ModifiedUser    VARCHAR(20) ) ;



/**/SELECT  @codeBlockNum   = 2
/**/      , @codeBlockDesc  = @codeBlockDesc02 ; -- SELECT initial control counts

    SELECT  @legacyCount        = COUNT(*) FROM Conversion.vw_LegacyIssuePostBond ;
    SELECT  @convertedCount     = COUNT(*) FROM dbo.IssuePostBond ;
    SELECT  @convertedActual    = @convertedCount ;


/**/SELECT  @codeBlockNum   = 3
/**/      , @codeBlockDesc  = @codeBlockDesc03 ; -- INSERT new IssuePostBond data into temp storage

    INSERT  @changedIssueData
    SELECT  IssueID, AccruedInterest, ArbitrageYield
                , NICAmount, NICPercent, TICPercent, AICPercent
--              , BBI
                , ModifiedDate, ModifiedUser
      FROM  Conversion.vw_LegacyIssuePostBond AS psb
     WHERE  NOT EXISTS ( SELECT 1 FROM dbo.IssuePostBond AS ipb
                          WHERE ipb.IssueID = psb.IssueID ) ; 
    SELECT  @newCount = @@ROWCOUNT ; 
    
    
/**/SELECT  @codeBlockNum   = 4
/**/      , @codeBlockDesc  = @codeBlockDesc03 ; -- INSERT changed IssuePostBond data into temp storage

    INSERT  @changedIssueData
    SELECT  IssueID, AccruedInterest, ArbitrageYield
                , NICAmount, NICPercent, TICPercent, AICPercent
                , ModifiedDate, ModifiedUser
      FROM  Conversion.vw_LegacyIssuePostBond AS psb
     WHERE  EXISTS ( SELECT 1 FROM dbo.IssuePostBond AS ipb
                      WHERE ipb.IssueID = psb.IssueID ) 
       AND  NOT EXISTS ( SELECT 1 FROM dbo.IssuePostBond AS ips
                          WHERE ips.IssueID         = psb.IssueID
                            AND ips.AccruedInterest = psb.AccruedInterest
                            AND ips.ArbitrageYield  = psb.ArbitrageYield
                            AND ips.NICAmount       = psb.NICAmount
                            AND ips.NICPercent      = psb.NICPercent
                            AND ips.TICPercent      = psb.TICPercent
                            AND ips.AICPercent      = psb.AICPercent
                            ) ; 
    SELECT  @updatedCount = @@ROWCOUNT ;
    SELECT  @changesCount = @newCount + @updatedCount ;
    
    
/**/SELECT  @codeBlockNum   = 5
/**/      , @codeBlockDesc  = @codeBlockDesc05 ; -- Stop processing if there are no data changes

    IF  ( @changesCount = 0 )
        GOTO  endOfProc ;


/**/SELECT  @codeBlockNum   = 8
/**/      , @codeBlockDesc  = @codeBlockDesc08 ; -- MERGE temp storage into dbo.IssuePostBond

    BEGIN TRANSACTION ;

     MERGE  dbo.IssuePostBond   AS tgt
     USING  @changedIssueData   AS src ON tgt.IssueID = src.IssueID
      WHEN  MATCHED THEN
            UPDATE SET  AccruedInterest = src.AccruedInterest
                      , ArbitrageYield  = src.ArbitrageYield
                      , NICAmount       = src.NICAmount
                      , NICPercent      = src.NICPercent
                      , TICPercent      = src.TICPercent
                      , AICPercent      = src.AICPercent
                      , ModifiedDate    = src.ModifiedDate
                      , ModifiedUser    = src.ModifiedUser

      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( IssueID, AccruedInterest, ArbitrageYield
                        , NICAmount, NICPercent, TICPercent, AICPercent
                        , ModifiedDate, ModifiedUser ) 
            VALUES ( src.IssueID, src.AccruedInterest, src.ArbitrageYield
                        , src.NICAmount, src.NICPercent, src.TICPercent, src.AICPercent
                        , src.ModifiedDate, src.ModifiedUser ) 
    OUTPUT  $action, inserted.IssueID INTO @issueMergeResults ;
    SELECT  @recordMERGEs = @@ROWCOUNT ;

/**/SELECT  @codeBlockNum   = 9
/**/      , @codeBlockDesc  = @codeBlockDesc09 ; -- SELECT final control counts

    SELECT  @recordINSERTs   = COUNT(*) FROM @issueMergeResults WHERE  Action = 'INSERT' ;
    SELECT  @recordUPDATEs   = COUNT(*) FROM @issueMergeResults WHERE  Action = 'UPDATE' ;
    SELECT  @convertedActual = COUNT(*) FROM dbo.IssuePostBond ;


/**/SELECT  @codeBlockNum   = 10
/**/      , @codeBlockDesc  = @codeBlockDesc10 ; -- Control Total Validation

    SELECT @total =  @convertedCount + @recordINSERTs
    IF  ( @convertedActual <> ( @convertedCount + @recordINSERTs ) )
        RAISERROR( @controlTotalsError, 16, 1, 'Converted Records', @convertedActual, 'Existing Records + Inserted Records', @total ) ;

    IF  ( @convertedActual <> @legacyCount )
        RAISERROR( @controlTotalsError, 16, 1, 'Converted Records', @convertedActual, 'Legacy Records', @legacyCount ) ;

    IF  ( @recordINSERTs <> @newCount )
        RAISERROR( @controlTotalsError, 16, 1, 'Inserted Records', @recordINSERTs,  'Expected Inserts', @newCount ) ;

    IF  ( @recordUPDATEs <> @updatedCount )
        RAISERROR( @controlTotalsError, 16, 1, 'Updated Records', @recordUPDATEs,  'Expected Updates', @updatedCount ) ;

    IF  ( @recordMERGEs <> @changesCount )
        RAISERROR( @controlTotalsError, 16, 1, 'Changed Records', @recordMERGEs,  'Expected Changes', @changesCount ) ;


    COMMIT TRANSACTION ;


endOfProc:
/**/SELECT  @codeBlockNum   = 11
/**/      , @codeBlockDesc  = @codeBlockDesc11 ; -- Reset CONTEXT_INFO to remove restrictions on triggers

    SET CONTEXT_INFO 0x0 ;



/**/SELECT  @codeBlockNum   = 12
/**/      , @codeBlockDesc  = @codeBlockDesc12 ; -- Print control totals

    SELECT  @processEndTime     = CONVERT( VARCHAR(30), GETDATE(), 121 )
          , @processElapsedTime = DATEDIFF( ms, CAST( @processStartTime AS DATETIME ), CAST( @processEndTime AS DATETIME ) ) ;

    RAISERROR( 'Conversion.processIssuePostBond CONTROL TOTALS ', 0, 0 ) ;
    RAISERROR( 'Records on legacy system                = % 8d', 0, 0, @legacyCount ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( 'Existing Records on converted system    = % 8d', 0, 0, @convertedCount ) ;
    RAISERROR( '     + new Records                      = % 8d', 0, 0, @newCount ) ;
    RAISERROR( '                                           ======= ', 0, 0 ) ;
    RAISERROR( 'Total Records on converted system       = % 8d', 0, 0, @convertedActual ) ;
    RAISERROR( 'Changed records already counted         = % 8d', 0, 0, @updatedCount ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( 'Database Change Details', 0, 0 ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( '     Total INSERTs dbo.IssuePostBond    = % 8d', 0, 0, @recordINSERTs ) ;
    RAISERROR( '     Total UPDATEs dbo.IssuePostBond    = % 8d', 0, 0, @recordUPDATEs ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( '     TOTAL changes on dbo.IssuePostBond = % 8d', 0, 0, @recordMERGEs ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( 'processIssuePostBond START : %s', 0, 0, @processStartTime ) ;
    RAISERROR( 'processIssuePostBond   END : %s', 0, 0, @processEndTime ) ;
    RAISERROR( '              Elapsed Time : %d ms', 0, 0, @processElapsedTime ) ;


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
