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

    Logic Summary:
    1)  SET CONTEXT_INFO prevents related converted tables from firing triggers caused by changes from proc
    2)  Create temp storage for changed data from source tables
    3)  SELECT initial control counts
    4)  INSERT changed Firms data into @changedFirmIDs
    5)  Exit procedure if there are no changes on edata.dbo.Firms
    6)  INSERT new firms data into #convertingFirms
    7)  INSERT updated Firms data into #convertingFirms
    8)  MERGE #processFirmsData with dbo.Firm
    9)  SELECT control counts and validate
   10)  Reset CONTEXT_INFO to re-enable converted table triggers
   11)  Print control totals


    Notes:

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;


    DECLARE @processName            AS VARCHAR (100)    = 'processFirms'
          , @errorMessage           AS VARCHAR (MAX)    = NULL
          , @errorQuery             AS VARCHAR (MAX)    = NULL
          , @processFirms           AS VARBINARY (128)  = CAST( 'processFirms' AS VARBINARY(128) )
          , @processStartTime       AS DATETIME         = GETDATE()
          , @processEndTime         AS DATETIME         = NULL
          , @processElapsedTime     AS INT              = 0 ;


    DECLARE @changesCount           AS INT = 0
          , @convertedActual        AS INT = 0
          , @convertedCount         AS INT = 0
          , @legacyCount            AS INT = 0
          , @newCount               AS INT = 0
          , @recordUPDATEs          AS INT = 0
          , @recordINSERTs          AS INT = 0
          , @recordMERGEs           AS INT = 0
          , @updatedCount           AS INT = 0 ;


    DECLARE @changedFirmIDs         AS TABLE ( FirmID   INT
                                             , LegacyChecksum      VARBINARY (128)
                                             , ConvertedChecksum   VARBINARY (128) ) ;


    DECLARE @firmMergeResults       AS TABLE( Action  NVARCHAR (10)
                                            , FirmID  INT ) ;


--  1)  SET CONTEXT_INFO prevents related converted tables from firing triggers caused by changes from proc
BEGIN TRY
    SET CONTEXT_INFO @processFirms ;


--  2)  Create temp storage for changed data from source tables
    IF  OBJECT_ID('tempdb..#convertingFirms') IS NOT NULL
        DROP TABLE  #convertingFirms ;
    CREATE TABLE    #convertingFirms (
        FirmID          INT     NOT NULL    PRIMARY KEY CLUSTERED
      , Firm            VARCHAR (125)
      , ShortName       VARCHAR (50)
      , FirmStatus      BIT
      , Phone           VARCHAR (20)
      , Fax             VARCHAR (20)
      , TollFree        VARCHAR (20)
      , WebSite         VARCHAR (50)
      , GoodFaith       VARCHAR (MAX)
      , Notes           VARCHAR (MAX)
      , ChangeDate      DATETIME
      , ChangeBy        VARCHAR (50) ) ;


--  3)  SELECT initial control counts
    SELECT  @legacyCount        = COUNT(*) FROM Conversion.vw_LegacyFirms ;
    SELECT  @convertedCount     = COUNT(*) FROM Conversion.vw_ConvertedFirms ;
    SELECT  @convertedActual    = @convertedCount ;


--  4)  INSERT changed Firms data into @changedFirmIDs
    INSERT  @changedFirmIDs
    SELECT  FirmID            = l.FirmID
          , legacyChecksum    = l.FirmChecksum
          , convertedChecksum = c.FirmChecksum
      FROM  Conversion.tvf_FirmChecksum( 'Legacy' )    AS l
 LEFT JOIN  Conversion.tvf_FirmChecksum( 'Converted' ) AS c ON l.FirmID = c.FirmID
     WHERE  c.FirmChecksum IS NULL OR l.FirmChecksum <> c.FirmChecksum ;
    SELECT  @changesCount = @@ROWCOUNT ;


--  5)  Exit procedure if there are no changes on edata.dbo.Firms
    IF  ( @changesCount = 0 )
        GOTO  endOfProc ;


--  6)  INSERT new firms data into #convertingFirms
    INSERT  #convertingFirms
    SELECT  FirmID, Firm, ShortName
                , FirmStatus, Phone, Fax
                , TollFree, WebSite
                , GoodFaith, Notes
                , ChangeDate, ChangeBy
      FROM  Conversion.vw_LegacyFirms AS a
     WHERE  EXISTS ( SELECT 1 FROM @changedFirmIDs AS b
                      WHERE a.FirmID = b.FirmID AND b.convertedChecksum IS NULL ) ;
    SELECT  @newCount = @@ROWCOUNT ;


--  7)  INSERT updated Firms data into #convertingFirms
    INSERT  #convertingFirms
    SELECT  FirmID, Firm, ShortName
                , FirmStatus, Phone, Fax
                , TollFree, WebSite
                , GoodFaith, Notes
                , ChangeDate, ChangeBy
      FROM  Conversion.vw_LegacyFirms AS a
     WHERE  EXISTS ( SELECT 1 FROM @changedFirmIDs AS b
                      WHERE a.FirmID = b.FirmID AND b.legacyChecksum <> b.convertedChecksum ) ;
    SELECT  @updatedCount = @@ROWCOUNT ;


--  8)  MERGE #processFirmsData with dbo.Firm
    SET IDENTITY_INSERT dbo.Firm ON ;

     MERGE  dbo.Firm            AS tgt
     USING  #convertingFirms    AS src ON tgt.FirmID = src.FirmID
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


--  9)  SELECT control counts and validate
    SELECT  @recordINSERTs   = COUNT(*) FROM @firmMergeResults WHERE  Action = 'INSERT' ;
    SELECT  @recordUPDATEs   = COUNT(*) FROM @firmMergeResults WHERE  Action = 'UPDATE' ;
    SELECT  @convertedActual = COUNT(*) FROM Conversion.vw_ConvertedFirms ;

    IF  ( @convertedActual <> ( @convertedCount + @recordINSERTs ) )
        OR
        ( @convertedActual <> @legacyCount )
        OR
        ( @recordINSERTs <> @newCount )
        OR
        ( @recordUPDATEs <> @updatedCount )
        OR
        ( @recordMERGEs <> @changesCount )
        OR
        ( @changesCount <> ( @recordINSERTs + @recordUPDATEs ) )

    BEGIN
        PRINT 'Control Totals Error!  Please review counts and processing!' ;
        PRINT '' ;
        PRINT '@convertedActual = ' + STR( @convertedActual, 8 ) ;
        PRINT '@convertedCount  = ' + STR( @convertedCount, 8 ) ;
        PRINT '@recordINSERTs   = ' + STR( @recordINSERTs, 8 ) ;
        PRINT '' ;
        PRINT '@convertedActual = ' + STR( @convertedActual, 8 ) ;
        PRINT '@legacyCount     = ' + STR( @legacyCount, 8 ) ;
        PRINT '' ;
        PRINT '@recordINSERTs   = ' + STR( @recordINSERTs, 8 ) ;
        PRINT '@newCount        = ' + STR( @newCount, 8 ) ;
        PRINT '' ;
        PRINT '@recordUPDATEs   = ' + STR( @recordUPDATEs, 8 ) ;
        PRINT '@updatedCount    = ' + STR( @updatedCount, 8 ) ;
        PRINT '' ;
        PRINT '@recordMERGEs    = ' + STR( @recordMERGEs, 8 ) ;
        PRINT '@changesCount    = ' + STR( @changesCount, 8 ) ;
        PRINT '' ;
        PRINT '@changesCount    = ' + STR( @changesCount, 8 ) ;
        PRINT '@recordINSERTs   = ' + STR( @recordINSERTs, 8 ) ;
        PRINT '@recordUPDATEs   = ' + STR( @recordUPDATEs, 8 ) ;
    END


END TRY
BEGIN CATCH
    EXECUTE dbo.processEhlersError ;
END CATCH


endOfProc:

-- 10)  Reset CONTEXT_INFO to re-enable converted table triggers
    SET CONTEXT_INFO 0x0 ;


-- 11)  Print control totals
    SELECT  @processEndTime     = GETDATE()
          , @processElapsedTime = DATEDIFF( ms, @processStartTime, @processEndTime ) ;

    PRINT   'Conversion.processFirms CONTROL TOTALS ' ;
    PRINT   'Firms on legacy system                  = ' + STR( @legacyCount, 8 ) ;
    PRINT   '' ;
    PRINT   'Existing Firms on converted system      = ' + STR( @convertedCount, 8 ) ;
    PRINT   '     + new records                      = ' + STR( @newCount, 8 ) ;
    PRINT   '                                           ======= ' ;
    PRINT   'Total Firms on converted system         = ' + STR( @convertedActual, 8 ) ;
    PRINT   'Changed records already counted         = ' + STR( @updatedCount, 8 ) ;
    PRINT   '' ;
    PRINT   '' ;
    PRINT   'Database Change Details ' ;
    PRINT   '' ;
    PRINT   '     Total INSERTs dbo.Firm             = ' + STR( @recordINSERTs, 8 ) ;
    PRINT   '     Total UPDATEs dbo.Firm             = ' + STR( @recordUPDATEs, 8 ) ;
    PRINT   '' ;
    PRINT   '     TOTAL changes on dbo.Firm          = ' + STR( @recordMERGEs, 8 ) ;
    PRINT   '' ;
    PRINT   'processFirms START : ' + CONVERT( VARCHAR (30), @processStartTime, 121 ) ;
    PRINT   'processFirms   END : ' + CONVERT( VARCHAR (30), @processEndTime, 121 ) ;
    PRINT   '      Elapsed Time : ' + CAST ( @processElapsedTime AS VARCHAR (20) ) + 'ms' ;

END
