CREATE PROCEDURE Conversion.processFirmCategories
AS
/*
************************************************************************************************************************************

  Procedure:  Conversion.processFirmCategories
     Author:  Chris Carson
    Purpose:  converts legacy FirmCategories column on edata.dbo.Firms


    revisor         date                description
    ---------       ----------          ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  SET CONTEXT_INFO prevents related converted tables from firing triggers caused by changes from proc
    2)  SELECT inital control counts
    3)  Test for changes with CHECKSUMs, exit proc if there are none
    4)  INSERT new FirmCategories into @changedFirmCategories
    5)  INSERT dropped FirmCategories into @changedFirmCategories ( these become inactive on dbo.FirmCategories )
    6)  MERGE @changedFirmCategories into dbo.FirmCategories table
    7)  SELECT control counts and validate
    8)  Reset CONTEXT_INFO to re-enable triggering on converted tables
    9)  Print control totals

   Notes:

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;


    DECLARE @processName            AS VARCHAR (100)    = 'processFirmCategories'
          , @errorMessage           AS VARCHAR (MAX)    = NULL
          , @errorQuery             AS VARCHAR (MAX)    = NULL
          , @processFirmCategories  AS VARBINARY (128)  = CAST( 'processFirmCategories' AS VARBINARY(128) )
          , @processStartTime       AS DATETIME         = GETDATE()
          , @processEndTime         AS DATETIME         = NULL
          , @processElapsedTime     AS INT              = 0 ;


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
          , @recordUPDATEs          AS INT = 0 ;


    DECLARE @changedFirmCategories  AS TABLE ( FirmID           INT
                                             , FirmCategoryID   INT
                                             , Active           BIT ) ;


    DECLARE @mergeResults           AS TABLE ( Action   NVARCHAR (10) ) ;


--  1)  SET CONTEXT_INFO prevents related converted tables from firing triggers caused by changes from proc
BEGIN TRY
    SET CONTEXT_INFO @processFirmCategories ;


--  2)  SELECT inital control counts
    SELECT  @legacyCount        = COUNT(*) FROM Conversion.tvf_ConvertedFirmCategories( 'Legacy' ) ;
    SELECT  @convertedCount     = COUNT(*) FROM Conversion.tvf_ConvertedFirmCategories( 'Converted' ) ;
    SELECT  @convertedActual    = @convertedCount ;


--  3)  Test for changes with CHECKSUMs, exit proc if there are none
    SELECT  @legacyChecksum     = CHECKSUM_AGG(CHECKSUM(*)) FROM Conversion.tvf_ConvertedFirmCategories ( 'Legacy' ) ;
    SELECT  @convertedChecksum  = CHECKSUM_AGG(CHECKSUM(*)) FROM Conversion.tvf_ConvertedFirmCategories ( 'Converted' ) ;

    IF  ( @legacyChecksum = @convertedChecksum )
        GOTO    endOfProc ;


--  4)  INSERT new FirmCategories into @changedFirmCategories
    INSERT  @changedFirmCategories ( FirmID, FirmCategoryID, Active )
    SELECT  FirmID, FirmCategoryID, 1
      FROM  Conversion.tvf_ConvertedFirmCategories ( 'Legacy' ) AS l
     WHERE  NOT EXISTS ( SELECT 1 FROM Conversion.tvf_ConvertedFirmCategories ( 'Converted' ) AS c
                          WHERE c.FirmID = l.FirmID AND c.FirmCategoryID = l.FirmCategoryID ) ;
    SELECT  @newCount = @@ROWCOUNT ;


--  5)  INSERT dropped FirmCategories into @changedFirmCategories ( these become inactive on dbo.FirmCategories )
    INSERT  @changedFirmCategories ( FirmID, FirmCategoryID, Active )
    SELECT  FirmID, FirmCategoryID, 0
      FROM  Conversion.tvf_ConvertedFirmCategories ( 'Converted' ) AS c
     WHERE  NOT EXISTS ( SELECT 1 FROM Conversion.tvf_ConvertedFirmCategories ( 'Legacy' ) AS l
                          WHERE l.FirmID = c.FirmID AND l.FirmCategoryID = c.FirmCategoryID ) ;
    SELECT  @droppedCount = @@ROWCOUNT ;
    SELECT  @changesCount = @newCount + @droppedCount ;


--  6)  MERGE @changedFirmCategories into dbo.FirmCategories table
      WITH  changedData AS (
            SELECT  FirmID          = f.FirmID
                  , FirmCategoryID  = f.FirmCategoryID
                  , Active          = f.Active
                  , ModifiedDate    = ISNULL( l.ChangeDate, @processStartTime )
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


--  7)  SELECT control counts and validate
    SELECT  @recordINSERTs      = COUNT(*) FROM @mergeResults WHERE action = 'INSERT' ;
    SELECT  @recordUPDATEs      = COUNT(*) FROM @mergeResults WHERE action = 'UPDATE' ;
    SELECT  @convertedActual    = COUNT(*) FROM Conversion.tvf_ConvertedFirmCategories( 'Converted' ) ;

    IF  ( @convertedActual <> ( @convertedCount + @newCount - @droppedCount ) )
        OR
        ( @convertedActual <> @legacyCount )
        OR
        ( ( @newCount + @droppedCount ) <> ( @recordINSERTs + @recordUPDATEs ) )
        OR
        ( @changesCount <> @recordMERGEs )
        OR
        ( @recordMERGEs <> ( @newCount + @droppedCount ) )
    BEGIN
        PRINT 'Control Totals Error!  Please review counts and processing!' ;
        PRINT '' ;
        PRINT '@convertedActual = ' + STR( @convertedActual, 8 ) ;
        PRINT '@convertedCount  = ' + STR( @convertedCount, 8 ) ;
        PRINT '@newCount        = ' + STR( @newCount, 8 ) ;
        PRINT '@droppedCount    = ' + STR( @droppedCount, 8 ) ;
        PRINT '' ;
        PRINT '@convertedActual = ' + STR( @convertedActual, 8 ) ;
        PRINT '@legacyCount     = ' + STR( @legacyCount, 8 ) ;
        PRINT '' ;
        PRINT '@newCount        = ' + STR( @newCount, 8 ) ;
        PRINT '@droppedCount    = ' + STR( @droppedCount, 8 ) ;
        PRINT '@recordINSERTs   = ' + STR( @recordINSERTs, 8 ) ;
        PRINT '@recordUPDATEs   = ' + STR( @recordUPDATEs, 8 ) ;
        PRINT '' ;
        PRINT '@changesCount    = ' + STR( @changesCount, 8 ) ;
        PRINT '@recordMERGEs    = ' + STR( @recordMERGEs, 8 ) ;
        PRINT '' ;
        PRINT '@recordMERGEs    = ' + STR( @recordMERGEs, 8 ) ;
        PRINT '@newCount        = ' + STR( @newCount, 8 ) ;
        PRINT '@droppedCount    = ' + STR( @droppedCount, 8 ) ;
        PRINT '' ;
    END


END TRY
BEGIN CATCH
    EXECUTE dbo.processEhlersError ;
END CATCH


endOfProc:

--  8)  Reset CONTEXT_INFO to re-enable triggering on converted tables
    SET CONTEXT_INFO 0x0 ;


--  9)  Print control totals
    SELECT  @processEndTime     = GETDATE()
          , @processElapsedTime = DATEDIFF( ms, @processStartTime, @processEndTime ) ;

    PRINT   'Conversion.processFirmCategories CONTROL TOTALS ' ;
    PRINT   '' ;
    PRINT   'Firms on legacy system                  = ' + STR( @legacyCount, 8 ) ;
    PRINT   'Legacy Firm Categories                  = ' + STR( @legacyCount, 8 ) ;
    PRINT   '' ;
    PRINT   'Converted Firm Categories               = ' + STR( @convertedCount, 8 ) ;
    PRINT   '     + New categories                   = ' + STR( @newCount, 8 ) ;
    PRINT   '     - Dropped categories               = ' + STR( @droppedCount, 8 ) ;
    PRINT   '                                           ======= ' ;
    PRINT   'Total Firm Categories on new system     = ' + STR( @convertedActual, 8 ) ;
    PRINT   '' ;
    PRINT   '' ;
    PRINT   'Database Change Details ' ;
    PRINT   '' ;
    PRINT   'Required Changes to dbo.FirmCategories  = ' + STR( @changesCount, 8 ) ;
    PRINT   '     Total INSERTs dbo.FirmCategories   = ' + STR( @recordINSERTs, 8 ) ;
    PRINT   '     Total UPDATEs dbo.FirmCategories   = ' + STR( @recordUPDATEs, 8 ) ;
    PRINT   '' ;
    PRINT   'processFirmCategories START : ' + CONVERT( VARCHAR (30), @processStartTime, 121 ) ;
    PRINT   'processFirmCategories   END : ' + CONVERT( VARCHAR (30), @processEndTime, 121 ) ;
    PRINT   '               Elapsed Time : ' + CAST ( @processElapsedTime AS VARCHAR (20) ) + 'ms' ;


END