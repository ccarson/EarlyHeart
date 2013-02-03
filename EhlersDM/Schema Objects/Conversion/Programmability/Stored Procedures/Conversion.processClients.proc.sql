CREATE PROCEDURE Conversion.processClients
AS
/*
************************************************************************************************************************************

  Procedure:  Conversion.processClients
     Author:  Chris Carson
    Purpose:  converts legacy Clients data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Set CONTEXT_INFO to prevent converted tables from triggering changes
    2)  Create temp storage for changed data from source tables
    3)  SELECT initial control counts
    4)  Test for changes with CHECKSUMs, exit proc if there are none
    5)  INSERT changed Client data into @changedClientIDs
    6)  INSERT new Client data into #convertingClients from vw_LegacyClients
    7)  INSERT updated Client data into #convertingClients from vw_LegacyClients
    8)  MERGE #convertingClients with dbo.Client
    9)  SELECT control counts and validate
   10)  Reset CONTEXT_INFO to re-enable triggering on converted tables
   11)  Print control totals


    Notes:

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;


    DECLARE @processName            AS VARCHAR (100)    = 'processClients'
          , @errorMessage           AS VARCHAR (MAX)    = NULL
          , @errorQuery             AS VARCHAR (MAX)    = NULL
          , @processClients         AS VARBINARY (128)  = CAST( 'processClients' AS VARBINARY(128) )
          , @processStartTime       AS DATETIME         = GETDATE()
          , @processEndTime         AS DATETIME         = NULL
          , @processElapsedTime     AS INT              = 0 ;


    DECLARE @changesCount           AS INT = 0
          , @convertedActual        AS INT = 0
          , @convertedChecksum      AS INT = 0
          , @convertedCount         AS INT = 0
          , @legacyChecksum         AS INT = 0
          , @legacyCount            AS INT = 0
          , @newCount               AS INT = 0
          , @recordUPDATEs          AS INT = 0
          , @recordINSERTs          AS INT = 0
          , @recordMERGEs           AS INT = 0
          , @updatedCount           AS INT = 0 ;


    DECLARE @changedClientIDs       AS TABLE ( ClientID           INT
                                             , LegacyChecksum     VARBINARY (128)
                                             , ConvertedChecksum  VARBINARY (128) ) ;


    DECLARE @clientMergeResults     AS TABLE( Action    NVARCHAR (10)
                                            , ClientID  INT ) ;


--  1)  Set CONTEXT_INFO to prevent converted tables from triggering changes
BEGIN TRY
    SET CONTEXT_INFO @processClients ;


--  2)  Create temp storage for changed data from source tables
    IF  OBJECT_ID('tempdb..#convertingClients') IS NOT NULL
        DROP TABLE  #convertingClients ;
    CREATE TABLE    #convertingClients (
        ClientID                INT             NOT NULL    PRIMARY KEY CLUSTERED
      , ClientName              VARCHAR(100)
      , InformalName            VARCHAR(60)
      , Prefix                  INT
      , SchoolDistrictNumber    VARCHAR(50)
      , Status                  INT
      , StatusDate              DATE
      , TaxID                   CHAR(10)
      , FiscalYearEnd           CHAR(5)
      , Phone                   VARCHAR(15)
      , Fax                     VARCHAR(15)
      , TollFree                VARCHAR(15)
      , TypeJurisdiction        INT
      , JurisdictionTypeOS      VARCHAR(100)
      , GovernBoard             INT
      , Population              INT
      , NewspaperName           VARCHAR(50)
      , WebSite                 VARCHAR(50)
      , Notes                   VARCHAR(MAX)
      , QBClient                VARCHAR(50)
      , AcctClass               INT
      , ChangeDate              DATETIME
      , ChangeBy                VARCHAR(20) ) ;


--  3)  SELECT initial control counts
    SELECT  @legacyCount     = COUNT(*) FROM Conversion.vw_LegacyClients ;
    SELECT  @convertedCount  = COUNT(*) FROM Conversion.vw_ConvertedClients ;
    SELECT  @convertedActual = @convertedCount ;


--  4)  Test for changes with CHECKSUMs, exit proc if there are none
    SELECT  @legacyChecksum     = CHECKSUM_AGG(CHECKSUM(*)) FROM Conversion.tvf_ClientChecksum ( 'Legacy' ) ;
    SELECT  @convertedChecksum  = CHECKSUM_AGG(CHECKSUM(*)) FROM Conversion.tvf_ClientChecksum ( 'Converted' ) ;

    IF  ( @legacyChecksum = @convertedChecksum )
        GOTO    endOfProc ;


--  5)  INSERT changed Client data into @changedClientIDs
    INSERT  @changedClientIDs ( ClientID, LegacyChecksum, ConvertedChecksum )
    SELECT  l.ClientID, l.ClientChecksum, c.ClientChecksum
      FROM  Conversion.tvf_ClientChecksum ( 'Legacy' )      AS l
 LEFT JOIN  Conversion.tvf_ClientChecksum ( 'Converted' )   AS c ON c.ClientID = l.ClientID
     WHERE  c.ClientChecksum IS NULL OR l.ClientChecksum <> c.ClientChecksum ;
    SELECT  @changesCount = @@ROWCOUNT ;


--  6)  INSERT new Client data into #convertingClients from vw_LegacyClients
    INSERT  #convertingClients
    SELECT  *
      FROM  Conversion.vw_LegacyClients AS l
     WHERE  EXISTS ( SELECT 1 FROM @changedClientIDs AS c
                      WHERE c.ClientID = l.ClientID AND c.ConvertedChecksum IS NULL ) ;
    SELECT  @newCount = @@ROWCOUNT ;


--  7)  INSERT updated Client data into #convertingClients from vw_LegacyClients
    INSERT  #convertingClients
    SELECT  *
      FROM  Conversion.vw_LegacyClients AS l
     WHERE  EXISTS ( SELECT 1 FROM @changedClientIDs AS c
                      WHERE c.ClientID = l.ClientID AND c.LegacyChecksum <> c.ConvertedChecksum ) ;
    SELECT  @updatedCount = @@ROWCOUNT ;


--  8)  MERGE #convertingClients with dbo.Client
    SET IDENTITY_INSERT dbo.Client ON ;

     MERGE  dbo.Client          AS tgt
     USING  #convertingClients  AS src ON tgt.ClientID = src.ClientID
      WHEN  MATCHED THEN
            UPDATE  SET   ClientName              = src.ClientName
                        , InformalName            = src.InformalName
                        , ClientPrefixID          = src.Prefix
                        , SchoolDistrictNumber    = src.SchoolDistrictNumber
                        , ClientStatusID          = src.Status
                        , StatusChangeDate        = src.StatusDate
                        , TaxID                   = src.TaxID
                        , FiscalYearEnd           = src.FiscalYearEnd
                        , Phone                   = src.Phone
                        , Fax                     = src.Fax
                        , TollFreePhone           = src.TollFree
                        , JurisdictionTypeID      = src.TypeJurisdiction
                        , JurisdictionTypeOS      = src.JurisdictionTypeOS
                        , GoverningBoardID        = src.GovernBoard
                        , Population              = src.Population
                        , Newspaper               = src.NewspaperName
                        , WebSite                 = src.WebSite
                        , Notes                   = src.Notes
                        , QuickBookName           = src.QBClient
                        , EhlersJobTeamID         = src.AcctClass
                        , ModifiedDate            = src.ChangeDate
                        , ModifiedUser            = src.ChangeBy

      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( ClientID, ClientName, InformalName, ClientPrefixID, SchoolDistrictNumber
                        , ClientStatusID, StatusChangeDate, TaxID, FiscalYearEnd
                        , Phone, Fax, TollFreePhone, JurisdictionTypeID, JurisdictionTypeOS
                        , GoverningBoardID, Population, Newspaper, WebSite, Notes, QuickBookName
                        , EhlersJobTeamID, ModifiedDate, ModifiedUser )
            VALUES ( src.ClientID, src.ClientName, src.InformalName, src.Prefix, src.SchoolDistrictNumber
                        , src.Status, src.StatusDate, src.TaxID, src.FiscalYearEnd
                        , src.Phone, src.Fax, src.TollFree, src.TypeJurisdiction, src.JurisdictionTypeOS
                        , src.GovernBoard, src.Population, src.NewspaperName, src.WebSite, src.Notes, src.QBClient
                        , src.AcctClass, src.ChangeDate, src.ChangeBy )
    OUTPUT  $action, inserted.ClientID INTO @clientMergeResults ;
    SELECT  @recordMERGEs = @@ROWCOUNT ;

    SET IDENTITY_INSERT dbo.Client OFF ;


--  9)  SELECT control counts and validate
    SELECT  @recordINSERTs   = COUNT(*) FROM @clientMergeResults WHERE Action = 'INSERT' ;
    SELECT  @recordUPDATEs   = COUNT(*) FROM @clientMergeResults WHERE Action = 'UPDATE' ;
    SELECT  @convertedActual = COUNT(*) FROM Conversion.vw_ConvertedClients ;


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

-- 10)  Reset CONTEXT_INFO to re-enable triggering on converted tables
    SET CONTEXT_INFO 0x0 ;


-- 11)  Print control totals
    SELECT  @processEndTime     = GETDATE()
          , @processElapsedTime = DATEDIFF( ms, @processStartTime, @processEndTime ) ;

    PRINT   'Conversion.processClients CONTROL TOTALS ' ;
    PRINT   'Clients on legacy system                = ' + STR( @legacyCount, 8 ) ;
    PRINT   '' ;
    PRINT   'Existing Clients on converted system    = ' + STR( @convertedCount, 8 ) ;
    PRINT   '     + new records                      = ' + STR( @newCount, 8 ) ;
    PRINT   '                                           ======= ' ;
    PRINT   'Total Clients on converted system       = ' + STR( @convertedActual, 8 ) ;
    PRINT   'Changed records already counted         = ' + STR( @updatedCount, 8 ) ;
    PRINT   '' ;
    PRINT   '' ;
    PRINT   'Database Change Details ' ;
    PRINT   '' ;
    PRINT   '     Total INSERTs dbo.Client           = ' + STR( @recordINSERTs, 8 ) ;
    PRINT   '     Total UPDATEs dbo.Client           = ' + STR( @recordUPDATEs, 8 ) ;
    PRINT   '' ;
    PRINT   '     TOTAL changes on dbo.Client        = ' + STR( @recordMERGEs, 8 ) ;
    PRINT   '' ;
    PRINT   'processClients START : ' + CONVERT( VARCHAR (30), @processStartTime, 121 ) ;
    PRINT   'processClients   END : ' + CONVERT( VARCHAR (30), @processEndTime, 121 ) ;
    PRINT   '        Elapsed Time : ' + CAST ( @processElapsedTime AS VARCHAR (20) ) + 'ms' ;

END
