CREATE PROCEDURE Conversion.processLocalAttorney
AS
/*
************************************************************************************************************************************

  Procedure:  Conversion.processLocalAttorney
     Author:  Chris Carson
    Purpose:  converts legacy ClientCPA data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:


    Notes:

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;

    DECLARE @rc                         AS INT              = 0
          , @processName                AS VARCHAR(100)     = 'processLocalAttorney'
          , @errorMessage               AS VARCHAR(MAX)     = NULL
          , @errorQuery                 AS VARCHAR(MAX)     = NULL
          , @processLocalAttorney       AS VARBINARY(128)   = CAST( 'processLocalAttorney' AS VARBINARY(128) ) ;


    DECLARE @changesCount               AS INT = 0
          , @convertedActual            AS INT = 0
          , @convertedChecksum          AS INT = 0
          , @convertedCount             AS INT = 0
          , @droppedActual              AS INT = 0
          , @droppedCount               AS INT = 0
          , @errorCount                 AS INT = 0
          , @legacyChecksum             AS INT = 0
          , @legacyCount                AS INT = 0
          , @newActual                  AS INT = 0
          , @newCount                   AS INT = 0
          , @recordDELETEs              AS INT = 0
          , @recordINSERTs              AS INT = 0
          , @recordMERGEs               AS INT = 0 ;


    DECLARE @droppedAttorneys     AS TABLE ( ClientID         INT
                                           , LocalAttorney    VARCHAR(100)
                                           , FirmCategoriesID INT ) ;

    DECLARE @attorneyMergeResults AS TABLE ( Action           NVARCHAR (10) ) ;




--  1)  Set CONTEXT_INFO to prevent converted tables from triggering changes
BEGIN TRY
    SET CONTEXT_INFO @processLocalAttorney ;


--  2)  Create temp storage for changed data from source tables
    IF  OBJECT_ID ('tempdb..#changedAttorneys') IS NOT NULL
        DROP TABLE  #changedAttorneys ;
    CREATE TABLE    #changedAttorneys (
        ClientID            INT
      , FirmCategoriesID    INT
      , ModifiedDate        DATETIME
      , ModifiedUser        VARCHAR (20) ) ;


--  3)  SELECT initial control counts
    SELECT  @legacyCount     = COUNT(*) FROM Conversion.tvf_LocalAttorney ( 'Legacy' ) WHERE FirmCategoriesID <> 0 ; 
    SELECT  @errorCount      = COUNT(*) FROM Conversion.tvf_LocalAttorney ( 'Legacy' ) WHERE FirmCategoriesID = 0 ;
    SELECT  @convertedCount  = COUNT(*) FROM Conversion.tvf_LocalAttorney ( 'Converted' ) ;
    SELECT  @convertedActual = @convertedCount ;


--  4)  Test for changes with CHECKSUMs, exit proc if there are none
    SELECT  @legacyChecksum     = CHECKSUM_AGG( CHECKSUM(*) ) FROM Conversion.tvf_LocalAttorney( 'Legacy' ) WHERE FirmCategoriesID <> 0 ; 
    SELECT  @convertedChecksum  = CHECKSUM_AGG( CHECKSUM(*) ) FROM Conversion.tvf_LocalAttorney( 'Converted' ) ;

    IF  ( @legacyChecksum = @convertedChecksum )
    BEGIN
        PRINT   'no Local Attorney changes, exiting' ;
        GOTO    endOfProc ;
    END

    PRINT 'migrating changed Local Attorney data' ;


--  5)  INSERT new Local Attorneys into #changedAttorneys
      WITH  newAttorneys AS (
            SELECT ClientID, FirmCategoriesID FROM Conversion.tvf_LocalAttorney ( 'Legacy' )
                EXCEPT
            SELECT  ClientID, FirmCategoriesID FROM Conversion.tvf_LocalAttorney ( 'Converted' ) )
    INSERT  #changedAttorneys ( ClientID, FirmCategoriesID )
    SELECT  ClientID, FirmCategoriesID
      FROM  newAttorneys
     WHERE  FirmCategoriesID <> 0
    SELECT  @newCount = @@ROWCOUNT ;


--  6)  INSERT dropped Local Attorneys into #changedAttorneys
      WITH  droppedAttorneys AS (
            SELECT ClientID, FirmCategoriesID FROM Conversion.tvf_LocalAttorney ( 'Converted' )
                EXCEPT
            SELECT ClientID, FirmCategoriesID FROM Conversion.tvf_LocalAttorney ( 'Legacy' ) )
    INSERT  #changedAttorneys ( ClientID, FirmCategoriesID )
    SELECT  ClientID, 0
      FROM  droppedAttorneys ;
    SELECT  @droppedCount = @@ROWCOUNT ;

    SELECT  @changesCount = @newCount + @droppedCount ;


--  7)  UPDATE #changedAttorneys with legacy Contact change data
    UPDATE  #changedAttorneys
       SET  ModifiedDate = b.ChangeDate
          , ModifiedUser = ISNULL( NULLIF ( b.ChangeBy, 'processClients' ), 'processLocalAttorney' )
      FROM  #changedAttorneys           AS a
INNER JOIN  Conversion.vw_LegacyClients AS b ON b.ClientID = a.ClientID ;


-- 8)   MERGE #changedAttorneys into dbo.ClientFirms
      WITH  convertedRecords AS (
            SELECT * FROM dbo.ClientFirms AS cf
             WHERE EXISTS ( SELECT 1 FROM Conversion.tvf_LocalAttorney ( 'Converted' ) AS c
                             WHERE c.ClientID = cf.ClientID and c.FirmCategoriesID = cf.FirmCategoriesID )
               AND EXISTS ( SELECT 1 FROM #changedAttorneys AS a WHERE a.ClientID = cf.ClientID ) )

     MERGE  convertedRecords  AS tgt
     USING  #changedAttorneys AS src ON src.ClientID = tgt.ClientID
      WHEN  MATCHED AND src.FirmCategoriesID = 0 THEN
            DELETE
      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( ClientID, FirmCategoriesID, ModifiedDate, ModifiedUser )
            VALUES ( src.ClientID, src.FirmCategoriesID, src.ModifiedDate, src.ModifiedUser )
    OUTPUT  $action INTO @attorneyMergeResults ( Action ) ;
    SELECT  @recordMERGEs = @@ROWCOUNT ;


--  9)  SELECT control counts and validate
    SELECT  @recordINSERTs   = COUNT(*) FROM @attorneyMergeResults WHERE  Action = 'INSERT' ;
    SELECT  @recordDELETEs   = COUNT(*) FROM @attorneyMergeResults WHERE  Action = 'DELETE' ;
    SELECT  @convertedActual = COUNT(*) FROM Conversion.tvf_LocalAttorney( 'Converted' ) ;

    IF  ( @convertedActual <> ( @convertedCount + @recordINSERTs - @recordDELETEs ) )
        OR
        ( @convertedActual <> @legacyCount )
        OR
        ( @recordINSERTs <> @newCount )
        OR
        ( @recordDELETEs <> @droppedCount )
        OR
        ( @recordMERGEs <> @changesCount )
        OR
        ( @changesCount <> ( @recordINSERTs + @recordDELETEs ) )

    BEGIN
        PRINT 'Control Totals Error!  Please review counts and processing!' ;
        PRINT '@convertedActual     = ' + STR( @convertedActual, 8 ) ;
        PRINT '@convertedCount      = ' + STR( @convertedCount, 8 ) ;
        PRINT '@recordINSERTs       = ' + STR( @recordINSERTs, 8 ) ;
        PRINT '@recordDELETEs       = ' + STR( @recordDELETEs, 8 ) ;
        PRINT ''
        PRINT '@convertedActual     = ' + STR( @convertedActual, 8 ) ;
        PRINT '@legacyCount         = ' + STR( @legacyCount, 8 ) ;
        PRINT ''
        PRINT '@recordINSERTs       = ' + STR( @recordINSERTs, 8 ) ;
        PRINT '@newCount            = ' + STR( @newCount, 8 ) ;
        PRINT ''
        PRINT '@recordDELETEs       = ' + STR( @recordDELETEs, 8 ) ;
        PRINT '@droppedCount        = ' + STR( @droppedCount, 8 ) ;
        PRINT ''
        PRINT '@recordMERGEs        = ' + STR( @recordMERGEs, 8 ) ;
        PRINT '@changesCount        = ' + STR( @changesCount, 8 ) ;
        PRINT ''
        PRINT '@changesCount        = ' + STR( @changesCount, 8 ) ;
        PRINT '@recordINSERTs       = ' + STR( @recordINSERTs, 8 ) ;
        PRINT '@recordDELETEs       = ' + STR( @recordDELETEs, 8 ) ;

        SELECT  @rc = 0 ;
    END

END TRY
BEGIN CATCH
    EXECUTE dbo.processEhlersError ;
END CATCH

endOfProc:
-- 12)  Reset CONTEXT_INFO to re-enable triggering on converted tables
    SET CONTEXT_INFO 0x0 ;


-- 13)  Print control totals
    PRINT 'Conversion.processLocalAttorney CONTROL TOTALS ' ;
    PRINT '' ;
    PRINT 'Existing Attorneys                            = ' + STR( @convertedCount, 8 ) ;
    PRINT '     + new records                  = ' + STR( @recordINSERTs, 8 ) ;
    PRINT '     - dropped records              = ' + STR( @recordDELETEs, 8 ) ;
    PRINT '                                                 ========== ' ;
    PRINT '     Total Local Attorneys                    = ' + STR( @convertedActual, 8 ) ;
    PRINT '' ;
    PRINT 'Database Change Details ' ;
    PRINT '' ;
    PRINT '     Total INSERTs dbo.ClientFirms            = ' + STR( @recordINSERTs, 8 ) ;
    PRINT '     Total DELETEs dbo.ClientFirms            = ' + STR( @recordDELETEs, 8 ) ;
    PRINT '' ;
    PRINT '     TOTAL changes on dbo.ClientFirms         = ' + STR( @recordMERGEs, 8 ) ;
    PRINT '' ;

    RETURN @rc ;
END
