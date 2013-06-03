CREATE PROCEDURE Meta.sampleProc
AS
/*
************************************************************************************************************************************

  Procedure:  <Schema>.<procedureName>
     Author:  <authorName>
    Purpose:  <one sentence description of procedure>


    revisor         date                description
    ---------       ----------          ----------------------------
    <revisor>       ###DATE###          created

    Logic Summary:
    1)  cut/paste values from

    Notes:
    *IF* you still need to describe what's going on in the proc add that commentary here
        If you can't explain your proc in a single sentence or can't explain each code block in a single sentence
        your code might benefit from refactoring...

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

/*  put control total variable declarations here */
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

/*  put common variable declarations here */
    DECLARE @processStartTime   AS VARCHAR (30)     = CONVERT( VARCHAR(30), GETDATE(), 121 )
          , @processEndTime     AS VARCHAR (30)     = NULL
          , @processElapsedTime AS INT              = 0 ;


/*  put code block descriptions here  */
    DECLARE @codeBlockNum       AS INT
          , @codeBlockDesc      AS SYSNAME
          , @codeBlockDesc01    AS SYSNAME  = N'each block of code gets a description'
          , @codeBlockDesc02    AS SYSNAME  = N'use a single phrase for each block'
          , @codeBlockDesc03    AS SYSNAME  = N'this assists in debugging and error processing'
          , @codeBlockDesc04    AS SYSNAME  = N'it also encourages discrete blocks of small code'
          , @codeBlockDesc05    AS SYSNAME  = N'sample control total validation'
          , @codeBlockDesc06    AS SYSNAME  = N'sample control total reporting' ;

/*  put program-specific variable declarations here     */
    DECLARE @currentID          AS INT
          , @maxNumberOfRecrods AS INT ;



/*  BEGIN CODE  */
/**/SELECT  @codeBlockNum   = 01, @codeBlockDesc  = @codeBlockDesc01 ; --  each block of code gets a description
    --  Add code here ( input validation )



/**/SELECT  @codeBlockNum   = 02, @codeBlockDesc  = @codeBlockDesc02 ; --  use a single phrase for each block
    --  Add code here



/**/SELECT  @codeBlockNum   = 05, @codeBlockDesc  = @codeBlockDesc05 ; --  use a single phrase for each block
    --  Add code here ( validate control totals )
    IF  @convertedActual <> @legacyCount
        RAISERROR( @controlTotalsError, 16, 1, 'Converted Firms', @convertedActual, 'Legacy Firms', @legacyCount ) ;

    SELECT @total =  @convertedCount + @newCount
    IF  @convertedActual <> @total
        RAISERROR( @controlTotalsError, 16, 1, 'Converted Firms', @convertedActual, 'Existing Firms + New Firms', @total ) ;



endOfProc:
/**/SELECT  @codeBlockNum   = 06, @codeBlockDesc = @codeBlockDesc06 ; --  Print control totals sample
    SELECT  @processEndTime     = CONVERT( VARCHAR(30), GETDATE(), 121 )
          , @processElapsedTime = DATEDIFF( ms, CAST( @processStartTime AS DATETIME ), CAST( @processEndTime AS DATETIME ) ) ;

    RAISERROR( 'Meta.sampleProc CONTROL TOTALS ', 0, 0 ) ;
    RAISERROR( 'records on legacy system                = % 8d', 0, 0, @legacyCount ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( 'Existing records on converted system    = % 8d', 0, 0, @convertedCount ) ;
    RAISERROR( '     + new records                      = % 8d', 0, 0, @newCount ) ;
    RAISERROR( '                                           ======= ', 0, 0 ) ;
    RAISERROR( 'Total Records on converted system         = % 8d', 0, 0, @convertedActual ) ;
    RAISERROR( 'Changed records already counted         = % 8d', 0, 0, @updatedCount ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( 'sampleProc START : %s', 0, 0, @processStartTime ) ;
    RAISERROR( 'sampleProc   END : %s', 0, 0, @processEndTime ) ;
    RAISERROR( '    Elapsed Time : %d ms', 0, 0, @processElapsedTime ) ;

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

/*      SELECT relevant data into @errorDataTemp and add it into @errorData
        This is the data that you receive in case of a system errore so you
        want to ensure you are passing enough data to help with debugging errors    
        
        Here is sample code to SELECT data and format it in HTML for the error handling program
*/

/*
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

         */
         

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
