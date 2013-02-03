CREATE PROCEDURE Conversion.processArbitrageService
AS
/*
************************************************************************************************************************************

  Procedure:    Conversion.processArbitrageService
     Author:    Chris Carson
    Purpose:    converts legacy data from dbo.IssueArbitrageService


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

Logic Summary:
    1)  Set CONTEXT_INFO to prevent converted tables from triggering
    2)  Load temp table with data changes:
        a)  Detect new data with no checksum
        b)  Detect changed data from ConvertedCallsData
        c)  Detect deleted data with missing checksums from ConvertedCallsData
    4)  Determine new IssueCallID values for INSERTs
    5)  MERGE #legacyCallsData with dbo.IssueCall
    6)  Update Conversion.DataChecksums with new HASHBYTES data
    7)  Print Control totals

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;

    DECLARE @totalRecords               AS INT = 0
          , @recordsDELETEd             AS INT = 0
          , @recordsINSERTed            AS INT = 0
          , @recordsMERGEd              AS INT = 0
          , @recordsToDelete            AS INT = 0
          , @recordsToInsert            AS INT = 0
          , @recordsToUpdate            AS INT = 0
          , @recordsUPDATEd             AS INT = 0
          , @rc                         AS INT = 0 
          , @processArbitrageService    AS VARBINARY(128) = CAST( 'processArbitrageService' AS VARBINARY(128) ) ;


--  1)  Set CONTEXT_INFO to prevent converted tables from triggering changes
    SET CONTEXT_INFO @processArbitrageService ;


--  2)  Load temp table with data changes
    IF  OBJECT_ID('tempdb..#processData') IS NOT NULL
        DROP TABLE #processData ;
    CREATE  TABLE  #processData (
        ID              INT     NOT NULL    PRIMARY KEY CLUSTERED
      , IssueID         INT
      , DtService       DATETIME
      , ComputationType INT
      , ynDataReq       BIT
      , ynDataIn        BIT
      , ynReport        BIT
      , Fee             DECIMAL( 15,2 )
      , ModifiedDate    DATETIME
      , ModifiedUser    VARCHAR(20) ) ;

    IF  OBJECT_ID ('tempdb..#changedData') IS NOT NULL
        DROP TABLE #changedData ;
    CREATE  TABLE  #changedData (
        ID                  INT
      , legacyChecksum      VARBINARY(128)
      , convertedChecksum   VARBINARY(128) ) ;


--  3)  Check for changes on edata.IssueArbitrageServices, bypass if no changes
    INSERT  #changedData
    SELECT  ID                  = l.ArbitrageServiceID
          , legacyChecksum      = l.ArbitrageServiceChecksum
          , convertedChecksum   = c.ArbitrageServiceChecksum
      FROM  Conversion.tvf_ArbitrageServiceChecksum ( 'Legacy' ) AS l
 LEFT JOIN  Conversion.tvf_ArbitrageServiceChecksum ( 'Converted' ) AS c
        ON  l.ArbitrageServiceID = c.ArbitrageServiceID
     WHERE  c.ArbitrageServiceChecksum IS NULL
            OR l.ArbitrageServiceChecksum <> c.ArbitrageServiceChecksum ;
    SELECT  @totalRecords = @@ROWCOUNT ;

    INSERT  #changedData
    SELECT  ID                  = c.ArbitrageServiceID
          , legacyChecksum      = l.ArbitrageServiceChecksum
          , convertedChecksum   = c.ArbitrageServiceChecksum
      FROM  Conversion.tvf_ArbitrageServiceChecksum ( 'Converted' ) AS c
 LEFT JOIN  Conversion.tvf_ArbitrageServiceChecksum ( 'Legacy' ) AS l
        ON  l.ArbitrageServiceID = c.ArbitrageServiceID
     WHERE  l.ArbitrageServiceChecksum IS NULL ;
    SELECT  @totalRecords = @totalRecords + @@ROWCOUNT ;

    IF  ( @totalRecords = 0  )
        BEGIN
            PRINT 'ArbitrageService data unchanged, ending processArbitrageService' ;
            GOTO endOfProc ;
        END
    ELSE
        PRINT 'Data has changed, migrating ArbitrageService data' ;

--  6)  When there are no INSERTs or UPDATEs, exit procedure
    IF  @totalRecords = 0 GOTO endOfProc ;

    --    Load INSERTs to dbo.ArbitrageService
    INSERT  #processData
    SELECT  ID, IssueID, DtService
                , ComputationType, ynDataReq
                , ynDataIn, ynReport, Fee
                , ModifiedDate, ModifiedUser
      FROM  Conversion.vw_LegacyArbitrageService AS a
     WHERE  EXISTS ( SELECT 1 FROM #changedData  AS b
                      WHERE a.ID = b.ID AND b.convertedChecksum IS NULL )
     ORDER  BY 2,3 ;
    SELECT  @recordsToInsert = @@ROWCOUNT ;

    --    Load UPDATEs for dbo.ArbitrageService
    INSERT  #processData
    SELECT  ID, IssueID, DtService
                , ComputationType, ynDataReq
                , ynDataIn, ynReport, Fee
                , ModifiedDate, ModifiedUser
      FROM  Conversion.vw_LegacyArbitrageService AS a
     WHERE  EXISTS ( SELECT 1 FROM #changedData  AS b
                      WHERE a.ID = b.ID AND b.legacyChecksum <> b.convertedChecksum )
    SELECT  @recordsToUpdate = @@ROWCOUNT ;

    --    Load DELETEs for dbo.ArbitrageService
    INSERT  #processData ( ID )
    SELECT  ID
      FROM  Conversion.vw_ConvertedArbitrageService AS a
     WHERE  EXISTS ( SELECT 1 FROM #changedData  AS b
                      WHERE a.ID = b.ID AND b.legacyChecksum IS NULL ) ;
    SELECT  @recordsToDelete = @@ROWCOUNT ;


--  6)  Throw error if no records are loaded
    SELECT  @totalRecords = @recordsToInsert +
                            @recordsToUpdate +
                            @recordsToDelete ;

    SELECT  @totalRecords = @recordsToInsert + @recordsToUpdate ;

    IF  ( @totalRecords = 0 )
    BEGIN
        PRINT   'Error:  changes detected but not captured' ;
        SELECT  @rc = 16 ;
        GOTO    endOfProc ;
    END


--  8)  MERGE #processCallsData with dbo.IssueCall
    DECLARE @SummaryOfChanges AS TABLE( Change NVARCHAR(10) ) ;

    SET IDENTITY_INSERT dbo.ArbitrageService ON ;

     MERGE  dbo.ArbitrageService  AS tgt
     USING  #processData          AS src
        ON  tgt.ArbitrageServiceID = src.ID
      WHEN  MATCHED AND src.IssueID IS NULL THEN
            DELETE
      WHEN  MATCHED THEN
            UPDATE SET  ServiceDate                 = src.DtService
                      , ArbitrageComputationTypeID  = src.ComputationType
                      , DataRequested               = src.ynDataReq
                      , DataReceived                = src.ynDataIn
                      , ArbitrageReport             = src.ynReport
                      , ArbitrageFee                = src.Fee
                      , ModifiedDate                = src.ModifiedDate
                      , ModifiedUser                = src.ModifiedUser
      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( ArbitrageServiceID, IssueID
                        , ServiceDate, ArbitrageComputationTypeID
                        , DataRequested, DataReceived
                        , ArbitrageReport, ArbitrageFee
                        , ModifiedDate, ModifiedUser )
            VALUES ( src.ID, src.IssueID
                        , src.DtService, src.ComputationType
                        , src.ynDataReq, src.ynDataIn
                        , src.ynReport, src.Fee
                        , src.ModifiedDate, src.ModifiedUser )

    OUTPUT  $action INTO @SummaryOfChanges ;
    SELECT  @recordsMERGEd = @@ROWCOUNT    ;

    SET IDENTITY_INSERT dbo.ArbitrageService OFF ;

    IF  @recordsMERGEd <> @totalRecords
    BEGIN
        PRINT   'Processing Error: @totalRecords  = ' + CAST( @totalRecords AS VARCHAR(20) )
              + '                  @recordsMERGEd = ' + CAST( @recordsMERGEd AS VARCHAR(20) ) + ' .' ;
        SELECT  @rc = 16 ;
    END


    SELECT  @recordsINSERTed = COUNT(*) FROM @SummaryOfChanges WHERE Change = 'INSERT' ;
    IF  @recordsINSERTed <> @recordsToInsert
    BEGIN
        PRINT   'Error ON INSERT:  @recordsToInsert = ' + CAST( @recordsToInsert AS VARCHAR(20) )
              + '                  @recordsINSERTed = ' + CAST( @recordsINSERTed AS VARCHAR(20) ) + ' .' ;
        SELECT  @rc = 16 ;
    END

    SELECT  @recordsUPDATEd = COUNT(*) FROM @SummaryOfChanges WHERE Change = 'UPDATE' ;
    IF  @recordsUPDATEd <> @recordsToUpdate
    BEGIN
        PRINT   'Error ON UPDATE:  @recordsToUpdate = ' + CAST( @recordsToUpdate AS VARCHAR(20) )
              + '                  @recordsUPDATEd  = ' + CAST( @recordsUPDATEd AS VARCHAR(20) ) + ' .' ;
        SELECT  @rc = 16 ;
    END

    SELECT  @recordsDELETEd = COUNT(*) FROM @SummaryOfChanges WHERE Change = 'DELETE' ;
    IF  @recordsDELETEd <> @recordsToDelete
    BEGIN
        PRINT   'Error ON UPDATE:  @recordsToDelete = ' + CAST( @recordsToDelete AS VARCHAR(20) )
              + '                  @recordsDELETEd  = ' + CAST( @recordsDELETEd AS VARCHAR(20) ) + ' .' ;
        SELECT  @rc = 16 ;
    END

    IF  @rc = 16    GOTO endOfProc ;


endOfProc:
-- 10)  Reset CONTEXT_INFO to re-enable converted table triggers
    SET CONTEXT_INFO 0x0 ;

-- 11)  Print control totals
    PRINT 'CONTROL TOTALS ' ;
    PRINT '    Changed records                          = ' + CAST( @totalRecords    AS VARCHAR(20) ) ;
    PRINT '         new records                         = ' + CAST( @recordsToInsert AS VARCHAR(20) ) ;
    PRINT '         modified records                    = ' + CAST( @recordsToUpdate AS VARCHAR(20) ) ;
    PRINT '         deleted records                     = ' + CAST( @recordsToDelete AS VARCHAR(20) ) ;
    PRINT '' ;
    PRINT '    Processed records                        = ' + CAST( @recordsMERGEd   AS VARCHAR(20) ) ;
    PRINT '         INSERTs to   dbo.ArbitrageService   = ' + CAST( @recordsINSERTed AS VARCHAR(20) ) ;
    PRINT '         UPDATEs to   dbo.ArbitrageService   = ' + CAST( @recordsUPDATEd  AS VARCHAR(20) ) ;
    PRINT '         DELETEs from dbo.ArbitrageService   = ' + CAST( @recordsDELETEd  AS VARCHAR(20) ) ;
    PRINT '' ;
END
