CREATE PROCEDURE [Conversion].[processContactJobFunctions]
AS
/*
************************************************************************************************************************************

  Procedure:  Conversion.processContacts
     Author:  Chris Carson
    Purpose:  converts legacy Contacts data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Set CONTEXT_INFO to prevent converted tables from triggering changes
    2)  Create temp storage for changed data from source tables
    3)  SELECT initial control counts
    4)  Test for changes with CHECKSUMs, exit proc if there are none
    5)  INSERT new Job Functions into #jobFunctionData
    6)  INSERT dropped Job Functions into #jobFunctionData
    7)  UPDATE #jobFunctionData with Contact data
    8)  SELECT control counts
    9)  MERGE #jobFunctionData into dbo.ContactJobFunctions
   10)  UPDATE @jobFunctionMergeResults with LegacyTableName
   11)  SELECT control counts and validate
   12)  Reset CONTEXT_INFO to re-enable triggering on converted tables
   13)  Print control totals


    Notes:

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;


    DECLARE @rc                         AS INT             = 0
          , @processName                AS VARCHAR   (100) = 'processJobFunctions'
          , @processDate                AS DATETIME        = GETDATE()
          , @errorMessage               AS VARCHAR   (MAX) = NULL
          , @errorQuery                 AS VARCHAR   (MAX) = NULL
          , @processJobFunctions        AS VARBINARY (128) = CAST( 'processJobFunctions' AS varbinary (128) ) ;


    DECLARE @changesCount               AS INT = 0
          , @convertedActual            AS INT = 0
          , @convertedChecksum          AS INT = 0
          , @convertedClientActual      AS INT = 0
          , @convertedClientCount       AS INT = 0
          , @convertedCount             AS INT = 0
          , @convertedFirmActual        AS INT = 0
          , @convertedFirmCount         AS INT = 0
          , @droppedActual              AS INT = 0
          , @droppedClientActual        AS INT = 0
          , @droppedClientCount         AS INT = 0
          , @droppedCount               AS INT = 0
          , @droppedFirmActual          AS INT = 0
          , @droppedFirmCount           AS INT = 0
          , @legacyChecksum             AS INT = 0
          , @legacyClientCount          AS INT = 0
          , @legacyCount                AS INT = 0
          , @legacyFirmCount            AS INT = 0
          , @newActual                  AS INT = 0
          , @newClientActual            AS INT = 0
          , @newClientCount             AS INT = 0
          , @newCount                   AS INT = 0
          , @newFirmActual              AS INT = 0
          , @newFirmCount               AS INT = 0
          , @recordClientINSERTs        AS INT = 0
          , @recordClientUPDATEs        AS INT = 0
          , @recordFirmINSERTs          AS INT = 0
          , @recordFirmUPDATEs          AS INT = 0
          , @recordINSERTs              AS INT = 0
          , @recordMERGEs               AS INT = 0
          , @recordUPDATEs              AS INT = 0 ;


    DECLARE @jobFunctionMergeResults    AS TABLE( Action           NVARCHAR (10)
                                                , ContactID        INT
                                                , JobFunctionID    INT
                                                , Active           BIT
                                                , LegacyTableName  VARCHAR (20) ) ;


--  1)  Set CONTEXT_INFO to prevent converted tables from triggering changes
BEGIN TRY
    SET CONTEXT_INFO @processJobFunctions ;


--  2)  Create temp storage for changed data from source tables
    IF  OBJECT_ID ('tempdb..#jobFunctionData') IS NOT NULL
        DROP TABLE  #jobFunctionData ;
    CREATE TABLE    #jobFunctionData (
        ContactID           INT
      , JobFunctionID       INT
      , LegacyTableName     VARCHAR (50)
      , Active              BIT
      , ModifiedDate        DATETIME
      , ModifiedUser        VARCHAR (20) ) ;


--  3)  SELECT initial control counts
    SELECT  @legacyFirmCount = COUNT(*) FROM Conversion.tvf_ConvertedJobFunctions ( 'Legacy' )
     WHERE  LegacyTableName = 'FirmContacts' ;

    SELECT  @legacyClientCount = COUNT(*) FROM Conversion.tvf_ConvertedJobFunctions ( 'Legacy' )
     WHERE  LegacyTableName = 'ClientContacts' ;

    SELECT  @convertedFirmCount = COUNT(*) FROM Conversion.tvf_ConvertedJobFunctions ( 'Converted' )
     WHERE  LegacyTableName = 'FirmContacts' ;

    SELECT  @convertedClientCount = COUNT(*) FROM Conversion.tvf_ConvertedJobFunctions ( 'Converted' )
     WHERE  LegacyTableName = 'ClientContacts' ;

    SELECT  @legacyCount     = @legacyFirmCount    + @legacyClientCount
          , @convertedCount  = @convertedFirmCount + @convertedClientCount
          , @convertedActual = @legacyFirmCount    + @legacyClientCount ;


--  4)  Test for changes with CHECKSUMs, exit proc if there are none
    SELECT  @legacyChecksum     = CHECKSUM_AGG( CHECKSUM(*) ) FROM Conversion.tvf_ConvertedJobFunctions( 'Legacy' ) ;
    SELECT  @convertedChecksum  = CHECKSUM_AGG( CHECKSUM(*) ) FROM Conversion.tvf_ConvertedJobFunctions( 'Converted' ) ;

    IF  ( @legacyChecksum = @convertedChecksum )
    BEGIN
        PRINT   'no legacy Job Function changes, exiting' ;
        GOTO    endOfProc ;
    END

    PRINT 'migrating changed Job Functions data' ;


--  5)  INSERT new Job Functions into #jobFunctionData
      WITH  newRecords AS (
            SELECT ContactID, JobFunctionID, LegacyTableName FROM Conversion.tvf_ConvertedJobFunctions ( 'Legacy' )
                EXCEPT
            SELECT ContactID, JobFunctionID, LegacyTableName FROM Conversion.tvf_ConvertedJobFunctions ( 'Converted' ) )
    INSERT  #jobFunctionData ( ContactID, JobFunctionID, LegacyTableName, Active )
    SELECT  ContactID, JobFunctionID, LegacyTableName, 1
      FROM  newRecords ;


--  6)  INSERT dropped Job Functions into #jobFunctionData
      WITH  droppedRecords AS (
            SELECT ContactID, JobFunctionID, LegacyTableName FROM Conversion.tvf_ConvertedJobFunctions ( 'Converted' )
                EXCEPT
            SELECT ContactID, JobFunctionID, LegacyTableName FROM Conversion.tvf_ConvertedJobFunctions ( 'Legacy' ) )
    INSERT  #jobFunctionData ( ContactID, JobFunctionID, LegacyTableName, Active )
    SELECT  ContactID, JobFunctionID, LegacyTableName, 0
      FROM  droppedRecords ;


--  7)  UPDATE #jobFunctionData with Contact data
    UPDATE  #jobFunctionData
       SET  ModifiedDate = ChangeDate
          , ModifiedUser = ChangeBy
      FROM  #jobFunctionData             AS a
INNER JOIN  Conversion.vw_LegacyContacts AS b ON b.ContactID = a.ContactID ;


--  8)  SELECT control counts
    SELECT  @newFirmCount   = COUNT(*) FROM #jobFunctionData WHERE LegacyTableName = 'FirmContacts'   AND Active = 1 ;
    SELECT  @newClientCount = COUNT(*) FROM #jobFunctionData WHERE LegacyTableName = 'ClientContacts' AND Active = 1 ;

    SELECT  @droppedFirmCount   = COUNT(*) FROM #jobFunctionData WHERE LegacyTableName = 'FirmContacts'   AND Active = 0 ;
    SELECT  @droppedClientCount = COUNT(*) FROM #jobFunctionData WHERE LegacyTableName = 'ClientContacts' AND Active = 0 ;

    SELECT  @newCount     = @newFirmCount + @newClientCount
          , @droppedCount = @droppedFirmCount + @droppedClientCount
          , @changesCount = @newCount + @droppedCount ;

SELECT * FROM #jobFunctionData ;

--  9)  MERGE #jobFunctionData into dbo.ContactJobFunctions
      WITH  jobFunctions AS (
            SELECT  ContactID,JobFunctionID, Active, ModifiedDate, ModifiedUser
              FROM  #jobFunctionData )

     MERGE  dbo.ContactJobFunctions AS tgt
     USING  jobFunctions            AS src
        ON  tgt.ContactID = src.ContactID AND tgt.JobFunctionID = src.JobFunctionID
      WHEN  MATCHED THEN
            UPDATE SET  Active       = src.Active
                      , ModifiedDate = src.ModifiedDate
                      , ModifiedUser = src.ModifiedUser
      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( ContactID, JobFunctionID, Active, ModifiedDate, ModifiedUser )
            VALUES ( src.ContactID, src.JobFunctionID, src.Active, src.ModifiedDate, src.ModifiedUser )
    OUTPUT  $action, inserted.ContactID, inserted.JobFunctionID, inserted.Active
      INTO  @jobFunctionMergeResults ( Action, ContactID, JobFunctionID, Active ) ;
    SELECT  @recordMERGEs = @@ROWCOUNT ;


-- 10)  UPDATE @jobFunctionMergeResults with LegacyTableName
    UPDATE  @jobFunctionMergeResults
       SET  LegacyTableName = l.LegacyTableName
      FROM  @jobFunctionMergeResults  AS r
INNER JOIN  Conversion.LegacyContacts AS l ON l.ContactID = r.ContactID ;


-- 11)  SELECT control counts and validate
    SELECT  @recordFirmINSERTs = COUNT(*) FROM @jobFunctionMergeResults
     WHERE  Action = 'INSERT' AND LegacyTableName = 'FirmContacts' ;

    SELECT  @recordFirmUPDATEs = COUNT(*) FROM @jobFunctionMergeResults
     WHERE  Action = 'UPDATE' AND LegacyTableName = 'FirmContacts' ;

    SELECT  @recordClientINSERTs = COUNT(*) FROM @jobFunctionMergeResults
     WHERE  Action = 'INSERT' AND LegacyTableName = 'ClientContacts' ;

    SELECT  @recordClientUPDATEs = COUNT(*) FROM @jobFunctionMergeResults
     WHERE  Action = 'UPDATE' AND LegacyTableName = 'ClientContacts' ;

    SELECT  @newFirmActual = COUNT(*) FROM @jobFunctionMergeResults
     WHERE  Active = 1 AND LegacyTableName = 'FirmContacts' ;

    SELECT  @newClientActual = COUNT(*) FROM @jobFunctionMergeResults
     WHERE  Active = 1 AND LegacyTableName = 'ClientContacts' ;

    SELECT  @droppedFirmActual = COUNT(*) FROM @jobFunctionMergeResults
     WHERE  Active = 0 AND LegacyTableName = 'FirmContacts' ;

    SELECT  @droppedClientActual = COUNT(*) FROM @jobFunctionMergeResults
     WHERE  Active = 0 AND LegacyTableName = 'ClientContacts' ;

    SELECT  @convertedFirmActual = COUNT(*) FROM Conversion.tvf_ConvertedJobFunctions ( 'Converted' )
     WHERE  LegacyTableName = 'FirmContacts' ;

    SELECT  @convertedClientActual  = COUNT(*) FROM Conversion.tvf_ConvertedJobFunctions ( 'Converted' )
     WHERE  LegacyTableName = 'ClientContacts' ;

    SELECT  @newActual = @newFirmActual + @newClientActual
          , @droppedActual = @droppedFirmActual + @droppedClientActual
          , @recordINSERTs = @recordFirmINSERTs + @recordClientINSERTs
          , @recordUPDATEs = @recordFirmUPDATEs + @recordClientUPDATEs
          , @convertedActual = @convertedFirmActual + @convertedClientActual ;

    IF  ( @convertedActual <> ( @convertedCount + @newActual - @droppedActual ) )
        OR
        ( @convertedActual <> @legacyCount )
        OR
        ( @convertedFirmActual <> ( @convertedFirmCount + @newFirmActual - @droppedFirmActual ) )
        OR
        ( @convertedClientActual <> ( @convertedClientCount + @newClientActual - @droppedClientActual ) )
        OR
        ( @newFirmActual <> @newFirmCount )
        OR
        ( @newClientActual <> @newClientCount )
        OR
        ( @droppedFirmActual <> @droppedFirmCount )
        OR
        ( @droppedClientActual <> @droppedClientCount )
        OR
        ( @recordMERGEs <> @changesCount )
        OR
        ( @changesCount <> ( @recordINSERTs + @recordUPDATEs ) )

    BEGIN
        PRINT 'Control Totals Error!  Please review counts and processing!' ;

        PRINT ' @convertedCount        = ' + STR( @convertedCount, 8 ) ;
        PRINT ' @legacyCount           = ' + STR( @legacyCount, 8 ) ;
        PRINT ' @newFirmCount          = ' + STR( @newFirmCount, 8 ) ;
        PRINT ' @newClientCount        = ' + STR( @newClientCount, 8 ) ;
        PRINT ' @droppedFirmCount      = ' + STR( @droppedFirmCount, 8 ) ;
        PRINT ' @droppedClientCount    = ' + STR( @droppedClientCount, 8 ) ;
        PRINT ' @changesCount          = ' + STR( @changesCount, 8 ) ;
        PRINT ' @convertedActual       = ' + STR( @convertedActual, 8 ) ;
        PRINT ' @convertedFirmActual   = ' + STR( @convertedFirmActual, 8 ) ;
        PRINT ' @convertedClientActual = ' + STR( @convertedClientActual, 8 ) ;
        PRINT ' @recordMERGEs          = ' + STR( @recordMERGEs, 8 ) ;
        PRINT ' @recordINSERTs         = ' + STR( @recordINSERTs, 8 ) ;
        PRINT ' @recordUPDATEs         = ' + STR( @recordUPDATEs, 8 ) ;
        PRINT ' @convertedClientCount  = ' + STR( @convertedClientCount, 8 ) ;
        PRINT ' @convertedFirmCount    = ' + STR( @convertedFirmCount, 8 ) ;
        PRINT ' @droppedActual         = ' + STR( @droppedActual, 8 ) ;
        PRINT ' @droppedClientActual   = ' + STR( @droppedClientActual, 8 ) ;
        PRINT ' @droppedFirmActual     = ' + STR( @droppedFirmActual, 8 ) ;
        PRINT ' @newActual             = ' + STR( @newActual, 8 ) ;
        PRINT ' @newClientActual       = ' + STR( @newClientActual, 8 ) ;
        PRINT ' @newFirmActual         = ' + STR( @newFirmActual, 8 ) ;

        SELECT  @rc = 16 ;
    END

END TRY
BEGIN CATCH
    EXECUTE dbo.processEhlersError ;
END CATCH

endOfProc:
-- 12)  Reset CONTEXT_INFO to re-enable triggering on converted tables
    SET CONTEXT_INFO 0x0 ;


-- 13)  Print control totals
    PRINT 'Conversion.processContactJobFunctions CONTROL TOTALS ' ;
    PRINT '' ;
    PRINT 'Existing Job Functions                        = ' + STR( @convertedCount, 8 ) ;
    PRINT '     new records                              = ' + STR( @newActual, 8 ) ;
    PRINT '         FirmContact                          = ' + STR( @newFirmActual, 8 ) ;
    PRINT '         ClientContact                        = ' + STR( @newClientActual, 8 ) ;
    PRINT '' ;
    PRINT '     dropped records                          = ' + STR( @droppedActual, 8 ) ;
    PRINT '         FirmContact                          = ' + STR( @droppedFirmActual, 8 ) ;
    PRINT '         ClientContact                        = ' + STR( @droppedClientActual, 8 ) ;
    PRINT '' ;
    PRINT '     Total Converted JobFunctions             = '  +STR( @convertedActual, 8 ) ;
    PRINT '' ;
    PRINT 'Database Change Details ' ;
    PRINT '     Total INSERTs dbo.ContactJobFunctions    = ' + STR( @recordINSERTs, 8 ) ;
    PRINT '         INSERTs FirmContacts                 = ' + STR( @recordFirmINSERTs, 8 ) ;
    PRINT '         INSERTs ClientContacts               = ' + STR( @recordClientINSERTs, 8 ) ;
    PRINT '' ;
    PRINT '     Total UPDATEs dbo.ContactJobFunctions    = ' + STR( @recordUPDATEs, 8 ) ;
    PRINT '         UPDATEs FirmContacts                 = ' + STR( @recordFirmUPDATEs, 8 ) ;
    PRINT '         UPDATEs ClientContacts               = ' + STR( @recordClientUPDATEs, 8 ) ;
    PRINT '' ;
    PRINT '     TOTAL changes on dbo.ContactJobFunctions = ' + STR( @recordMERGEs, 8 ) ;
    PRINT '' ;

    RETURN @rc ;
END
