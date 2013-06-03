CREATE PROCEDURE Conversion.processFirms
AS
/*
************************************************************************************************************************************

  Procedure:  Conversion.processFirms
     Author:  Chris Carson
    Purpose:  converts legacy Firms data


    revisor         date                description
    ---------       ----------          ----------------------------
    ccarson         2013-01-24          created
    ccarson         ###DATE###          revised error reporting

    Logic Summary:

    1)  SET CONTEXT_INFO to prevent conversion from firing triggers
    2)  SELECT initial control counts
    3)  INSERT new Firms data into dbo.Firm
    4)  UPDATE dbo.Firm with changed data
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
          , @codeBlockDesc01    AS SYSNAME = 'SET CONTEXT_INFO to prevent conversion from firing triggers'
          , @codeBlockDesc02    AS SYSNAME = 'SELECT initial control counts'
          , @codeBlockDesc03    AS SYSNAME = 'INSERT new Firms data into dbo.Firm'
          , @codeBlockDesc04    AS SYSNAME = 'UPDATE dbo.Firm with changed data'
          , @codeBlockDesc05    AS SYSNAME = 'SELECT final control counts'
          , @codeBlockDesc06    AS SYSNAME = 'Validate control totals'
          , @codeBlockDesc07    AS SYSNAME = 'Print control totals' ;



    DECLARE @changesCount       AS INT  = 0
          , @convertedActual    AS INT  = 0
          , @convertedCount     AS INT  = 0
          , @legacyCount        AS INT  = 0
          , @newCount           AS INT  = 0
          , @recordUPDATEs      AS INT  = 0
          , @recordINSERTs      AS INT  = 0
          , @recordMERGEs       AS INT  = 0
          , @updatedCount       AS INT  = 0
          , @total              AS INT  = 0 ;



/**/SELECT  @codeBlockNum = 01, @codeBlockDesc = @codeBlockDesc01 ; --  SET CONTEXT_INFO to prevent conversion from firing triggers
    SET CONTEXT_INFO @fromConversion ;



/**/SELECT  @codeBlockNum = 02, @codeBlockDesc = @codeBlockDesc02 ; --  SELECT initial control counts
    SELECT  @legacyCount        = COUNT(*) FROM Conversion.vw_LegacyFirms ;
    SELECT  @convertedCount     = COUNT(*) FROM Conversion.vw_ConvertedFirms ;
    SELECT  @convertedActual    = @convertedCount ;



/**/SELECT  @codeBlockNum = 03, @codeBlockDesc = @codeBlockDesc03 ; --  INSERT new Firms data into dbo.Firm
    SET IDENTITY_INSERT dbo.Firm ON ;

    INSERT  dbo.Firm ( FirmID, FirmName, ShortName, Active, FirmPhone, FirmTollFree, FirmFax
                             , FirmWebSite, FirmNotes, GoodFaith, ModifiedDate, ModifiedUser )
    SELECT  FirmID          = FirmID
          , FirmName        = Firm
          , ShortName       = ShortName
          , Active          = FirmStatus
          , FirmPhone       = Phone
          , FirmTollFree    = TollFree
          , FirmFax         = Fax
          , FirmWebSite     = WebSite
          , FirmNotes       = Notes
          , GoodFaith       = GoodFaith
          , ModifiedDate    = ChangeDate
          , ModifiedUser    = ChangeBy
      FROM  Conversion.vw_LegacyFirms
     WHERE  FirmID NOT IN ( SELECT FirmID FROM dbo.Firm ) ;
    SELECT  @newCount = @@ROWCOUNT ;

    SET IDENTITY_INSERT dbo.Firm OFF ;



/**/SELECT  @codeBlockNum = 04, @codeBlockDesc = @codeBlockDesc04 ; --  UPDATE dbo.Firm with changed data
      WITH  changedFirms AS (
            SELECT  l.FirmID
              FROM  Conversion.tvf_FirmChecksum( 'Legacy' )     AS l
        INNER JOIN  Conversion.tvf_FirmChecksum( 'Converted' ) AS c ON c.FirmID = l.FirmID
             WHERE  l.FirmChecksum <> c.FirmChecksum ) ,

            changedData AS (
            SELECT  TOP 100 PERCENT
                    FirmID, Firm, ShortName, FirmStatus, Phone, TollFree
                        , Fax, WebSite, Notes, GoodFaith, ChangeDate, ChangeBy
              FROM  Conversion.vw_LegacyFirms
             WHERE  FirmID IN ( SELECT FirmID FROM changedFirms )
             ORDER  BY FirmID )

     MERGE  dbo.Firm    AS tgt
     USING  changedData AS src ON src.FirmID = tgt.FirmID
      WHEN  MATCHED THEN
            UPDATE   SET  FirmName      = src.Firm
                        , ShortName     = src.ShortName
                        , Active        = src.FirmStatus
                        , FirmPhone     = src.Phone
                        , FirmTollFree  = src.TollFree
                        , FirmFax       = src.Fax
                        , FirmWebSite   = src.WebSite
                        , FirmNotes     = src.Notes
                        , GoodFaith     = src.GoodFaith
                        , ModifiedDate  = src.ChangeDate
                        , ModifiedUser  = src.ChangeBy ;
    SELECT  @updatedCount = @@ROWCOUNT ;



/**/SELECT  @codeBlockNum = 05, @codeBlockDesc = @codeBlockDesc05 ; --  SELECT final control counts
    SELECT  @convertedActual = COUNT(*) FROM Conversion.vw_ConvertedFirms ;



/**/SELECT  @codeBlockNum = 06, @codeBlockDesc = @codeBlockDesc06 ; --  Validate control totals
    IF  @convertedActual <> @legacyCount
        RAISERROR( @controlTotalsError, 16, 1, 'Converted Firms', @convertedActual, 'Legacy Firms', @legacyCount ) ;

    SELECT @total =  @convertedCount + @newCount
    IF  @convertedActual <> @total
        RAISERROR( @controlTotalsError, 16, 1, 'Converted Firms', @convertedActual, 'Existing Firms + New Firms', @total ) ;



endOfProc:
/**/SELECT  @codeBlockNum = 07, @codeBlockDesc = @codeBlockDesc07 ; --  Print control totals
    SELECT  @processEndTime     = CONVERT( VARCHAR(30), GETDATE(), 121 )
          , @processElapsedTime = DATEDIFF( ms, CAST( @processStartTime AS DATETIME ), CAST( @processEndTime AS DATETIME ) ) ;

    RAISERROR( 'Conversion.processFirms CONTROL TOTALS ', 0, 0 ) ;
    RAISERROR( 'Firms on legacy system                  = % 8d', 0, 0, @legacyCount ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( 'Existing Firms on converted system      = % 8d', 0, 0, @convertedCount ) ;
    RAISERROR( '     + new records                      = % 8d', 0, 0, @newCount ) ;
    RAISERROR( '                                           ======= ', 0, 0 ) ;
    RAISERROR( 'Total Firms on converted system         = % 8d', 0, 0, @convertedActual ) ;
    RAISERROR( 'Changed records already counted         = % 8d', 0, 0, @updatedCount ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( 'processFirms START : %s', 0, 0, @processStartTime ) ;
    RAISERROR( 'processFirms   END : %s', 0, 0, @processEndTime ) ;
    RAISERROR( '      Elapsed Time : %d ms', 0, 0, @processElapsedTime ) ;

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
              + '<tr><td>@convertedActual</td><td>' + STR( @convertedActual, 8 ) + '</td></tr>'
              + '<tr><td>@updatedCount</td><td>'    + STR( @updatedCount, 8 )    + '</td></tr>'
              + '<tr><td></td><td></td></tr>'
              + '</table></br></br>'
         WHERE  @errorMessage LIKE '%Control Total Failure%' ;
        SELECT  @errorData = ISNULL( @errorData, '' ) + @errorDataTemp
         WHERE  @errorDataTemp IS NOT NULL ;


        SELECT  @errorDataTemp = '<b>Records to be inserted</b></br></br>'
              + '<table border="1">'
              + '<tr><th>FirmID</th><th>Firm</th><th>ShortName</th><th>FirmStatus</th>'
              + '<th>Phone</th><th>Fax</th><th>TollFree</th><th>WebSite</th><th>GoodFaith</th>'
              + '<th>Notes</th><th>ChangeDate</th><th>ChangeBy</th></tr>'
              + CAST ( ( SELECT  td = FirmID, ''
                              ,  td = Firm, ''
                              ,  td = ShortName, ''
                              ,  td = FirmStatus, ''
                              ,  td = Phone, ''
                              ,  td = Fax, ''
                              ,  td = TollFree, ''
                              ,  td = WebSite, ''
                              ,  td = GoodFaith, ''
                              ,  td = Notes, ''
                              ,  td = ChangeDate, ''
                              ,  td = ChangeBy, ''
                           FROM  Conversion.vw_LegacyFirms
                          WHERE  FirmID NOT IN ( SELECT FirmID FROM dbo.Firm )
                          ORDER  BY 1
                            FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
              + '</table></br></br>' ;
        SELECT  @errorData = ISNULL( @errorData, '' ) + @errorDataTemp
         WHERE  @errorDataTemp IS NOT NULL ;


          WITH  changedFirms AS (
                SELECT  l.FirmID
                  FROM  Conversion.tvf_FirmChecksum( 'Legacy' )     AS l
            INNER JOIN  Conversion.tvf_FirmChecksum( 'Converted' )  AS c ON c.FirmID = l.FirmID
                 WHERE  l.FirmChecksum <> c.FirmChecksum )

        SELECT  @errorDataTemp = '<b>Records to be updated</b></br></br>'
              + '<table border="1">'
              + '<tr><th>FirmID</th><th>Firm</th><th>ShortName</th><th>FirmStatus</th>'
              + '<th>Phone</th><th>Fax</th><th>TollFree</th><th>WebSite</th><th>GoodFaith</th>'
              + '<th>Notes</th><th>ChangeDate</th><th>ChangeBy</th></tr>'
              + CAST ( ( SELECT  td = FirmID, ''
                              ,  td = Firm, ''
                              ,  td = ShortName, ''
                              ,  td = FirmStatus, ''
                              ,  td = Phone, ''
                              ,  td = Fax, ''
                              ,  td = TollFree, ''
                              ,  td = WebSite, ''
                              ,  td = GoodFaith, ''
                              ,  td = Notes, ''
                              ,  td = ChangeDate, ''
                              ,  td = ChangeBy, ''
                           FROM  Conversion.vw_LegacyFirms
                          WHERE  FirmID IN ( SELECT FirmID FROM changedFirms )
                          ORDER  BY 1
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
