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
    1)  SET CONTEXT_INFO, inhibiting triggers when invoked
    2)  SELECT initial control counts
    3)  INSERT changed data into temp storage
    4)  Stop processing if there are no data changes
    5)  INSERT new data into temp storage
    6)  INSERT updated data into temp storage
    7)  MERGE temp storage into dbo.Firm
    8)  SELECT final control counts
    9)  Control Count Validation
   10)  Reset CONTEXT_INFO, allowing triggers to fire when invoked
   11)  Print control totals


    Notes:

************************************************************************************************************************************
*/
BEGIN
BEGIN TRY
    SET NOCOUNT ON ;


    DECLARE @fromConversion         AS VARBINARY (128)  = CAST( 'fromConversion' AS VARBINARY (128) ) ;
          , @processStartTime       AS VARCHAR (30)     = CONVERT( VARCHAR(30), GETDATE(), 121 )
          , @processEndTime         AS VARCHAR (30)     = NULL
          , @processElapsedTime     AS INT              = 0 ;


    DECLARE @codeBlockDesc01        AS SYSNAME  = 'SET CONTEXT_INFO, inhibiting triggers when invoked'
          , @codeBlockDesc02        AS SYSNAME  = 'SELECT initial control counts'
          , @codeBlockDesc03        AS SYSNAME  = 'INSERT changed data into temp storage'
          , @codeBlockDesc04        AS SYSNAME  = 'Stop processing if there are no data changes'
          , @codeBlockDesc05        AS SYSNAME  = 'INSERT new data into temp storage'
          , @codeBlockDesc06        AS SYSNAME  = 'INSERT updated data into temp storage'
          , @codeBlockDesc07        AS SYSNAME  = 'MERGE temp storage into dbo.Firm'
          , @codeBlockDesc08        AS SYSNAME  = 'SELECT final control counts'
          , @codeBlockDesc19        AS SYSNAME  = 'Control Total Validation'
          , @codeBlockDesc10        AS SYSNAME  = 'Reset CONTEXT_INFO, allowing triggers to fire when invoked'
          , @codeBlockDesc11        AS SYSNAME  = 'Print control totals' ;


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


    DECLARE @changesCount           AS INT  = 0
          , @convertedActual        AS INT  = 0
          , @convertedCount         AS INT  = 0
          , @legacyCount            AS INT  = 0
          , @newCount               AS INT  = 0
          , @recordUPDATEs          AS INT  = 0
          , @recordINSERTs          AS INT  = 0
          , @recordMERGEs           AS INT  = 0
          , @updatedCount           AS INT  = 0
          , @total                  AS INT  = 0 ;


    DECLARE @controlTotalsError     AS VARCHAR (200)    = N'Control Total Failure:  %s = %d, %s = %d' ;

    DECLARE @changedFirmData        AS TABLE ( FirmID               INT     NOT NULL    PRIMARY KEY CLUSTERED
                                             , Firm                 VARCHAR (125)
                                             , ShortName            VARCHAR (50)
                                             , FirmStatus           BIT
                                             , Phone                VARCHAR (20)
                                             , Fax                  VARCHAR (20)
                                             , TollFree             VARCHAR (20)
                                             , WebSite              VARCHAR (50)
                                             , GoodFaith            VARCHAR (MAX)
                                             , Notes                VARCHAR (MAX)
                                             , ChangeDate           DATETIME
                                             , ChangeBy             VARCHAR (50) ) ;

    DECLARE @changedFirmIDs         AS TABLE ( FirmID               INT     NOT NULL    PRIMARY KEY CLUSTERED
                                             , LegacyChecksum       VARBINARY (128)
                                             , ConvertedChecksum    VARBINARY (128) ) ;


    DECLARE @mergeResults           AS TABLE ( Action  NVARCHAR (10)
                                             , FirmID  INT ) ;


/**/SELECT  @codeBlockNum   = 01
/**/      , @codeBlockDesc  = @codeBlockDesc01 ; --  SET CONTEXT_INFO, inhibiting triggers when invoked

    SET CONTEXT_INFO @fromConversion ;


/**/SELECT  @codeBlockNum   = 02
/**/      , @codeBlockDesc  = @codeBlockDesc02 ; --  SELECT initial control counts

    SELECT  @legacyCount        = COUNT(*) FROM Conversion.vw_LegacyFirms ;
    SELECT  @convertedCount     = COUNT(*) FROM Conversion.vw_ConvertedFirms ;
    SELECT  @convertedActual    = @convertedCount ;


/**/SELECT  @codeBlockNum   = 03
/**/      , @codeBlockDesc  = @codeBlockDesc03 ; --  INSERT changed data into temp storage

    INSERT  @changedFirmIDs
    SELECT  FirmID            = l.FirmID
          , legacyChecksum    = l.FirmChecksum
          , convertedChecksum = c.FirmChecksum
      FROM  Conversion.tvf_FirmChecksum( 'Legacy' )    AS l
 LEFT JOIN  Conversion.tvf_FirmChecksum( 'Converted' ) AS c ON l.FirmID = c.FirmID
     WHERE  c.FirmChecksum IS NULL OR l.FirmChecksum <> c.FirmChecksum ;
    SELECT  @changesCount = @@ROWCOUNT ;


/**/SELECT  @codeBlockNum   = 04
/**/      , @codeBlockDesc  = @codeBlockDesc04 ; --  Stop processing if there are no data changes

    IF  @changesCount = 0 GOTO endOfProc ;


/**/SELECT  @codeBlockNum   = 05
/**/      , @codeBlockDesc  = @codeBlockDesc05 ; --  INSERT new data into temp storage

    INSERT  @changedFirmData
    SELECT  FirmID, Firm, ShortName
                , FirmStatus, Phone, Fax
                , TollFree, WebSite
                , GoodFaith, Notes
                , ChangeDate, ChangeBy
      FROM  Conversion.vw_LegacyFirms AS a
     WHERE  EXISTS ( SELECT 1 FROM @changedFirmIDs AS b
                      WHERE a.FirmID = b.FirmID AND b.convertedChecksum IS NULL ) ;
    SELECT  @newCount = @@ROWCOUNT ;


/**/SELECT  @codeBlockNum   = 06
/**/      , @codeBlockDesc  = @codeBlockDesc06 ; --  INSERT updated data into temp storage

    INSERT  @changedFirmData
    SELECT  FirmID, Firm, ShortName
                , FirmStatus, Phone, Fax
                , TollFree, WebSite
                , GoodFaith, Notes
                , ChangeDate, ChangeBy
      FROM  Conversion.vw_LegacyFirms AS a
     WHERE  EXISTS ( SELECT 1 FROM @changedFirmIDs AS b
                      WHERE a.FirmID = b.FirmID AND b.legacyChecksum <> b.convertedChecksum ) ;
    SELECT  @updatedCount = @@ROWCOUNT ;


/**/SELECT  @codeBlockNum   = 07
/**/      , @codeBlockDesc  = @codeBlockDesc07 ; --  MERGE temp storage into dbo.Firm

    BEGIN TRANSACTION ;

    SET IDENTITY_INSERT dbo.Firm ON ;

     MERGE  dbo.Firm            AS tgt
     USING  @changedFirmData    AS src ON tgt.FirmID = src.FirmID
      WHEN  MATCHED THEN
            UPDATE  SET   FirmName      = src.Firm
                        , ShortName     = src.ShortName
                        , Active        = src.FirmStatus
                        , FirmPhone     = src.Phone
                        , FirmTollFree  = src.TollFree
                        , FirmFax       = src.Fax
                        , FirmWebSite   = src.WebSite
                        , FirmNotes     = src.Notes
                        , GoodFaith     = src.GoodFaith
                        , ModifiedDate  = src.ChangeDate
                        , ModifiedUser  = src.ChangeBy
      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( FirmID, FirmName, ShortName, Active, FirmPhone, FirmTollFree, FirmFax
                        , FirmWebSite, FirmNotes, GoodFaith, ModifiedDate, ModifiedUser )
            VALUES ( src.FirmID, src.Firm, src.ShortName, src.FirmStatus, src.Phone, src.TollFree, src.Fax
                        , src.Website, src.Notes, src.GoodFaith, src.ChangeDate, src.ChangeBy )
    OUTPUT  $action, inserted.FirmID INTO @firmMergeResults ;
    SELECT  @recordMERGEs = @@ROWCOUNT ;

    SET IDENTITY_INSERT dbo.Firm OFF ;


/**/SELECT  @codeBlockNum   = 08
/**/      , @codeBlockDesc  = @codeBlockDesc08 ; --  SELECT final control counts

    SELECT  @recordINSERTs   = COUNT(*) FROM @mergeResults WHERE  Action = 'INSERT' ;
    SELECT  @recordUPDATEs   = COUNT(*) FROM @mergeResults WHERE  Action = 'UPDATE' ;
    SELECT  @convertedActual = COUNT(*) FROM Conversion.vw_ConvertedFirms ;


/**/SELECT  @codeBlockNum   = 09
/**/      , @codeBlockDesc  = @codeBlockDesc09 ; --  Control Total Validation

    SELECT @total =  @convertedCount + @recordINSERTs
    IF  ( @convertedActual <> ( @convertedCount + @recordINSERTs ) )
        RAISERROR( @controlTotalsError, 16, 1, 'Converted Firms', @convertedActual, 'Existing Firms + Inserted Firms', @total ) ;

    IF  ( @convertedActual <> @legacyCount )
        RAISERROR( @controlTotalsError, 16, 1, 'Converted Firms', @convertedActual, 'Legacy Firms', @legacyCount ) ;

    IF  ( @recordINSERTs <> @newCount )
        RAISERROR( @controlTotalsError, 16, 1, 'Inserted Firms', @recordINSERTs,  'Expected Inserts', @newCount ) ;

    IF  ( @recordUPDATEs <> @updatedCount )
        RAISERROR( @controlTotalsError, 16, 1, 'Updated Firms', @recordUPDATEs,  'Expected Updates', @updatedCount ) ;

    IF  ( @recordMERGEs <> @changesCount )
        RAISERROR( @controlTotalsError, 16, 1, 'Changed Firms', @recordMERGEs,  'Expected Changes', @changesCount ) ;


    COMMIT TRANSACTION ;


endOfProc:
/**/SELECT  @codeBlockNum   = 10
/**/      , @codeBlockDesc  = @codeBlockDesc10 ; --  Reset CONTEXT_INFO, allowing triggers to fire when invoked

    SET CONTEXT_INFO 0x0 ;


/**/SELECT  @codeBlockNum   = 11
/**/      , @codeBlockDesc  = @codeBlockDesc11 ; --  Print control totals

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
    RAISERROR( 'Database Change Details', 0, 0 ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( '     Total INSERTs dbo.Firm             = % 8d', 0, 0, @recordINSERTs ) ;
    RAISERROR( '     Total UPDATEs dbo.Firm             = % 8d', 0, 0, @recordUPDATEs ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( '     TOTAL changes on dbo.Firm          = % 8d', 0, 0, @recordMERGEs ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( 'processFirms START : %s', 0, 0, @processStartTime ) ;
    RAISERROR( 'processFirms   END : %s', 0, 0, @processEndTime ) ;
    RAISERROR( '      Elapsed Time : %d ms', 0, 0, @processElapsedTime ) ;

END TRY
BEGIN CATCH

    IF  @@TRANCOUNT > 0
        ROLLBACK TRANSACTION ;

    SELECT  @errorTypeID    = 1
          , @errorSeverity  = ERROR_SEVERITY()
          , @errorState     = ERROR_STATE()
          , @errorNumber    = ERROR_NUMBER()
          , @errorLine      = ERROR_LINE()
          , @errorProcedure = ISNULL( ERROR_PROCEDURE(), '-' )

    IF  @errorMessage IS NULL
    BEGIN
        SELECT  @errorMessage = N'Error occurred in Code Block %d, %s ' + CHAR(13)
                              + N'Error %d, Level %d, State %d, Procedure %s, Line %d, Message: ' + ERROR_MESSAGE() ;

        RAISERROR( @errorMessage, @errorSeverity, 1
                 , @codeBlockNum
                 , @codeBlockDesc
                 , @errorNumber
                 , @errorSeverity
                 , @errorState
                 , @errorProcedure
                 , @errorLine ) ;

        SELECT  @errorMessage = ERROR_MESSAGE() ;

        IF  @codeBlockDesc = @codeBlockDesc08
            SELECT  @errorData = '<b>temp storage contents from processFirms procedure</b></br></br>'
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
                                            FROM  @changedFirmData
                                             FOR XML PATH('tr'), TYPE ) AS VARCHAR(MAX) )
                               + N'</table>' ;

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

    END
        ELSE
    BEGIN
        SELECT  @errorSeverity  = ERROR_SEVERITY()
              , @errorState     = ERROR_STATE()

        RAISERROR( @errorMessage, @errorSeverity, @errorState ) ;
    END

END CATCH
END
