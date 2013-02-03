CREATE PROCEDURE Conversion.processClientDisclosure
AS
/*
************************************************************************************************************************************

  Procedure:  Conversion.processClientDisclosure
     Author:  Chris Carson
    Purpose:  converts legacy Clients with disclosure data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:

    Notes:

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;

    DECLARE @rc                         AS INT            = 0
          , @errorMessage               AS VARCHAR(MAX)   = NULL
          , @errorQuery                 AS VARCHAR(MAX)   = NULL
          , @processName                AS VARCHAR(100)   = 'processClientDisclosure'
          , @processClientDisclosure    AS VARBINARY(128) = CAST( 'processClientDisclosure' AS VARBINARY(128) ) ;

    DECLARE @convertedDisclosuresActual AS INT = 0
          , @convertedDisclosuresCount  AS INT = 0
          , @disclosureChangesActual    AS INT = 0
          , @disclosureChangesCount     AS INT = 0
          , @disclosureMERGEs           AS INT = 0
          , @droppedDisclosuresActual   AS INT = 0
          , @droppedDisclosuresCount    AS INT = 0
          , @legacyDisclosuresCount     AS INT = 0
          , @newDisclosuresActual       AS INT = 0
          , @newDisclosuresCount        AS INT = 0
          , @updatedDisclosuresActual   AS INT = 0
          , @updatedDisclosuresCount    AS INT = 0 ;


    DECLARE @disclosureChanges          AS TABLE ( ClientID             INT
                                                 , LegacyChecksum       VARBINARY (128)
                                                 , ConvertedChecksum    VARBINARY (128) ) ;


    DECLARE @disclosureMergeResults     AS TABLE ( Action    NVARCHAR(10)
                                                 , ClientID  INT ) ;

BEGIN TRY


--  1)  Set CONTEXT_INFO to prevent converted tables from triggering changes
    SET CONTEXT_INFO @processClientDisclosure ;


--  2)  Create temp storage for changed data from source tables
    IF  OBJECT_ID('tempdb..#processDisclosureData') IS NOT NULL
        DROP TABLE  #processDisclosureData ;
    CREATE TABLE    #processDisclosureData (
        ClientID        INT             NOT NULL    PRIMARY KEY CLUSTERED
      , DisclosureType  VARCHAR (100)
      , ContractType    VARCHAR (100)
      , ContractDate    DATE
      , ChangeDate      DATETIME
      , ChangeBy        VARCHAR (20) ) ;


--  3)  SELECT initial control counts
    SELECT  @legacyDisclosuresCount       = COUNT(*) FROM Conversion.vw_LegacyClientDisclosure ;
    SELECT  @convertedDisclosuresCount    = COUNT(*) FROM Conversion.vw_ConvertedClientDisclosure ;
    SELECT  @convertedDisclosuresActual   = @convertedDisclosuresCount ;


--  4)  Test for changes with CHECKSUMs, exit proc if there are none
    IF  NOT EXISTS ( SELECT CHECKSUM_AGG( CHECKSUM(*) ) FROM Conversion.tvf_ClientDisclosureChecksum( 'Legacy' )
                        EXCEPT
                     SELECT CHECKSUM_AGG( CHECKSUM(*) ) FROM Conversion.tvf_ClientDisclosureChecksum( 'Converted' ) )
    BEGIN
        PRINT   'No changes for client Disclosure' + CHAR(13) ;
        GOTO    endOfProc ;
    END

    PRINT 'Migrating client Disclosure changes ' + CHAR(13) ;

--  5)  INSERT changed Disclosure data into @disclosureChanges
    INSERT  @disclosureChanges
    SELECT  ClientID            = l.ClientID
          , LegacyChecksum      = l.DisclosureChecksum
          , ConvertedChecksum   = c.DisclosureChecksum
      FROM  Conversion.tvf_ClientDisclosureChecksum( 'Legacy' )    AS l
 LEFT JOIN  Conversion.tvf_ClientDisclosureChecksum( 'Converted' ) AS c ON c.ClientID = l.ClientID
     WHERE  c.ClientID IS NULL OR l.DisclosureChecksum <> c.DisclosureChecksum
        UNION ALL
    SELECT  ClientID            = c.ClientID
          , LegacyChecksum      = l.DisclosureChecksum
          , ConvertedChecksum   = c.DisclosureChecksum
      FROM  Conversion.tvf_ClientDisclosureChecksum( 'Converted' ) AS c
 LEFT JOIN  Conversion.tvf_ClientDisclosureChecksum( 'Legacy' )    AS l ON l.ClientID = c.ClientID
     WHERE  l.ClientID IS NULL ;
    SELECT  @disclosureChangesCount = @@ROWCOUNT ;


--  6)  INSERT new Disclosure data into #processClientDisclosureData from vw_LegacyClientDisclosures
      WITH  newDisclosures AS (
            SELECT * FROM Conversion.vw_LegacyClientDisclosure AS l
             WHERE EXISTS ( SELECT 1 FROM @disclosureChanges AS d
                             WHERE d.ClientID = l.ClientID AND d.ConvertedChecksum IS NULL ) )

    INSERT  #processDisclosureData
    SELECT  *
      FROM  newDisclosures
    SELECT  @newDisclosuresCount = @@ROWCOUNT ;


--  7)  INSERT updated Disclosure data into #processClientDisclosureData from vw_LegacyClientDisclosures
      WITH  updatedDisclosures AS (
            SELECT * FROM Conversion.vw_LegacyClientDisclosure AS l
             WHERE EXISTS ( SELECT 1 FROM @disclosureChanges AS d
                             WHERE d.ClientID = l.ClientID AND d.ConvertedChecksum <> d.LegacyChecksum ) )
    INSERT  #processDisclosureData
    SELECT  *
      FROM  updatedDisclosures ;
    SELECT  @updatedDisclosuresCount = @@ROWCOUNT ;


--  8)  INSERT dropped Disclosure data into #processClientDisclosureData from vw_LegacyClientDisclosures
      WITH  droppedDisclosures AS (
            SELECT  ClientID, ChangeDate, ChangeBy
              FROM  Conversion.vw_LegacyClients AS l
             WHERE  EXISTS ( SELECT 1 FROM @disclosureChanges AS d
                              WHERE d.ClientID = l.ClientID AND d.LegacyChecksum IS NULL ) )

    INSERT  #processDisclosureData ( ClientID, ChangeDate, ChangeBy )
    SELECT  ClientID, ChangeDate, ChangeBy
      FROM  droppedDisclosures ;
    SELECT  @droppedDisclosuresCount = @@ROWCOUNT ;


--  9)  UPDATE existing dbo.Client with Disclosure Data from #processClientDisclosureData
    UPDATE  dbo.Client
       SET  DisclosureContractType = ISNULL( DisclosureType, '' )
          , ContractBillingType    = ISNULL( ContractType, '' )
      FROM  dbo.Client                   AS c
INNER JOIN  #processDisclosureData AS d ON d.ClientID = c.ClientID ;
    SELECT  @disclosureChangesActual = @@ROWCOUNT ;


-- 10)  MERGE #processClientDisclosureData
      WITH  existingDocuments AS (
            SELECT * FROM dbo.ClientDocument AS c
             WHERE ClientDocumentNameID = 2
               AND EXISTS ( SELECT 1 FROM @disclosureChanges AS d WHERE d.ClientID = c.ClientID ) )

     MERGE  existingDocuments       AS tgt
     USING  #processDisclosureData  AS src
        ON  tgt.ClientID = src.ClientID
      WHEN  MATCHED AND DocumentDate IS NOT NULL THEN
            UPDATE  SET   DocumentDate  = src.ContractDate
                        , IsOnFile      = 1
                        , ModifiedDate  = src.ChangeDate
                        , ModifiedUser  = src.ChangeBy

      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( ClientID, ClientDocumentNameID, DocumentName
                        , ClientDocumentTypeID, DocumentDate
                        , IsOnFile, ModifiedDate, ModifiedUser )
            VALUES ( src.ClientID, 2, ''
                        , 0, src.ContractDate
                        , 1, src.ChangeDate, src.ChangeBy )
    OUTPUT  $action, inserted.ClientID INTO @disclosureMergeResults ;
    SELECT  @disclosureMERGEs = @@ROWCOUNT ;

-- 11)  UPDATE dbo.ClientDocument from #processClientDisclosureData to clear dropped disclosures
    UPDATE  dbo.ClientDocument
       SET  IsOnFile        = 0
          , DocumentName    = ''
          , DocumentDate    = '1900-01-01'
          , ModifiedDate    = d.ChangeDate
          , ModifiedUser    = d.ChangeBy
      FROM  dbo.ClientDocument     AS c
INNER JOIN  #processDisclosureData  AS d ON d.ClientID = c.ClientID
     WHERE  c.ClientDocumentNameID = 2 AND d.ContractDate IS NULL ;
    SELECT  @droppedDisclosuresActual = @@ROWCOUNT ;


-- 12)  SELECT control counts and validate
    SELECT  @newDisclosuresActual       = COUNT(*) FROM @disclosureMergeResults WHERE Action = 'INSERT' ;
    SELECT  @updatedDisclosuresActual   = COUNT(*) FROM @disclosureMergeResults WHERE Action = 'UPDATE' ;
    SELECT  @convertedDisclosuresActual = COUNT(*) FROM Conversion.vw_ConvertedClientDisclosure ;


    IF  ( @convertedDisclosuresActual <> ( @convertedDisclosuresCount + @newDisclosuresActual- @droppedDisclosuresActual ) )
        OR
        ( @convertedDisclosuresActual <> @legacyDisclosuresCount )
        OR
        ( @disclosureChangesCount <>  ( @newDisclosuresActual + @updatedDisclosuresActual + @droppedDisclosuresActual ) )
        OR
        ( @disclosureMERGEs <>  ( @newDisclosuresCount + @updatedDisclosuresCount ) )
        OR
        ( @disclosureChangesCount <>  @disclosureChangesActual )
        OR
        ( @newDisclosuresCount <>  @newDisclosuresActual )
        OR
        ( @updatedDisclosuresCount <> @updatedDisclosuresActual )
        OR
        ( @updatedDisclosuresCount <> @updatedDisclosuresActual )

    BEGIN
        PRINT 'Control Totals Error!  Please review counts and processing!' ;
        SELECT  @rc = 16 ;
    END


    GOTO    endOfProc ;

END TRY
BEGIN CATCH
    EXECUTE dbo.processEhlersError ;
END CATCH



endOfProc:
-- 10)  Reset CONTEXT_INFO to re-enable triggering on converted tables
    SET CONTEXT_INFO 0x0 ;


-- 11)  Print control totals
    PRINT 'Conversion.processClientDisclosure CONTROL TOTALS ' ;
    PRINT '' ;
    PRINT 'Existing Client Disclosures                  = ' + STR( @convertedDisclosuresCount, 8 ) ;
    PRINT '    + New Disclosures                        = ' + STR( @newDisclosuresCount, 8 ) ;
    PRINT '    - Dropped Disclosures                    = ' + STR( @droppedDisclosuresCount, 8 ) ;
    PRINT '                                               --------' ;
    PRINT 'Total Converted Client Disclosures           = ' + STR( @convertedDisclosuresActual, 8 ) ;
    PRINT '' ;
    PRINT 'Details of Database Changes ' ;
    PRINT '     UPDATEs dbo.Client                      = ' + STR( @disclosureChangesActual, 8 ) ;

    PRINT '     INSERTs dbo.ClientDocument              = ' + STR( @newDisclosuresActual, 8 ) ;
    PRINT '     UPDATEs dbo.ClientDocument ( changes )  = ' + STR( @updatedDisclosuresActual, 8 ) ;
    PRINT '     DELETEs dbo.ClientDocument ( drops )    = ' + STR( @droppedDisclosuresActual, 8 ) ;

    PRINT '                                               --------' ;
    PRINT 'Disclosure changes                           = ' + STR( @disclosureChangesActual, 8 ) ;

    PRINT '' ;

    RETURN @rc ;
END
