CREATE PROCEDURE Conversion.processClientCPAs
AS
/*
************************************************************************************************************************************

  Procedure:  Conversion.processClientCPAs
     Author:  Chris Carson
    Purpose:  converts legacy ClientCPA data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created
    ccarson         ###DATE###          revised error reporting

    Logic Summary:
    1)  SET CONTEXT_INFO to prevent conversion from firing triggers
    2)  SELECT initial control counts
    3)  MERGE changed legacy Client CPA data into dbo.ClientFirms
    4)  SELECT final control counts
    5)  Validate control totals
    6)  Print control totals


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

    DECLARE @controlTotalsError     AS VARCHAR (200)    = N'Control Total Failure:  %s = %d, %s = %d' ;

    DECLARE @fromConversion         AS VARBINARY (128)  = CAST( 'fromConversion' AS VARBINARY(128) )
          , @processStartTime       AS VARCHAR (30)     = CONVERT( VARCHAR(30), GETDATE(), 121 )
          , @processEndTime         AS VARCHAR (30)     = NULL
          , @processElapsedTime     AS INT              = 0 ;

    DECLARE @codeBlockNum           AS INT
          , @codeBlockDesc          AS SYSNAME
          , @codeBlockDesc01        AS SYSNAME = 'SET CONTEXT_INFO to prevent conversion from firing triggers'
          , @codeBlockDesc02        AS SYSNAME = 'SELECT initial control counts'
          , @codeBlockDesc03        AS SYSNAME = 'MERGE changed legacy Client CPA data into dbo.ClientFirms'
          , @codeBlockDesc04        AS SYSNAME = 'SELECT final control counts'
          , @codeBlockDesc05        AS SYSNAME = 'Validate control totals'
          , @codeBlockDesc06        AS SYSNAME = 'Print control totals' ;



    DECLARE @convertedActual        AS INT = 0
          , @convertedCount         AS INT = 0
          , @droppedCount           AS INT = 0
          , @legacyCount            AS INT = 0
          , @newCount               AS INT = 0
          , @recordMERGEs           AS INT = 0
          , @total                  AS INT = 0 ;

    DECLARE @mergeResults           AS TABLE    ( Action NVARCHAR (10) ) ;



/**/SELECT  @codeBlockNum = 01, @codeBlockDesc = @codeBlockDesc01 ; -- SET CONTEXT_INFO to prevent conversion from firing triggers
    SET CONTEXT_INFO @fromConversion ;



/**/SELECT  @codeBlockNum = 02, @codeBlockDesc = @codeBlockDesc02 ; -- SELECT initial control counts
    SELECT  @legacyCount        = COUNT(*) FROM Conversion.tvf_ClientCPAs ( 'Legacy' ) WHERE  FirmCategoriesID <> 0 ;
    SELECT  @convertedCount     = COUNT(*) FROM Conversion.tvf_ClientCPAs ( 'Converted' ) ;
    SELECT  @convertedActual    = @convertedCount ;



/**/SELECT  @codeBlockNum = 03, @codeBlockDesc = @codeBlockDesc03 ; -- MERGE changed legacy Client CPA data into dbo.ClientFirms
      WITH  inserts AS (
            SELECT  ClientID, FirmCategoriesID FROM Conversion.tvf_ClientCPAs ( 'Legacy' )
             WHERE  FirmCategoriesID <> 0
                EXCEPT
            SELECT  ClientID, FirmCategoriesID FROM Conversion.tvf_ClientCPAs ( 'Converted' ) ) ,

            newData AS (
            SELECT  ClientID            = ins.ClientID
                  , FirmCategoriesID    = ins.FirmCategoriesID
                  , ModifiedDate        = cli.ChangeDate
                  , ModifiedUser        = ISNULL( NULLIF( cli.ChangeBy, 'processClients' ), 'processClientCPAs' )
              FROM  inserts                         AS ins
        INNER JOIN  Conversion.vw_LegacyClients     AS cli ON cli.ClientID = ins.ClientID ) ,

            deletes AS (
            SELECT  ClientID, FirmCategoriesID FROM Conversion.tvf_ClientCPAs ( 'Converted' )
                EXCEPT
            SELECT  ClientID, FirmCategoriesID FROM Conversion.tvf_ClientCPAs ( 'Legacy' )
             WHERE  FirmCategoriesID <> 0 ) ,

            clients AS (
            SELECT  ClientID FROM inserts
                UNION
            SELECT  ClientID FROM deletes ) ,

            firmCategories AS (
            SELECT  FirmCategoriesID FROM dbo.FirmCategories
             WHERE  FirmCategoryID IN ( SELECT FirmCategoryID FROM dbo.FirmCategory
                                         WHERE LegacyValue = 'CCPA' ) ) ,

            clientCPAs AS (
            SELECT * FROM dbo.ClientFirms
             WHERE  ClientID IN ( SELECT ClientID FROM clients )
               AND  FirmCategoriesID IN ( SELECT FirmCategoriesID FROM firmCategories ) )

     MERGE  clientCPAs  AS tgt
     USING  newData     AS src ON src.ClientID = tgt.ClientID AND src.FirmCategoriesID = tgt.FirmCategoriesID
      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( ClientID, FirmCategoriesID, ModifiedDate, ModifiedUser )
            VALUES ( src.ClientID, src.FirmCategoriesID, src.ModifiedDate, src.ModifiedUser )

      WHEN  NOT MATCHED BY SOURCE THEN
            DELETE

    OUTPUT  $action INTO @mergeResults ( Action ) ;
    SELECT  @recordMERGEs = @@ROWCOUNT ;



/**/SELECT  @codeBlockNum = 04, @codeBlockDesc = @codeBlockDesc04 ; -- SELECT final control counts
    SELECT  @convertedActual    = COUNT(*) FROM Conversion.tvf_ClientCPAs ( 'Converted' ) ;
    SELECT  @newCount           = COUNT(*) FROM @mergeResults WHERE Action = 'INSERT' ;
    SELECT  @droppedCount       = COUNT(*) FROM @mergeResults WHERE Action = 'DELETE' ;




/**/SELECT  @codeBlockNum = 05, @codeBlockDesc = @codeBlockDesc05 ; -- Validate control totals
    IF  @convertedActual <> @legacyCount
        RAISERROR( @controlTotalsError, 16, 1, 'Converted ClientCPAs', @convertedActual, 'Legacy ClientCPAs', @legacyCount ) ;

    SELECT @total =  @convertedCount + @newCount - @droppedCount ;
    IF  @convertedActual <> @total
        RAISERROR( @controlTotalsError, 16, 1, 'Converted ClientCPAs', @convertedActual, 'Existing Records + Changes', @total ) ;



endOfProc:
/**/SELECT  @codeBlockNum = 06, @codeBlockDesc = @codeBlockDesc06 ; -- Print control totals
    SELECT  @processEndTime     = CONVERT( VARCHAR(30), GETDATE(), 121 )
          , @processElapsedTime = DATEDIFF( ms, CAST( @processStartTime AS DATETIME ), CAST( @processEndTime AS DATETIME ) ) ;

    RAISERROR( 'Conversion.processClientCPAs CONTROL TOTALS ', 0, 0 ) ;
    RAISERROR( 'ClientCPAs listed in legacy system          = % 8d', 0, 0, @legacyCount ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( 'ClientCPAs existing in converted system     = % 8d', 0, 0, @convertedCount ) ;
    RAISERROR( '     + new records                          = % 8d', 0, 0, @newCount ) ;
    RAISERROR( '     - dropped records                      = % 8d', 0, 0, @droppedCount ) ;
    RAISERROR( '                                               ======= ', 0, 0 ) ;
    RAISERROR( 'Total ClientCPAs on converted system        = % 8d', 0, 0, @convertedActual ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( 'processClientCPAs START : %s', 0, 0, @processStartTime ) ;
    RAISERROR( 'processClientCPAs   END : %s', 0, 0, @processEndTime ) ;
    RAISERROR( '           Elapsed Time : %d ms', 0, 0, @processElapsedTime ) ;


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
              + '<tr><td>@legacyCount</td><td>'     + STR( @legacyCount, 8 )        + '</td></tr>'
              + '<tr><td>@convertedCount</td><td>'  + STR( @convertedCount, 8 )     + '</td></tr>'
              + '<tr><td>@newCount</td><td>'        + STR( @newCount, 8 )           + '</td></tr>'
              + '<tr><td>@droppedCount</td><td>'    + STR( @droppedCount, 8 )       + '</td></tr>'
              + '<tr><td>@convertedActual</td><td>' + STR( @convertedActual, 8 )    + '</td></tr>'
              + '</table></br></br>'
         WHERE  @errorMessage LIKE '%Control Total Failure%' ;
        SELECT  @errorData = ISNULL( @errorData, '' ) + @errorDataTemp
         WHERE  @errorDataTemp IS NOT NULL ;


          WITH  inserts AS (
                SELECT  ClientID, ClientCPA, ClientCPAFirmID, FirmCategoriesID FROM Conversion.tvf_ClientCPAs ( 'Legacy' )
                 WHERE  FirmCategoriesID <> 0
                    EXCEPT
                SELECT  ClientID, ClientCPA, ClientCPAFirmID, FirmCategoriesID FROM Conversion.tvf_ClientCPAs ( 'Converted' ) )

        SELECT  @errorDataTemp = '<b>Records to be inserted</b></br></br>'
              + '<table border="1">'
              + '<tr><th>ClientID</th><th>ClientCPA</th><th>ClientCPAFirmID</th><th>FirmCategoriesID</th>'
              + '<th>ModifiedDate</th><th>ModifiedUser</th></tr>'
              + CAST ( ( SELECT  td = ins.ClientID          , ''
                              ,  td = ins.ClientCPA         , ''
                              ,  td = ins.ClientCPAFirmID   , ''
                              ,  td = ins.FirmCategoriesID  , ''
                              ,  td = cli.ChangeDate        , ''
                              ,  td = ISNULL( NULLIF( cli.ChangeBy, 'processClients' ), 'processClientCPAs' ), ''
                           FROM  inserts AS ins
                     INNER JOIN  Conversion.vw_LegacyClients AS cli ON cli.ClientID = ins.ClientID
                          ORDER  BY 3, 1
                            FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
              + '</table></br></br>' ;
        SELECT  @errorData = ISNULL( @errorData, '' ) + @errorDataTemp
         WHERE  @errorDataTemp IS NOT NULL ;


          WITH  deletes AS (
                SELECT  ClientID, ClientCPA, ClientCPAFirmID, FirmCategoriesID FROM Conversion.tvf_ClientCPAs ( 'Converted' )
                    EXCEPT
                SELECT  ClientID, ClientCPA, ClientCPAFirmID, FirmCategoriesID FROM Conversion.tvf_ClientCPAs ( 'Legacy' )
                 WHERE  FirmCategoriesID <> 0 )

        SELECT  @errorDataTemp = '<b>Records to be deleted</b></br></br>'
              + '<table border="1">'
              + '<tr><th>ClientID</th><th>ClientCPA</th><th>ClientCPAFirmID</th><th>FirmCategoriesID</th></tr>'
              + CAST ( ( SELECT  td = ClientID          , ''
                              ,  td = ClientCPA         , ''
                              ,  td = ClientCPAFirmID   , ''
                              ,  td = FirmCategoriesID  , ''
                           FROM  deletes AS del
                          ORDER  BY 3, 1
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
