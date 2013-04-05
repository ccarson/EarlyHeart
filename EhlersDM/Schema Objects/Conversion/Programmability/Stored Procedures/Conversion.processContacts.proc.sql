CREATE PROCEDURE Conversion.processContacts
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
    2)  CREATE temp storage for changed data from source tables
    3)  SELECT initial control counts
    4)  Test for changes with CHECKSUMs, exit proc if there are none
    5)  INSERT new contact data into #processContactsData, SELECT control counts
    6)  INSERT modified contact data into #processContactsData, SELECT control counts
    7)  INSERT deleted legacy contacts into #processContactsData, SELECT control counts
    8)  MERGE #processContactsData into dbo.Contact, processing INSERTs and UPDATEs
    9)  UPDATE @contactMergeResults with legacy Contacts data
   10)  INSERT to dbo.FirmContacts with saved data from dbo.Contact INSERTs
   11)  INSERT to dbo.ClientContacts with saved data from dbo.Contact INSERTs
   12)  INSERT to Conversion.LegacyContacts saved data from dbo.Contact INSERTs
   13)  UPDATE dbo.Contact with legacy deleted data, SELECT control counts
   14)  DELETE Conversion.LegacyContacts records for inactive dbo.Contact records
   15)  SELECT control counts and validate
   16)  Reset CONTEXT_INFO to re-enable triggering on converted tables
   17)  Print control totals


    Notes:


************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;

    DECLARE @rc                             AS INT             = 0
          , @processName                    AS VARCHAR   (100) = 'processContacts'
          , @processDate                    AS DATETIME        = GETDATE()
          , @errorMessage                   AS VARCHAR   (MAX) = NULL
          , @errorQuery                     AS VARCHAR   (MAX) = NULL
          , @processContacts                AS VARBINARY (128) = CAST( 'processContacts' AS varbinary (128) ) ;


    DECLARE @contactChangesCount            AS INT = 0
          , @contactsMERGEdActual           AS INT = 0
          , @convertedContactsActual        AS INT = 0
          , @convertedContactsCount         AS INT = 0
          , @currentContactID               AS INT = 0
          , @deletedClientContactsActual    AS INT = 0
          , @deletedClientContactsCount     AS INT = 0
          , @deletedContactsActual          AS INT = 0
          , @deletedContactsCount           AS INT = 0
          , @deletedFirmContactsActual      AS INT = 0
          , @deletedFirmContactsCount       AS INT = 0
          , @legacyContactsCount            AS INT = 0
          , @newClientContactsActual        AS INT = 0
          , @newClientContactsCount         AS INT = 0
          , @newContactsActual              AS INT = 0
          , @newContactsCount               AS INT = 0
          , @newFirmContactsActual          AS INT = 0
          , @newFirmContactsCount           AS INT = 0
          , @updatedClientContactsActual    AS INT = 0
          , @updatedClientContactsCount     AS INT = 0
          , @updatedContactsActual          AS INT = 0
          , @updatedContactsCount           AS INT = 0
          , @updatedFirmContactsActual      AS INT = 0
          , @updatedFirmContactsCount       AS INT = 0 ;


    DECLARE @contactMergeResults AS TABLE( Action            NVARCHAR (10)
                                         , LegacyContactID   INT
                                         , LegacyTableName   VARCHAR (30)
                                         , ContactID         INT
                                         , SourceID          INT
                                         , ChangeDate        DATETIME
                                         , ChangeBy          VARCHAR(30) ) ;

    BEGIN TRY

--  1)  Set CONTEXT_INFO to prevent converted tables from triggering changes
    SET CONTEXT_INFO @processContacts ;


--  2)  Create temp storage for changed data from source tables
    IF  OBJECT_ID('tempdb..#processContactsData') IS NOT NULL
        DROP TABLE  #processContactsData ;

    CREATE TABLE    #processContactsData (
        ContactID           INT     NOT NULL    PRIMARY KEY CLUSTERED
      , LegacyContactID     INT
      , LegacyTableName     VARCHAR(50)
      , SourceID            INT
      , NamePrefix          VARCHAR(5)
      , FirstName           VARCHAR(50)
      , LastName            VARCHAR(100)
      , Department          VARCHAR(50)
      , Title               VARCHAR(50)
      , Phone               VARCHAR(25)
      , Extension           VARCHAR(10)
      , Fax                 VARCHAR(25)
      , CellPhone           VARCHAR(25)
      , Email               VARCHAR(75)
      , Notes               VARCHAR(MAX)
      , ChangeDate          DATETIME
      , ChangeBy            VARCHAR(50) ) ;


--  3)  SELECT initial control counts
    SELECT  @legacyContactsCount        = COUNT(*) FROM Conversion.vw_LegacyContacts ;
    SELECT  @convertedContactsCount     = COUNT(*) FROM Conversion.vw_ConvertedContacts ;
    SELECT  @convertedContactsActual    = @convertedContactsCount ;


--  4)  Test for changes with CHECKSUMs, exit proc if there are none
    IF  EXISTS ( SELECT CHECKSUM_AGG( CHECKSUM(*) ) FROM Conversion.tvf_ContactChecksum ( 'Legacy' )
                    EXCEPT
                 SELECT CHECKSUM_AGG( CHECKSUM(*) ) FROM Conversion.tvf_ContactChecksum ( 'Converted' ) )
        PRINT 'migrating changed Contacts data' ;
    ELSE
        BEGIN
            PRINT   'no changes on legacy Contacts data, exiting' ;
            GOTO    endOfProc ;
        END


--  5)  INSERT new contact data into #processContactsData, SELECT control counts
    SELECT  @currentContactID = ISNULL( MAX(ContactID), 0 ) FROM dbo.Contact ;

    INSERT  #processContactsData
    SELECT  ContactID = @currentContactID + ROW_NUMBER() OVER ( ORDER BY (SELECT NULL) )
                , LegacyContactID, LegacyTableName, SourceID
                , NamePrefix, FirstName, LastName, Department, Title
                , Phone, Extension, Fax, CellPhone, Email, Notes
                , ChangeDate, ChangeBy
      FROM  Conversion.vw_LegacyContacts AS l
     WHERE  ContactID = 0 ;
    SELECT  @newContactsCount = @@ROWCOUNT ;

    SELECT  @newFirmContactsCount   = COUNT(*) FROM #processContactsData WHERE LegacyTableName = 'FirmContacts' ;
    SELECT  @newClientContactsCount = COUNT(*) FROM #processContactsData WHERE LegacyTableName = 'ClientContacts' ;


--  6)  INSERT modified contact data into #processContactsData, SELECT control counts
      WITH  changes AS (
            SELECT  l.ContactID
              FROM  Conversion.tvf_ContactChecksum ( 'Legacy' ) AS l
        INNER JOIN  Conversion.tvf_ContactChecksum ( 'Converted' ) AS c ON c.ContactID = l.ContactID
             WHERE  l.ContactChecksum <> c.ContactChecksum )

    INSERT  #processContactsData
    SELECT  ContactID, LegacyContactID, LegacyTableName, SourceID
                , NamePrefix, FirstName, LastName
                , Department, Title
                , Phone, Extension, Fax, CellPhone
                , Email, Notes
                , ChangeDate, ChangeBy
      FROM  Conversion.vw_LegacyContacts AS l
     WHERE  EXISTS ( SELECT 1 FROM changes AS c WHERE c.ContactID = l.ContactID ) ;
    SELECT  @updatedContactsCount = @@ROWCOUNT ;

    SELECT  @updatedFirmContactsCount   = COUNT(*) FROM  #processContactsData WHERE LegacyTableName = 'FirmContacts' ;
    SELECT  @updatedClientContactsCount = COUNT(*) FROM  #processContactsData WHERE LegacyTableName = 'ClientContacts' ;

    SELECT  @updatedFirmContactsCount   = @updatedFirmContactsCount - @newFirmContactsCount ;
    SELECT  @updatedClientContactsCount = @updatedClientContactsCount - @newClientContactsCount ;


--  7)  INSERT deleted legacy contacts into #processContactsData, SELECT control counts
      WITH  deletes AS (
            SELECT  ContactID, LegacyContactID, LegacyTableName
              FROM  Conversion.tvf_ContactChecksum ( 'Converted' ) AS c
             WHERE  NOT EXISTS ( SELECT 1 FROM Conversion.vw_LegacyContacts AS l
                                  WHERE l.LegacyTableName = c.LegacyTableName AND l.LegacyContactID = c.LegacyContactID ) )

    INSERT  #processContactsData ( ContactID, LegacyContactID, LegacyTableName )
    SELECT  ContactID, 0, LegacyTableName
      FROM  deletes
    SELECT  @deletedContactsCount = @@ROWCOUNT ;

    SELECT  @deletedFirmContactsCount   = COUNT(*) FROM  #processContactsData
     WHERE  LegacyTableName = 'FirmContacts' AND LegacyContactID = 0 ;
    SELECT  @deletedClientContactsCount = COUNT(*) FROM  #processContactsData
     WHERE  LegacyTableName = 'ClientContacts' AND LegacyContactID = 0 ;

    SELECT  @contactChangesCount = COUNT(*) FROM #processContactsData ;


--  8)  MERGE #processContactsData into dbo.Contact, processing INSERTs and UPDATEs
    SET IDENTITY_INSERT dbo.Contact ON ;

     MERGE  dbo.Contact          AS tgt
     USING  #processContactsData AS src
        ON  tgt.ContactID = src.ContactID
      WHEN  MATCHED AND src.LegacyContactID <> 0 THEN
            UPDATE SET  NamePrefix   = src.NamePrefix
                      , FirstName    = src.FirstName
                      , LastName     = src.LastName
                      , Title        = src.Title
                      , Department   = src.Department
                      , Phone        = src.Phone
                      , Extension    = src.Extension
                      , Fax          = src.Fax
                      , CellPhone    = src.CellPhone
                      , Email        = src.Email
                      , Notes        = src.Notes
                      , Active       = 1
                      , ModifiedDate = src.ChangeDate
                      , ModifiedUser = src.ChangeBy
      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( ContactID, NamePrefix, FirstName, LastName
                        , Title, Department, Phone, Extension, Fax, CellPhone
                        , Email, Notes, Active
                        , ModifiedDate, ModifiedUser )
            VALUES ( src.ContactID, src.NamePrefix
                        , src.FirstName, src.LastName
                        , src.Title, src.Department
                        , src.Phone, src.Extension
                        , src.Fax, src.CellPhone
                        , src.Email, src.Notes
                        , 1, src.ChangeDate, src.ChangeBy )
    OUTPUT  $action, inserted.ContactID, inserted.ModifiedDate, inserted.ModifiedUser
      INTO  @contactMergeResults ( Action, ContactID, ChangeDate, ChangeBy ) ;
    SELECT  @contactsMERGEdActual = @@ROWCOUNT ;

    SET IDENTITY_INSERT dbo.Contact OFF ;


--  9)  UPDATE @contactMergeResults with legacy Contacts data
    UPDATE  @contactMergeResults
       SET  LegacyContactID = pcd.LegacyContactID
          , LegacyTableName = pcd.LegacyTableName
          , SourceID        = pcd.SourceID
      FROM  @contactMergeResults AS cc
INNER JOIN  #processContactsData AS pcd
        ON  pcd.ContactID = cc.ContactID ;


--  10) INSERT to dbo.FirmContacts with saved data from dbo.Contact INSERTs
    INSERT  dbo.FirmContacts ( FirmID, ContactID, ModifiedDate, ModifiedUser )
    SELECT  SourceID, ContactID, ChangeDate, ChangeBy
      FROM  @contactMergeResults
     WHERE  LegacyTableName = 'FirmContacts' AND Action = 'INSERT' ;
    SELECT  @newFirmContactsActual = @@ROWCOUNT ;


--  11) INSERT to dbo.ClientContacts with saved data from dbo.Contact INSERTs
    INSERT  dbo.ClientContacts ( ClientID, ContactID, ModifiedDate, ModifiedUser )
    SELECT  SourceID, ContactID, ChangeDate, ChangeBy
      FROM  @contactMergeResults
     WHERE  LegacyTableName = 'ClientContacts' AND Action = 'INSERT' ;
    SELECT  @newClientContactsActual = @@ROWCOUNT ;


--  12) INSERT to Conversion.LegacyContacts saved data from dbo.Contact INSERTs
    INSERT  Conversion.LegacyContacts ( ContactID, LegacyContactID, LegacyTableName )
    SELECT  ContactID, LegacyContactID, LegacyTableName
      FROM  @contactMergeResults
     WHERE  Action = 'INSERT' ;


--  13) UPDATE dbo.Contact with legacy deleted data, SELECT control counts
    UPDATE  dbo.Contact
       SET  Active = 0
          , ModifiedDate = @processDate
          , ModifiedUser = @processName
      FROM  dbo.Contact AS c
     WHERE  EXISTS ( SELECT 1 FROM #processContactsData AS x WHERE x.ContactID = c.ContactID AND x.LegacyContactID = 0 ) ;
    SELECT  @deletedContactsActual = @@ROWCOUNT ;

    SELECT  @deletedFirmContactsActual = COUNT(*)
      FROM  dbo.Contact AS c
     WHERE  c.Active = 0
       AND  EXISTS ( SELECT 1 FROM Conversion.LegacyContacts AS l
                      WHERE l.ContactID = c.ContactID AND l.LegacyTableName = 'FirmContacts' ) ;

    SELECT  @deletedClientContactsActual = COUNT(*)
      FROM  dbo.Contact AS c
     WHERE  c.Active = 0
       AND  EXISTS ( SELECT 1 FROM Conversion.LegacyContacts AS l
                      WHERE l.ContactID = c.ContactID AND l.LegacyTableName = 'ClientContacts' ) ;


--  14) DELETE Conversion.LegacyContacts records for inactive dbo.Contact records
      WITH  inactiveContacts AS (
            SELECT * FROM Conversion.LegacyContacts AS lc
             WHERE EXISTS ( SELECT 1 FROM dbo.Contact AS c WHERE c.ContactID = lc.ContactID AND c.Active = 0 ) )
    DELETE  inactiveContacts ;


--  15) SELECT control counts and validate
    SELECT  @newContactsActual       = COUNT(*) FROM @contactMergeResults WHERE Action = 'INSERT' ;
    SELECT  @updatedContactsActual   = COUNT(*) FROM @contactMergeResults WHERE Action = 'UPDATE' ;
    SELECT  @convertedContactsActual = COUNT(*) FROM Conversion.vw_ConvertedContacts ;


    IF  ( @convertedContactsActual <> ( @convertedContactsCount + @newContactsCount  - @deletedContactsCount ) )
        OR
        ( @convertedContactsActual <> @legacyContactsCount )
        OR
        ( @newContactsCount <> ( @newFirmContactsActual + @newClientContactsActual ) )
        OR
        ( @updatedContactsCount <> ( @updatedFirmContactsActual + @updatedClientContactsActual ) )
        OR
        ( @deletedContactsCount <> ( @deletedFirmContactsActual + @deletedClientContactsActual ) )
        OR
        ( @contactChangesCount <> ( @newContactsActual + @updatedContactsActual + @deletedContactsActual ) )
    BEGIN
        PRINT 'Control Totals Error!  Please review counts and processing!' ;
        SELECT  @rc = 16 ;
    END

    END TRY
    BEGIN CATCH
        EXECUTE dbo.processEhlersError ;
    END CATCH


endOfProc:
--  16) Reset CONTEXT_INFO to re-enable triggering on converted tables
    SET CONTEXT_INFO 0x0 ;


--  17) Print control totals
    PRINT 'Conversion.processContacts CONTROL TOTALS ' ;

    PRINT 'Existing Contacts                        = ' + STR( @convertedContactsCount, 8 ) ;
    PRINT '    + New Contacts                       = ' + STR( @newContactsCount, 8 ) ;
    PRINT '        Firm Contacts        = '             + STR( @newFirmContactsCount, 8 ) ;
    PRINT '        Client Contacts      = '             + STR( @newClientContactsCount, 8 ) ;

    PRINT '    - Deleted Contacts                   = ' + STR( @deletedContactsCount, 8 ) ;
    PRINT '        Firm Contacts        = '             + STR( @deletedFirmContactsCount, 8 ) ;
    PRINT '        Client Contacts      = '             + STR( @deletedClientContactsCount, 8 ) ;

    PRINT '                                           --------' ;
    PRINT 'Total Converted Contacts                 = ' + STR( @convertedContactsActual, 8 ) ;

    PRINT 'Details of Database Changes ' ;
    PRINT '    INSERTs dbo.Contact                  = ' + STR( @newContactsActual, 8 ) ;
    PRINT '    INSERTs dbo.FirmContacts             = ' + STR( @newFirmContactsActual, 8 ) ;
    PRINT '    INSERTs dbo.ClientContacts           = ' + STR( @newClientContactsActual, 8 ) ;
    PRINT '    INSERTs Conversion.LegacyContacts    = ' + STR( @newContactsActual, 8 ) ;

    PRINT '    UPDATEs dbo.Contact                  = ' + STR( @updatedContactsActual, 8 ) ;
    PRINT '    UPDATEs dbo.FirmContacts             = ' + STR( @updatedFirmContactsActual, 8 ) ;
    PRINT '    UPDATEs dbo.ClientContacts           = ' + STR( @updatedClientContactsActual, 8 ) ;

    PRINT '' ;

    RETURN @rc ;
END
