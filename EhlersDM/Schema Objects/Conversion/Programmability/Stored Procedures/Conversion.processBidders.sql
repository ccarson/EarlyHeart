CREATE PROCEDURE Conversion.processBidders
AS
/*
************************************************************************************************************************************

  Procedure:    Conversion.processBidders
     Author:    Chris Carson
    Purpose:    converts legacy Bidder and BidMaturities data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created
    ccarson         ###DATE###          revised error reporting

    Logic Summary:
    1)  SELECT initial control counts
    2)  INSERT new records into dbo.Bidder
    3)  MERGE changed data into dbo.Bidder
    4)  DELETE dropped records from dbo.Bidder
    5)  SELECT final control counts
    6)  Validate control totals
    7)  Print control totals

    Notes:


************************************************************************************************************************************
*/
BEGIN
BEGIN TRY
    SET NOCOUNT     ON ;
    SET XACT_ABORT  ON ;

    DECLARE @localTransaction   AS BIT ;

    IF  @@TRANCOUNT = 0
    BEGIN
        SET @localTransaction = 1 ;
        BEGIN TRANSACTION localTransaction ;
    END

    DECLARE @controlTotalsError AS VARCHAR (200)    = N'Control Total Failure:  %s = %d, %s = %d' ;

    DECLARE @fromConversion     AS VARBINARY (128)  = CAST( 'fromConversion' AS VARBINARY (128) )
          , @processStartTime   AS VARCHAR (30)     = CONVERT( VARCHAR(30), GETDATE(), 121 )
          , @processEndTime     AS VARCHAR (30)     = NULL
          , @processElapsedTime AS INT              = 0 ;

    DECLARE @codeBlockNum       AS INT
          , @codeBlockDesc      AS SYSNAME
          , @codeBlockDesc01    AS SYSNAME = 'SELECT initial control counts'
          , @codeBlockDesc02    AS SYSNAME = 'INSERT new records into dbo.Bidder'
          , @codeBlockDesc03    AS SYSNAME = 'MERGE changed data into dbo.Bidder'
          , @codeBlockDesc04    AS SYSNAME = 'DELETE dropped records from dbo.Bidder'
          , @codeBlockDesc05    AS SYSNAME = 'SELECT final control counts'
          , @codeBlockDesc06    AS SYSNAME = 'Validate control totals'
          , @codeBlockDesc07    AS SYSNAME = 'Print control totals' ;



    DECLARE @changesCount       AS INT  = 0
          , @convertedActual    AS INT  = 0
          , @convertedCount     AS INT  = 0
          , @droppedCount       AS INT  = 0
          , @legacyCount        AS INT  = 0
          , @newCount           AS INT  = 0
          , @updatedCount       AS INT  = 0
          , @total              AS INT  = 0 ;



/**/SELECT  @codeBlockNum   = 01, @codeBlockDesc = @codeBlockDesc01 ; -- SELECT initial control counts
    SELECT  @legacyCount        = COUNT(*) FROM Conversion.vw_LegacyBidders ;
    SELECT  @convertedCount     = COUNT(*) FROM dbo.Bidder ;
    SELECT  @convertedActual    = @convertedCount ;



/**/SELECT  @codeBlockNum   = 02, @codeBlockDesc = @codeBlockDesc02 ; -- INSERT new records into dbo.Bidder
    INSERT  dbo.Bidder ( IssueID, FirmID, BidSourceID, BidPrice, TICPercent, NICPercent, NICAmount, BABTICPercent
                            , HasWinningBid, IsRecoveryAct, ModifiedDate, ModifiedUser )
    SELECT  IssueID, FirmID, '3', PurchasePrice, TICPercent, NICPercent, NICAmount, BABTICPercent
                , HasWinningBid, IsRecoveryAct, GETDATE(), 'processBidders'
      FROM  Conversion.vw_LegacyBidders AS lgb
     WHERE  NOT EXISTS ( SELECT 1 FROM dbo.Bidder AS bid
                          WHERE bid.IssueID = lgb.IssueID AND bid.FirmID = lgb.FirmID ) ;
    SELECT  @newCount = @@ROWCOUNT ;



/**/SELECT  @codeBlockNum   = 03, @codeBlockDesc = @codeBlockDesc03 ; -- MERGE changed data into dbo.Bidder
      WITH  changedData AS (
            SELECT  IssueID, FirmID, PurchasePrice, TICPercent, NICPercent, NICAmount, BABTICPercent, HasWinningBid, IsRecoveryAct
              FROM  Conversion.vw_LegacyBidders AS lgb
             WHERE  EXISTS ( SELECT 1 FROM dbo.Bidder AS bid WHERE bid.IssueID = lgb.IssueID AND bid.FirmID = lgb.FirmID )
                EXCEPT
            SELECT  IssueID, FirmID, BidPrice, TICPercent, NICPercent, NICAmount, BABTICPercent, HasWinningBid, IsRecoveryAct
              FROM  dbo.Bidder )

     MERGE  dbo.Bidder  AS tgt
     USING  changedData AS src ON tgt.IssueID = src.IssueID AND tgt.FirmID = src.FirmID
      WHEN  MATCHED THEN
            UPDATE  SET BidPrice        = src.PurchasePrice
                      , TICPercent      = src.TICPercent
                      , NICPercent      = src.NICPercent
                      , NICAmount       = src.NICAmount
                      , BABTICPercent   = src.BABTICPercent
                      , HasWinningBid   = src.HasWinningBid
                      , IsRecoveryAct   = src.IsRecoveryAct
                      , ModifiedUser    = 'processBidders'
                      , ModifiedDate    = GETDATE() ;
    SELECT  @updatedCount = @@ROWCOUNT ;



/**/SELECT  @codeBlockNum   = 04, @codeBlockDesc = @codeBlockDesc04 ; -- DELETE dropped records from dbo.Bidder
    DELETE  dbo.Bidder
     WHERE  NOT EXISTS ( SELECT 1 FROM Conversion.vw_LegacyBidders AS l
                          WHERE l.IssueID = dbo.Bidder.IssueID AND l.FirmID = dbo.Bidder.FirmID ) ;
    SELECT  @droppedCount = @@ROWCOUNT ;



/**/SELECT  @codeBlockNum   = 05, @codeBlockDesc = @codeBlockDesc05 ; -- SELECT final control counts
    SELECT  @convertedActual = COUNT(*) FROM dbo.Bidder ;



/**/SELECT  @codeBlockNum   = 06, @codeBlockDesc = @codeBlockDesc06 ; -- Validate control totals
    IF  @convertedActual <> @legacyCount
        RAISERROR( @controlTotalsError, 16, 1, 'Converted Bidders', @convertedActual, 'Legacy Bidders', @legacyCount ) ;

    SELECT @total =  @convertedCount + @newCount - @droppedCount
    IF  @convertedActual <> @total
        RAISERROR( @controlTotalsError, 16, 1, 'Converted Bidders', @convertedActual, 'Existing Bidders + Net Changes', @total ) ;



endOfProc:
/**/SELECT  @codeBlockNum   = 07, @codeBlockDesc = @codeBlockDesc07 ; -- Print control totals
    SELECT  @processEndTime     = CONVERT( VARCHAR(30), GETDATE(), 121 )
          , @processElapsedTime = DATEDIFF( ms, CAST( @processStartTime AS DATETIME ), CAST( @processEndTime AS DATETIME ) ) ;

    RAISERROR( 'Conversion.processBidders CONTROL TOTALS ', 0, 0 ) ;
    RAISERROR( 'Bidders on legacy system                = % 8d', 0, 0, @legacyCount ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( 'Existing Bidders on converted system    = % 8d', 0, 0, @convertedCount ) ;
    RAISERROR( '     + new records                      = % 8d', 0, 0, @newCount ) ;
    RAISERROR( '     + dropped records                  = % 8d', 0, 0, @droppedCount ) ;
    RAISERROR( '                                           ======= ', 0, 0 ) ;
    RAISERROR( 'Total Bidders on converted system       = % 8d', 0, 0, @convertedActual ) ;
    RAISERROR( 'Changed records already counted         = % 8d', 0, 0, @updatedCount ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( 'processBidders START : %s', 0, 0, @processStartTime ) ;
    RAISERROR( 'processBidders   END : %s', 0, 0, @processEndTime ) ;
    RAISERROR( '        Elapsed Time : %d ms', 0, 0, @processElapsedTime ) ;

    IF  @localTransaction = 1 AND XACT_STATE() = 1
        COMMIT TRANSACTION localTransaction ;

    RETURN 0 ;

END TRY
BEGIN CATCH

    DECLARE @errorTypeID            AS INT              = 1
          , @errorSeverity          AS INT              = ERROR_SEVERITY()
          , @errorState             AS INT              = ERROR_STATE()
          , @errorNumber            AS INT              = ERROR_NUMBER()
          , @errorLine              AS INT              = ERROR_LINE()
          , @errorProcedure         AS SYSNAME          = ERROR_PROCEDURE()
          , @errorMessage           AS VARCHAR (MAX)
          , @formattedErrorMessage  AS VARCHAR (MAX)    = NULL
          , @errorData              AS VARCHAR (MAX)    = NULL
          , @errorDataTemp          AS VARCHAR (MAX)    = NULL ;

    IF  @@TRANCOUNT > 0 ROLLBACK TRANSACTION ;

    IF  @errorMessage IS NULL
    BEGIN
        SELECT  @errorMessage = ERROR_MESSAGE() ;

        SELECT  @errorDataTemp = '<b>Control Totals</b></br></br>'
              + '<table border="1">'
              + '<tr><th>Description</th><th>Count</th></tr>'
              + '<tr><td>@legacyCount</td><td>'     + STR( @legacyCount, 8 )     + '</td></tr>'
              + '<tr><td>@convertedCount</td><td>'  + STR( @convertedCount, 8 )  + '</td></tr>'
              + '<tr><td>@newCount</td><td>'        + STR( @newCount, 8 )        + '</td></tr>'
              + '<tr><td>@droppedCount</td><td>'    + STR( @droppedCount, 8 )    + '</td></tr>'
              + '<tr><td>@convertedActual</td><td>' + STR( @convertedActual, 8 ) + '</td></tr>'
              + '<tr><td>@updatedCount</td><td>'    + STR( @updatedCount, 8 )    + '</td></tr>'
              + '</table></br></br>'
         WHERE  @errorMessage LIKE '%Control Total Failure%' ;
        SELECT  @errorData = ISNULL( @errorData, '' ) + @errorDataTemp
         WHERE  @errorDataTemp IS NOT NULL ;


        SELECT  @errorDataTemp = '<b>Records to be inserted</b></br></br>'
              + '<table border="1">'
              + '<tr><th>IssueID</th><th>FirmID</th><th>PurchasePrice</th><th>TICPercent</th>'
              + '<th>NICPercent</th><th>NICAmount</th><th>BABTICPercent</th>'
              + '<th>HasWinningBid</th><th>IsRecoveryAct</th></tr>'
              + CAST ( ( SELECT  td= IssueID       , ''
                               , td= FirmID        , ''
                               , td= PurchasePrice , ''
                               , td= TICPercent    , ''
                               , td= NICPercent    , ''
                               , td= NICAmount     , ''
                               , td= BABTICPercent , ''
                               , td= HasWinningBid , ''
                               , td= IsRecoveryAct , ''
                           FROM  Conversion.vw_LegacyBidders AS lgb
                          WHERE  NOT EXISTS ( SELECT 1 FROM dbo.Bidder AS bid
                                               WHERE bid.IssueID = lgb.IssueID AND bid.FirmID = lgb.FirmID )
                          ORDER  BY 1, 3
                            FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
              + '</table></br></br>' ;
        SELECT  @errorData = ISNULL( @errorData, '' ) + @errorDataTemp
         WHERE  @errorDataTemp IS NOT NULL ;


          WITH  changedData AS (
                SELECT  IssueID, FirmID, PurchasePrice, TICPercent, NICPercent, NICAmount, BABTICPercent, HasWinningBid, IsRecoveryAct
                  FROM  Conversion.vw_LegacyBidders AS lgb
                 WHERE  EXISTS ( SELECT 1 FROM dbo.Bidder AS bid WHERE bid.IssueID = lgb.IssueID AND bid.FirmID = lgb.FirmID )
                    EXCEPT
                SELECT  IssueID, FirmID, BidPrice, TICPercent, NICPercent, NICAmount, BABTICPercent, HasWinningBid, IsRecoveryAct
                  FROM  dbo.Bidder )

        SELECT  @errorDataTemp = '<b>Records to be updated</b></br></br>'
              + '<table border="1">'
              + '<tr><th>IssueID</th><th>FirmID</th><th>PurchasePrice</th><th>TICPercent</th>'
              + '<th>NICPercent</th><th>NICAmount</th><th>BABTICPercent</th>'
              + '<th>HasWinningBid</th><th>IsRecoveryAct</th></tr>'
              + CAST ( ( SELECT  td= IssueID       , ''
                               , td= FirmID        , ''
                               , td= PurchasePrice , ''
                               , td= TICPercent    , ''
                               , td= NICPercent    , ''
                               , td= NICAmount     , ''
                               , td= BABTICPercent , ''
                               , td= HasWinningBid , ''
                               , td= IsRecoveryAct , ''
                           FROM  changedData
                          ORDER  BY 1, 3
                            FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
              + '</table></br></br>' ;
        SELECT  @errorData = ISNULL( @errorData, '' ) + @errorDataTemp
         WHERE  @errorDataTemp IS NOT NULL ;


          WITH  dropped AS (
                SELECT IssueID, FirmID FROM dbo.Bidder
                    EXCEPT
                SELECT IssueID, FirmID FROM Conversion.vw_LegacyBidders )

        SELECT  @errorDataTemp = '<b>Records to be deleted</b></br></br>'
                               + '<table border="1">'
                               + '<tr><th>IssueID</th><th>FirmID</th></tr>'
                               + CAST ( ( SELECT  td= IssueID   , ''
                                                , td= FirmID    , ''
                                            FROM  dropped
                                           ORDER  BY 1, 3
                                             FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
                               + '</table></br></br>' ;
        SELECT  @errorData = ISNULL( @errorData, '' ) + @errorDataTemp
         WHERE  @errorDataTemp IS NOT NULL ;


        EXECUTE dbo.processEhlersError  @errorTypeID
                                      , @codeBlockNum
                                      , @codeBlockDesc
                                      , @errorNumber
                                      , @errorSeverity
                                      , @errorState
                                      , @errorProcedure
                                      , @errorLine
                                      , @errorMessage
                                      , @errorData ;

        SELECT  @formattedErrorMessage = N'Error occurred in Code Block %d, %s ' + CHAR(13)
                                       + N'Error %d, Level %d, State %d, Procedure %s, Line %d, Message: %s ' ;

        RAISERROR( @formattedErrorMessage, @errorSeverity, @codeBlockNum
                 , @codeBlockNum
                 , @codeBlockDesc
                 , @errorNumber
                 , @errorSeverity
                 , @errorState
                 , @errorProcedure
                 , @errorLine
                 , @errorMessage ) ;
    END
        ELSE
    BEGIN
        SELECT  @errorMessage   = ERROR_MESSAGE()
              , @errorSeverity  = ERROR_SEVERITY()
              , @errorState     = ERROR_STATE()

        RAISERROR( @errorMessage, @errorSeverity, @errorState ) ;
    END

    RETURN 16 ;

END CATCH
END
