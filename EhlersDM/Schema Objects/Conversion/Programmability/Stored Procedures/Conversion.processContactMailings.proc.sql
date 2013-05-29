CREATE PROCEDURE Conversion.processContactMailings
AS
/*
************************************************************************************************************************************

  Procedure:  Conversion.processContactMailings
     Author:  Chris Carson
    Purpose:  converts legacy Contacts data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created
    mkiemen         2013-05-28          add return as first line of script to ensure script doesnt do anything
    

    Logic Summary:
    1)  Set CONTEXT_INFO to prevent converted tables from triggering changes
    2)  Create temp storage for changed data from source tables
    3)  Check for contact data changes, skip to check JobFunction data if no changes
    4)  load records where ContactID == 0, these are INSERTs to dbo.Contact
    5)  load records with different checksums, these are UPDATEs to dbo.Contact
    6)  exit procedure if no records changed, throw an error if this occurs!
    7)  MERGE #processContactsData into dbo.Contact
    8)  Apply legacy contact data to results from MERGE
    9)  Load dbo.FirmContacts with data from dbo.Contact INSERTs
    10) Load dbo.ClientContacts with data from dbo.Contact INSERTs
    11) Load Conversion.LegacyContacts with data from dbo.Contact INSERTs
    12) Check for changes in JobFunction data, skip to next section if no changes
    13) MERGE input data into dbo.ContactJobFunctions
    14) Check for changes in Mailings data, skip to procedure end if no changes
    15) MERGE mailings data into dbo.ContactMailings
    16) Reset CONTEXT_INFO to re-enable triggering on converted tables
    17) Print control totals

    Notes:

************************************************************************************************************************************
*/
BEGIN
    RETURN ;
    SET NOCOUNT ON ;


    DECLARE @processName            AS VARCHAR (100)    = 'processMailings'
          , @errorMessage           AS VARCHAR (MAX)    = NULL
          , @errorQuery             AS VARCHAR (MAX)    = NULL
          , @processMailings        AS VARBINARY (128)  = CAST( 'processMailings' AS VARBINARY(128) )
          , @processStartTime       AS DATETIME         = GETDATE()
          , @processEndTime         AS DATETIME         = NULL
          , @processElapsedTime     AS INT              = 0 ;

    DECLARE @changesCount           AS INT = 0
          , @convertedActual        AS INT = 0
          , @convertedChecksum      AS INT = 0
          , @convertedClientActual  AS INT = 0
          , @convertedClientCount   AS INT = 0
          , @convertedCount         AS INT = 0
          , @convertedFirmActual    AS INT = 0
          , @convertedFirmCount     AS INT = 0
          , @droppedClientCount     AS INT = 0
          , @droppedCount           AS INT = 0
          , @droppedFirmCount       AS INT = 0
          , @legacyChecksum         AS INT = 0
          , @legacyClientCount      AS INT = 0
          , @legacyCount            AS INT = 0
          , @legacyFirmCount        AS INT = 0
          , @newClientCount         AS INT = 0
          , @newCount               AS INT = 0
          , @newFirmCount           AS INT = 0
          , @recordClientDELETEs    AS INT = 0
          , @recordClientINSERTs    AS INT = 0
          , @recordClientUPDATEs    AS INT = 0
          , @recordDELETEs          AS INT = 0
          , @recordFirmDELETEs      AS INT = 0
          , @recordFirmINSERTs      AS INT = 0
          , @recordFirmUPDATEs      AS INT = 0
          , @recordINSERTs          AS INT = 0
          , @recordMERGEs           AS INT = 0
          , @recordUPDATEs          AS INT = 0
          , @updatedClientCount     AS INT = 0
          , @updatedCount           AS INT = 0
          , @updatedFirmCount       AS INT = 0 ;


    DECLARE @mailingMergeResults    AS TABLE( Action           NVARCHAR (10)
                                            , ContactID        INT
                                            , MailingTypeID    INT
                                            , OptOut           BIT
                                            , LegacyTableName  VARCHAR (20) ) ;


--  1)  Set CONTEXT_INFO to prevent converted tables from triggering changes
    SET CONTEXT_INFO @processMailings ;


--  2)  Create temp storage for changed data from source tables
BEGIN TRY
    IF  OBJECT_ID ('tempdb..#changedMailings') IS NOT NULL
        DROP TABLE  #changedMailings ;
    CREATE TABLE    #changedMailings (
        LegacyContactID     INT
      , LegacyTableName     VARCHAR(50)
      , ContactID           INT
      , MailingTypeID       INT
      , OptOut              BIT
      , ModifiedDate        DATETIME
      , ModifiedUser        VARCHAR (20) ) ;


--  3)  SELECT initial control counts
    SELECT  @legacyFirmCount = COUNT(*) FROM Conversion.tvf_ConvertedMailings ( 'Legacy' )
     WHERE  LegacyTableName = 'FirmContacts' ;

    SELECT  @legacyClientCount = COUNT(*) FROM Conversion.tvf_ConvertedMailings ( 'Legacy' )
     WHERE  LegacyTableName = 'ClientContacts' ;

    SELECT  @convertedFirmCount = COUNT(*) FROM Conversion.tvf_ConvertedMailings ( 'Converted' )
     WHERE  LegacyTableName = 'FirmContacts' ;

    SELECT  @convertedClientCount = COUNT(*) FROM Conversion.tvf_ConvertedMailings ( 'Converted' )
     WHERE  LegacyTableName = 'ClientContacts' ;

    SELECT  @legacyCount     = @legacyFirmCount    + @legacyClientCount
          , @convertedCount  = @convertedFirmCount + @convertedClientCount
          , @convertedActual = @legacyFirmCount    + @legacyClientCount ;


--  4)  Test for changes with CHECKSUMs, exit proc if there are none
    SELECT  @legacyChecksum     = CHECKSUM_AGG( CHECKSUM(*) ) FROM Conversion.tvf_ConvertedMailings( 'Legacy' ) ;
    SELECT  @convertedChecksum  = CHECKSUM_AGG( CHECKSUM(*) ) FROM Conversion.tvf_ConvertedMailings( 'Converted' ) ;

    IF  ( @legacyChecksum = @convertedChecksum )
        GOTO    endOfProc ;


--  5)  INSERT new Mailings into #changedMailings, SELECT control counts
      WITH  newRecords AS (
            SELECT * FROM Conversion.tvf_ConvertedMailings ( 'Legacy' ) AS l
             WHERE NOT EXISTS ( SELECT 1 FROM Conversion.tvf_ConvertedMailings ( 'Converted' ) AS c
                                 WHERE c.ContactID = l.ContactID AND c.MailingTypeID = l.MailingTypeID )  )
    INSERT  #changedMailings
    SELECT  LegacyContactID = c.LegacyContactID
          , LegacyTableName = c.LegacyTableName
          , ContactID       = c.ContactID
          , MailingTypeID   = n.MailingTypeID
          , OptOut          = n.OptOut
          , ModifiedDate    = c.ChangeDate
          , ModifiedUser    = ISNULL( NULLIF( c.ChangeBy, 'processContacts' ), 'processMailings' )
      FROM  newRecords AS n
INNER JOIN  Conversion.vw_LegacyContacts AS c ON c.ContactID = n.ContactID ;
    SELECT  @newFirmCount   = COUNT(*) FROM #changedMailings WHERE LegacyTableName = 'FirmContacts' ;
    SELECT  @newClientCount = COUNT(*) FROM #changedMailings WHERE LegacyTableName = 'ClientContacts' ;


--  5)  INSERT changed Mailings into #changedMailings, SELECT control counts
      WITH  updatedRecords AS (
            SELECT * FROM Conversion.tvf_ConvertedMailings ( 'Legacy' ) AS l
             WHERE EXISTS ( SELECT 1 FROM Conversion.tvf_ConvertedMailings ( 'Converted' ) AS c
                             WHERE c.ContactID = l.ContactID AND c.MailingTypeID = l.MailingTypeID AND c.OptOut <> l.OptOut ) )
    INSERT  #changedMailings
    SELECT  LegacyContactID = c.LegacyContactID
          , LegacyTableName = c.LegacyTableName
          , ContactID       = c.ContactID
          , MailingTypeID   = u.MailingTypeID
          , OptOut          = u.OptOut
          , ModifiedDate    = c.ChangeDate
          , ModifiedUser    = ISNULL( NULLIF( c.ChangeBy, 'processContacts' ), 'processMailings' )
      FROM  updatedRecords               AS u
INNER JOIN  Conversion.vw_LegacyContacts AS c ON c.ContactID = u.ContactID ;
    SELECT  @updatedFirmCount   = COUNT(*) FROM #changedMailings WHERE LegacyTableName = 'FirmContacts' ;
    SELECT  @updatedClientCount = COUNT(*) FROM #changedMailings WHERE LegacyTableName = 'ClientContacts' ;

    IF  ( @updatedFirmCount = @newFirmCount )
        SELECT  @updatedFirmCount = 0 ;
    ELSE
        SELECT  @updatedFirmCount = @updatedFirmCount - @newFirmCount ;

    IF  ( @updatedClientCount = @newClientCount )
        SELECT  @updatedClientCount = 0 ;
    ELSE
        SELECT  @updatedClientCount = @updatedClientCount - @newClientCount ;


--  5)  INSERT dropped Mailings into #changedMailings, SELECT control counts
      WITH  droppedRecords AS (
            SELECT * FROM Conversion.tvf_ConvertedMailings ( 'Converted' ) AS c
             WHERE NOT EXISTS ( SELECT 1 FROM Conversion.tvf_ConvertedMailings ( 'Converted' ) AS l
                                 WHERE l.ContactID = c.ContactID AND l.MailingTypeID = c.MailingTypeID ) )
    INSERT  #changedMailings
    SELECT  LegacyContactID = LegacyContactID
          , LegacyTableName = LegacyTableName
          , ContactID       = ContactID
          , MailingTypeID   = MailingTypeID
          , OptOut          = NULL
          , ModifiedDate    = NULL
          , ModifiedUser    = NULL
      FROM  droppedRecords
    SELECT  @droppedFirmCount   = COUNT(*) FROM #changedMailings WHERE LegacyTableName = 'FirmContacts' ;
    SELECT  @droppedClientCount = COUNT(*) FROM #changedMailings WHERE LegacyTableName = 'ClientContacts' ;

    IF  ( @droppedFirmCount = ( @updatedFirmCount + @newFirmCount ) )
        SELECT  @droppedFirmCount = 0 ;
    ELSE
        SELECT  @droppedFirmCount = @droppedFirmCount - @updatedFirmCount - @newFirmCount ;

    IF  ( @droppedClientCount = ( @updatedClientCount + @newClientCount ) )
        SELECT  @droppedClientCount = 0 ;
    ELSE
        SELECT  @droppedClientCount = @droppedClientCount - @updatedClientCount - @newClientCount ;


--  5)  INSERT unaffected Mailings ( these are required in order to update all records in new system )
      WITH  unchangedRecords AS (
            SELECT * FROM Conversion.tvf_ConvertedMailings ( 'Legacy' ) AS l
             WHERE EXISTS ( SELECT 1 FROM Conversion.tvf_ConvertedMailings ( 'Converted' ) AS c
                             WHERE c.ContactID = l.ContactID AND c.MailingTypeID = l.MailingTypeID AND c.OptOut = l.OptOut ) )
    INSERT  #changedMailings
    SELECT  LegacyContactID = c.LegacyContactID
          , LegacyTableName = c.LegacyTableName
          , ContactID       = c.ContactID
          , MailingTypeID   = u.MailingTypeID
          , OptOut          = u.OptOut
          , ModifiedDate    = c.ChangeDate
          , ModifiedUser    = ISNULL( NULLIF( c.ChangeBy, 'processContacts' ), 'processMailings' )
      FROM  unchangedRecords             AS u
INNER JOIN  Conversion.vw_LegacyContacts AS c ON c.ContactID = u.ContactID ;

--  8)  SELECT control counts
    SELECT  @newCount       = @newFirmCount     + @newClientCount
          , @updatedCount   = @updatedFirmCount + @updatedClientCount
          , @droppedCount   = @droppedFirmCount + @droppedClientCount ;

    SELECT  @changesCount   = @newCount + @updatedCount + @droppedCount ;


--  9)  MERGE #changedMailings into dbo.ContactMailings
      WITH  mailings AS (
            SELECT  ContactID, MailingTypeID, OptOut, ModifiedDate, ModifiedUser
              FROM  #changedMailings ) ,

            currentData AS (
            SELECT * FROM dbo.ContactMailings WHERE ContactID IN ( SELECT ContactID FROM mailings ) )

     MERGE  currentData AS tgt
     USING  mailings    AS src ON tgt.ContactID = src.ContactID AND tgt.MailingTypeID = src.MailingTypeID
      WHEN  MATCHED AND src.OptOut <> tgt.OptOut THEN
            UPDATE SET  OptOut       = src.OptOut
                      , OptOutDate   = CASE src.OptOut WHEN 1 THEN src.ModifiedDate ELSE NULL END
                      , ModifiedDate = src.ModifiedDate
                      , ModifiedUser = src.ModifiedUser
      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( ContactID
                   , MailingTypeID
                   , DeliveryMethodID
                   , OptOut
                   , OptOutDate
                   , ModifiedDate
                   , ModifiedUser )
            VALUES ( src.ContactID
                   , src.MailingTypeID
                   , 3
                   , src.OptOut
                   , CASE src.OptOut WHEN 1 THEN src.ModifiedDate ELSE NULL END
                   , src.ModifiedDate
                   , src.ModifiedUser )
      WHEN  NOT MATCHED BY SOURCE THEN
            DELETE
    OUTPUT  $action
          , ISNULL( inserted.ContactID, deleted.ContactID )
          , ISNULL( inserted.MailingTypeID, deleted.MailingTypeID )
          , ISNULL( inserted.OptOut, deleted.OptOut )
      INTO  @mailingMergeResults ( Action, ContactID, MailingTypeID, OptOut ) ;
    SELECT  @recordMERGEs = @@ROWCOUNT ;


-- 10)  UPDATE @mailingMergeResults with LegacyTableName
    UPDATE  @mailingMergeResults
       SET  LegacyTableName = b.LegacyTableName
      FROM  @mailingMergeResults AS a
INNER JOIN  #changedMailings     AS b ON b.ContactID = a.ContactID ;


-- 11)  SELECT control counts and validate
    SELECT  @recordFirmINSERTs = COUNT(*) FROM @mailingMergeResults
     WHERE  Action = 'INSERT' AND LegacyTableName = 'FirmContacts' ;

    SELECT  @recordFirmUPDATEs = COUNT(*) FROM @mailingMergeResults
     WHERE  Action = 'UPDATE' AND LegacyTableName = 'FirmContacts' ;

    SELECT  @recordFirmDELETEs = COUNT(*) FROM @mailingMergeResults
     WHERE  Action = 'DELETE' AND LegacyTableName = 'FirmContacts' ;

    SELECT  @recordClientINSERTs = COUNT(*) FROM @mailingMergeResults
     WHERE  Action = 'INSERT' AND LegacyTableName = 'ClientContacts' ;

    SELECT  @recordClientUPDATEs = COUNT(*) FROM @mailingMergeResults
     WHERE  Action = 'UPDATE' AND LegacyTableName = 'ClientContacts' ;

    SELECT  @recordClientDELETEs = COUNT(*) FROM @mailingMergeResults
     WHERE  Action = 'DELETE' AND LegacyTableName = 'ClientContacts' ;

    SELECT  @convertedFirmActual = COUNT(*) FROM Conversion.tvf_ConvertedMailings ( 'Converted' )
     WHERE  LegacyTableName = 'FirmContacts' ;

    SELECT  @convertedClientActual  = COUNT(*) FROM Conversion.tvf_ConvertedMailings ( 'Converted' )
     WHERE  LegacyTableName = 'ClientContacts' ;

    SELECT  @recordINSERTs = @recordFirmINSERTs + @recordClientINSERTs
          , @recordUPDATEs = @recordFirmUPDATEs + @recordClientUPDATEs
          , @recordDELETEs = @recordFirmDELETEs + @recordClientDELETEs
          , @convertedActual = @convertedFirmActual + @convertedClientActual ;

    IF  ( @convertedActual <> ( @convertedCount + @recordINSERTs - @recordDELETEs ) )
        OR
        ( @convertedActual <> @legacyCount )
        OR
        ( @convertedFirmActual <> ( @convertedFirmCount + @recordFirmINSERTs - @recordFirmDELETEs ) )
        OR
        ( @convertedClientActual <> ( @convertedClientCount + @recordClientINSERTs - @recordClientDELETEs ) )
        OR
        ( @recordFirmINSERTs <> @newFirmCount )
        OR
        ( @recordClientINSERTs <> @newClientCount )
        OR
        ( @recordFirmUPDATEs <> @updatedFirmCount )
        OR
        ( @recordClientUPDATEs <> @updatedClientCount )
        OR
        ( @recordFirmDELETEs <> @droppedFirmCount )
        OR
        ( @recordClientDELETEs <> @droppedClientCount )
        OR
        ( @recordMERGEs <> @changesCount )
        OR
        ( @changesCount <> ( @recordINSERTs + @recordUPDATEs + @recordDELETEs ) )

    BEGIN
        PRINT '' ;
        PRINT 'Control Totals Error!  Please review counts and processing!' ;
        PRINT '' ;
        PRINT '@convertedActual         = ' + STR( @convertedActual, 8 ) ;
        PRINT '@convertedCount          = ' + STR( @convertedCount, 8 ) ;
        PRINT '@recordINSERTs           = ' + STR( @recordINSERTs, 8 ) ;
        PRINT '@recordDELETEs           = ' + STR( @recordDELETEs, 8 ) ;
        PRINT '' ;
        PRINT '@convertedActual         = ' + STR( @convertedActual, 8 ) ;
        PRINT '@legacyCount             = ' + STR( @legacyCount, 8 ) ;
        PRINT '' ;
        PRINT '@convertedFirmActual     = ' + STR( @convertedFirmActual, 8 ) ;
        PRINT '@convertedFirmCount      = ' + STR( @convertedFirmCount, 8 ) ;
        PRINT '@recordFirmINSERTs       = ' + STR( @recordFirmINSERTs, 8 ) ;
        PRINT '@recordFirmDELETEs       = ' + STR( @recordFirmDELETEs, 8 ) ;
        PRINT '' ;
        PRINT '@convertedClientActual   = ' + STR( @convertedClientActual, 8 ) ;
        PRINT '@convertedClientCount    = ' + STR( @convertedClientCount, 8 ) ;
        PRINT '@recordClientINSERTs     = ' + STR( @recordClientINSERTs, 8 ) ;
        PRINT '@recordClientDELETEs     = ' + STR( @recordClientDELETEs, 8 ) ;
        PRINT '' ;
        PRINT '@recordFirmINSERTs       = ' + STR( @recordFirmINSERTs, 8 ) ;
        PRINT '@newFirmCount            = ' + STR( @newFirmCount, 8 ) ;
        PRINT '' ;
        PRINT '@recordClientINSERTs     = ' + STR( @recordClientINSERTs, 8 ) ;
        PRINT '@newClientCount          = ' + STR( @newClientCount, 8 ) ;
        PRINT '' ;
        PRINT '@recordFirmUPDATEs       = ' + STR( @recordFirmUPDATEs, 8 ) ;
        PRINT '@updatedFirmCount        = ' + STR( @updatedFirmCount, 8 ) ;
        PRINT '' ;
        PRINT '@recordClientUPDATEs     = ' + STR( @recordClientUPDATEs, 8 ) ;
        PRINT '@updatedClientCount      = ' + STR( @updatedClientCount, 8 ) ;
        PRINT '' ;
        PRINT '@recordFirmDELETEs       = ' + STR( @recordFirmDELETEs, 8 ) ;
        PRINT '@droppedFirmCount        = ' + STR( @droppedFirmCount, 8 ) ;
        PRINT '' ;
        PRINT '@recordClientDELETEs     = ' + STR( @recordClientDELETEs, 8 ) ;
        PRINT '@droppedClientCount      = ' + STR( @droppedClientCount, 8 ) ;
        PRINT '' ;
        PRINT '@recordMERGEs            = ' + STR( @recordMERGEs, 8 ) ;
        PRINT '@changesCount            = ' + STR( @changesCount, 8 ) ;
        PRINT '' ;
        PRINT '@changesCount            = ' + STR( @changesCount, 8 ) ;
        PRINT '@recordINSERTs           = ' + STR( @recordINSERTs, 8 ) ;
        PRINT '@recordUPDATEs           = ' + STR( @recordUPDATEs, 8 ) ;
        PRINT '@recordDELETEs           = ' + STR( @recordDELETEs, 8 ) ;
        PRINT '' ;
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

    PRINT   'Conversion.processContactMailings CONTROL TOTALS ' ;
    PRINT   '' ;
    PRINT   'Existing Mailings                       = ' + STR( @convertedCount, 8 ) ;
    PRINT   '     new records                        = ' + STR( @recordINSERTs, 8 ) ;
    PRINT   '         FirmContact                    = ' + STR( @recordFirmINSERTs, 8 ) ;
    PRINT   '         ClientContact                  = ' + STR( @recordClientINSERTs, 8 ) ;
    PRINT   '' ;
    PRINT   '     changed records                    = ' + STR( @recordUPDATEs, 8 ) ;
    PRINT   '         FirmContact                    = ' + STR( @recordFirmUPDATEs, 8 ) ;
    PRINT   '         ClientContact                  = ' + STR( @recordClientUPDATEs, 8 ) ;
    PRINT   '' ;
    PRINT   '     dropped records                    = ' + STR( @recordDELETEs, 8 ) ;
    PRINT   '         FirmContact                    = ' + STR( @recordFirmDELETEs, 8 ) ;
    PRINT   '         ClientContact                  = ' + STR( @recordClientDELETEs, 8 ) ;
    PRINT   '' ;
    PRINT   '     Total Converted Mailings           = ' + STR( @convertedActual, 8 ) ;
    PRINT   '' ;
    PRINT   'Database Change Details ' ;
    PRINT   '     Total INSERTs dbo.ContactMailings  = ' + STR( @recordINSERTs, 8 ) ;
    PRINT   '         INSERTs FirmContacts           = ' + STR( @recordFirmINSERTs, 8 ) ;
    PRINT   '         INSERTs ClientContacts         = ' + STR( @recordClientINSERTs, 8 ) ;
    PRINT   '' ;
    PRINT   '     Total UPDATEs dbo.ContactMailings  = ' + STR( @recordUPDATEs, 8 ) ;
    PRINT   '         UPDATEs FirmContacts           = ' + STR( @recordFirmUPDATEs, 8 ) ;
    PRINT   '         UPDATEs ClientContacts         = ' + STR( @recordClientUPDATEs, 8 ) ;
    PRINT   '' ;
    PRINT   '     Total DELETEs dbo.ContactMailings  = ' + STR( @recordDELETEs, 8 ) ;
    PRINT   '         DELETEs FirmContacts           = ' + STR( @recordFirmDELETEs, 8 ) ;
    PRINT   '         DELETEs ClientContacts         = ' + STR( @recordClientDELETEs, 8 ) ;
    PRINT   '' ;
    PRINT   '     TOTAL database changes             = ' + STR( @recordMERGEs, 8 ) ;
    PRINT   '' ;

END
