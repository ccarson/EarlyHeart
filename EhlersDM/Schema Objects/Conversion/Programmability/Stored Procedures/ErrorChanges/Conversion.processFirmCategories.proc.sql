CREATE PROCEDURE Conversion.processFirmCategories
AS
/*
************************************************************************************************************************************

  Procedure:  Conversion.processFirmCategories
     Author:  Chris Carson
    Purpose:  converts legacy FirmCategories column on edata.Firms


    revisor         date                description
    ---------       ----------          ----------------------------
    ccarson         2013-01-24          created
    ccarson         ###DATE###          revised error reporting

    Logic Summary:
    1)  Validate input parameters
    2)  SET CONTEXT_INFO, inhibiting triggers when invoked
    3)  SELECT initial control counts
    4)  Exit process unless there are actual data changes
    5)  INSERT new FirmCategories into temp storage
    6)  INSERT dropped FirmCategories into temp storage
    7)  MERGE temp storage into dbo.FirmCategories
    8)  SELECT final control counts
    9)  Control Total Validation
   10)  Reset CONTEXT_INFO, allowing triggers to fire when invoked
   11)  Print control totals
    
   Notes:
        FirmCategory entries that are deleted from legacy are marked as Inactive on new system
   
************************************************************************************************************************************
*/
BEGIN
BEGIN TRY

    SET NOCOUNT ON ;


    DECLARE @processFirmCategories  AS VARBINARY (128)  = CAST( 'processFirmCategories' AS VARBINARY(128) )
          , @processStartTime       AS VARCHAR (30)     = CONVERT( VARCHAR(30), GETDATE(), 121 )
          , @processEndTime         AS VARCHAR (30)     = NULL
          , @processElapsedTime     AS INT              = 0 ;

    DECLARE @codeBlockDesc01        AS VARCHAR (128)    = 'Validate input parameters'
          , @codeBlockDesc02        AS VARCHAR (128)    = 'SET CONTEXT_INFO, inhibiting triggers when invoked'
          , @codeBlockDesc03        AS VARCHAR (128)    = 'SELECT initial control counts'
          , @codeBlockDesc04        AS VARCHAR (128)    = 'Exit process unless there are actual data changes'
          , @codeBlockDesc05        AS VARCHAR (128)    = 'INSERT new FirmCategories into temp storage'
          , @codeBlockDesc06        AS VARCHAR (128)    = 'INSERT dropped FirmCategories into temp storage'
          , @codeBlockDesc07        AS VARCHAR (128)    = 'MERGE temp storage into dbo.FirmCategories'
          , @codeBlockDesc08        AS VARCHAR (128)    = 'SELECT final control counts'
          , @codeBlockDesc09        AS VARCHAR (128)    = 'Control Total Validation'
          , @codeBlockDesc10        AS VARCHAR (128)    = 'Reset CONTEXT_INFO, allowing triggers to fire when invoked'
          , @codeBlockDesc11        AS VARCHAR (128)    = 'Print control totals' ; 


    DECLARE @codeBlockNum           AS INT
          , @codeBlockDesc          AS VARCHAR (128)
          , @errorTypeID            AS INT
          , @errorSeverity          AS INT
          , @errorState             AS INT
          , @errorNumber            AS INT
          , @errorLine              AS INT
          , @errorProcedure         AS VARCHAR (128)
          , @errorMessage           AS VARCHAR (MAX) = NULL
          , @errorData              AS VARCHAR (MAX) = NULL ;


    DECLARE @changesCount           AS INT = 0
          , @convertedActual        AS INT = 0
          , @convertedChecksum      AS INT = 0
          , @convertedCount         AS INT = 0
          , @droppedCount           AS INT = 0
          , @legacyChecksum         AS INT = 0
          , @legacyCount            AS INT = 0
          , @newCount               AS INT = 0
          , @recordINSERTs          AS INT = 0
          , @recordMERGEs           AS INT = 0
          , @recordUPDATEs          AS INT = 0
          , @total                  AS INT = 0 ;

    DECLARE @controlTotalsError     AS VARCHAR (200)    = N'Control Total Failure:  %s = %d, %s = %d' ;


    DECLARE @changedFirmCategories  AS TABLE ( FirmID           INT
                                             , FirmCategoryID   INT
                                             , Active           BIT ) ;


    DECLARE @mergeResults           AS TABLE ( Action   NVARCHAR (10) ) ;


/**/SELECT  @codeBlockNum   = 1
/**/      , @codeBlockDesc  = @codeBlockDesc01 ; -- Validate input parameters
--  No input validation



/**/SELECT  @codeBlockNum   = 2
/**/      , @codeBlockDesc  = @codeBlockDesc02 ; -- SET CONTEXT_INFO, inhibiting triggers when invoked
    SET CONTEXT_INFO @processFirmCategories ;



/**/SELECT  @codeBlockNum   = 3
/**/      , @codeBlockDesc  = @codeBlockDesc03 ; -- SELECT inital control counts
    SELECT  @legacyCount        = COUNT(*) FROM Conversion.tvf_ConvertedFirmCategories( 'Legacy' ) ;
    SELECT  @convertedCount     = COUNT(*) FROM Conversion.tvf_ConvertedFirmCategories( 'Converted' ) ;
    SELECT  @convertedActual    = @convertedCount ;



/**/SELECT  @codeBlockNum   = 4
/**/      , @codeBlockDesc  = @codeBlockDesc04 ; -- Exit process unless there are actual data changes
    SELECT  @legacyChecksum     = CHECKSUM_AGG(CHECKSUM(*)) FROM Conversion.tvf_ConvertedFirmCategories ( 'Legacy' ) ;
    SELECT  @convertedChecksum  = CHECKSUM_AGG(CHECKSUM(*)) FROM Conversion.tvf_ConvertedFirmCategories ( 'Converted' ) ;

    IF  ( @legacyChecksum = @convertedChecksum )
        GOTO    endOfProc ;



/**/SELECT  @codeBlockNum   = 5
/**/      , @codeBlockDesc  = @codeBlockDesc05 ; -- INSERT new FirmCategories into temp storage
    INSERT  @changedFirmCategories ( FirmID, FirmCategoryID, Active )
    SELECT  FirmID, FirmCategoryID, 1
      FROM  Conversion.tvf_ConvertedFirmCategories ( 'Legacy' ) AS l
     WHERE  NOT EXISTS ( SELECT 1 FROM Conversion.tvf_ConvertedFirmCategories ( 'Converted' ) AS c
                          WHERE c.FirmID = l.FirmID AND c.FirmCategoryID = l.FirmCategoryID ) ;
    SELECT  @newCount = @@ROWCOUNT ;



/**/SELECT  @codeBlockNum   = 6
/**/      , @codeBlockDesc  = @codeBlockDesc06 ; -- INSERT dropped FirmCategories into temp storage
    INSERT  @changedFirmCategories ( FirmID, FirmCategoryID, Active )
    SELECT  FirmID, FirmCategoryID, 0
      FROM  Conversion.tvf_ConvertedFirmCategories ( 'Converted' ) AS c
     WHERE  NOT EXISTS ( SELECT 1 FROM Conversion.tvf_ConvertedFirmCategories ( 'Legacy' ) AS l
                          WHERE l.FirmID = c.FirmID AND l.FirmCategoryID = c.FirmCategoryID ) ;
    SELECT  @droppedCount = @@ROWCOUNT ;
    SELECT  @changesCount = @newCount + @droppedCount ;



/**/SELECT  @codeBlockNum   = 7
/**/      , @codeBlockDesc  = @codeBlockDesc07 ; -- MERGE temp storage into dbo.FirmCategories

    BEGIN TRANSACTION ;

      WITH  changedData AS (
            SELECT  FirmID          = f.FirmID
                  , FirmCategoryID  = f.FirmCategoryID
                  , Active          = f.Active
                  , ModifiedDate    = ISNULL( l.ChangeDate, CAST( @processStartTime AS DATETIME ) )
                  , ModifiedUser    = ISNULL( NULLIF( l.ChangeBy, 'processFirms' ), 'FirmCategories' )
              FROM  @changedFirmCategories AS f
         LEFT JOIN  Conversion.vw_LegacyFirms AS l ON l.FirmID = f.FirmID )

     MERGE  dbo.FirmCategories  AS tgt
     USING  changedData         AS src ON tgt.FirmID = src.FirmID AND tgt.FirmCategoryID = src.FirmCategoryID
      WHEN  MATCHED THEN
            UPDATE SET  Active        = src.Active
                      , ModifiedDate  = src.ModifiedDate
                      , ModifiedUser  = src.ModifiedUser
      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( FirmID, FirmCategoryID, Active, ModifiedDate, ModifiedUser )
            VALUES ( src.FirmID, src.FirmCategoryID, src.Active, src.ModifiedDate, src.ModifiedUser )
    OUTPUT  $action INTO @mergeResults ;
    SELECT  @recordMERGEs = @@ROWCOUNT ;




/**/SELECT  @codeBlockNum   = 8
/**/      , @codeBlockDesc  = @codeBlockDesc08 ; -- SELECT final control counts
    SELECT  @recordINSERTs      = COUNT(*) FROM @mergeResults WHERE action = 'INSERT' ;
    SELECT  @recordUPDATEs      = COUNT(*) FROM @mergeResults WHERE action = 'UPDATE' ;
    SELECT  @convertedActual    = COUNT(*) FROM Conversion.tvf_ConvertedFirmCategories( 'Converted' ) ;



/**/SELECT  @codeBlockNum   = 9
/**/      , @codeBlockDesc  = @codeBlockDesc09 ; -- Control Total Validation

    SELECT  @total = @convertedCount + @newCount - @droppedCount ;
    IF  ( @convertedActual <> @total  )
        RAISERROR( @controlTotalsError, 16, 1, 'Converted Firm Categories', @convertedActual, 'Existing Firm Categories + Inserts - Deletes', @total ) ;

    IF  ( @convertedActual <> @legacyCount )
        RAISERROR( @controlTotalsError, 16, 1, 'Converted Firm Categories', @convertedActual, 'Legacy Firm Categories', @legacyCount ) ;

    IF  ( @recordINSERTs <> @newCount )
        RAISERROR( @controlTotalsError, 16, 1, 'Inserted Firm Categories', @recordINSERTs,  'Expected Inserts', @newCount ) ;

    IF  ( @recordUPDATEs <> @droppedCount )
        RAISERROR( @controlTotalsError, 16, 1, 'Dropped Firm Categories', @recordUPDATEs,  'Expected Drops', @droppedCount ) ;

    IF  ( @recordMERGEs <> @changesCount )
        RAISERROR( @controlTotalsError, 16, 1, 'Changed Firm Categories', @recordMERGEs,  'Expected Changes', @changesCount ) ;

    COMMIT TRANSACTION ;

        
endOfProc:
/**/SELECT  @codeBlockNum   = 10
/**/      , @codeBlockDesc  = @codeBlockDesc10 ; -- Reset CONTEXT_INFO, allowing triggers to fire when invoked
    SET CONTEXT_INFO 0x0 ;



/**/SELECT  @codeBlockNum   = 11
/**/      , @codeBlockDesc  = @codeBlockDesc11 ; -- Print control totals

    SELECT  @processEndTime     = CONVERT( VARCHAR(30), GETDATE(), 121 )
          , @processElapsedTime = DATEDIFF( ms, CAST( @processStartTime AS DATETIME ), CAST( @processEndTime AS DATETIME ) ) ;


    RAISERROR( 'Conversion.processFirmCategories CONTROL TOTALS ', 0, 0 ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( 'Legacy Firm Categories                  = % 8d', 0, 0, @legacyCount ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( 'Converted Firm Categories               = % 8d', 0, 0, @convertedCount ) ;
    RAISERROR( '     + New categories                   = % 8d', 0, 0, @newCount ) ;
    RAISERROR( '     - Dropped categories               = % 8d', 0, 0, @droppedCount ) ;
    RAISERROR( '                                           ======= ', 0, 0 ) ;
    RAISERROR( 'Total Firm Categories on new system     = % 8d', 0, 0, @convertedActual ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( 'Database Change Details ', 0, 0 ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( 'Required Changes to dbo.FirmCategories  = % 8d', 0, 0, @changesCount ) ;
    RAISERROR( '     Total INSERTs dbo.FirmCategories   = % 8d', 0, 0, @recordINSERTs ) ;
    RAISERROR( '     Total UPDATEs dbo.FirmCategories   = % 8d', 0, 0, @recordUPDATEs ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( 'processFirmCategories START : %s', 0, 0, @processStartTime ) ;
    RAISERROR( 'processFirmCategories   END : %s', 0, 0, @processEndTime ) ;
    RAISERROR( '               Elapsed Time : %d ms', 0, 0, @processElapsedTime ) ;


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

        IF  @codeBlockDesc = @codeBlockDesc07
            SELECT  @errorData = '<b>temp storage contents from processFirmCategories procedure</b></br></br>'
                               + '<table border="1">'
                               + '<tr><th>FirmID</th><th>FirmCategoryID</th><th>Active</th></tr>'
                               + CAST ( ( SELECT  td = FirmID, ''
                                               ,  td = FirmCategoryID, ''
                                               ,  td = Active, ''
                                            FROM  @changedFirmCategories
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
