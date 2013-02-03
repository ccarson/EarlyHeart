CREATE PROCEDURE Conversion.processAddresses
AS
/*
************************************************************************************************************************************

  Procedure:    Conversion.processAddresses
     Author:    Chris Carson
    Purpose:    converts legacy Address data from sources


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Set CONTEXT_INFO to prevent converted tables from triggering changes
    2)  Create temp storage for changed address data
    3)  Check for address changes, and exit if none
    4)  load records where AddressID is 0, these are INSERTs
    5)  load records where AddressID != 0, these are UPDATEs
    6)  Throw error if no records are loaded
    7)  MERGE #processAddressData with dbo.Address
    8)  Load @AddressChanges from 7) with legacy address data
    9)  INSERT dbo.FirmAddresses data from @AddressChanges
   10)  INSERT dbo.ClientAddresses data from @AddressChanges
   11)  INSERT dbo.ContactAddresses data from @AddressChanges
   12)  INSERT Conversion.LegacyAddresses to link legacy data to converted dbo.Address table
   13)  Reset CONTEXT_INFO to re-enable converted table triggers
   14)  Print out control totals.

   Notes:

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;

    DECLARE @rc                            AS INT = 0
          , @changedClientAddress          AS INT = 0
          , @changedClientContactAddress   AS INT = 0
          , @changedFirmAddress            AS INT = 0
          , @changedFirmContactAddress     AS INT = 0
          , @currentAddressID              AS INT = 0
          , @deletedClientAddress          AS INT = 0
          , @deletedClientContactAddress   AS INT = 0
          , @deletedFirmAddress            AS INT = 0
          , @deletedFirmContactAddress     AS INT = 0
          , @dletClientAddress             AS INT = 0
          , @dletClientContactAddress      AS INT = 0
          , @dletFirmAddress               AS INT = 0
          , @dletFirmContactAddress        AS INT = 0
          , @isrtClientAddress             AS INT = 0
          , @isrtClientContactAddress      AS INT = 0
          , @isrtFirmAddress               AS INT = 0
          , @isrtFirmContactAddress        AS INT = 0
          , @newClientAddress              AS INT = 0
          , @newClientContactAddress       AS INT = 0
          , @newFirmAddress                AS INT = 0
          , @newFirmContactAddress         AS INT = 0
          , @recordsDELETEd                AS INT = 0
          , @recordsINSERTed               AS INT = 0
          , @recordsMERGEd                 AS INT = 0
          , @recordsToDelete               AS INT = 0
          , @recordsToInsert               AS INT = 0
          , @recordsToUpdate               AS INT = 0
          , @recordsUPDATEd                AS INT = 0
          , @totalRecords                  AS INT = 0
          , @updtClientAddress             AS INT = 0
          , @updtClientContactAddress      AS INT = 0
          , @updtFirmAddress               AS INT = 0
          , @updtFirmContactAddress        AS INT = 0
          , @ts                            AS VARCHAR(20)
          , @processAddresses              AS VARBINARY(128) = CAST( 'processAddresses' AS VARBINARY(128) ) ;


--  1)  Set CONTEXT_INFO to prevent converted tables from triggering changes
    SET CONTEXT_INFO @processAddresses ;


--  2)  Create temp storage for changed address data
    IF  OBJECT_ID( 'tempdb..#processAddressData' ) IS NOT NULL
        DROP TABLE  #processAddressData ;
      CREATE TABLE  #processAddressData (
             AddressID       INT     NOT NULL    PRIMARY KEY CLUSTERED
           , LegacyTableName VARCHAR(30)
           , LegacyID        INT
           , Address1        VARCHAR(50)
           , Address2        VARCHAR(50)
           , City            VARCHAR(50)
           , [State]         VARCHAR(5)
           , Zip             VARCHAR(10)
           , ChangeDate      DATETIME
           , ChangeBy        VARCHAR(50) ) ;

    IF  OBJECT_ID ('tempdb..#changedAddresses') IS NOT NULL
        DROP  TABLE  #changedAddresses ;
      CREATE  TABLE  #changedAddresses (
             LegacyID           INT
           , LegacyTableName    VARCHAR(30)
           , AddressID          INT
           , AddressChecksum    VARBINARY(128) ) ;


--  3)  Check for address changes, and exit if none
    INSERT  #changedAddresses
    SELECT  LegacyID, LegacyTableName, AddressID, AddressChecksum FROM Conversion.tvf_AddressChecksum( 'Firms' )
        UNION ALL
    SELECT  LegacyID, LegacyTableName, AddressID, AddressChecksum FROM Conversion.tvf_AddressChecksum( 'Clients' )
        UNION ALL
    SELECT  LegacyID, LegacyTableName, AddressID, AddressChecksum FROM Conversion.tvf_AddressChecksum( 'FirmContacts' )
        UNION ALL
    SELECT  LegacyID, LegacyTableName, AddressID, AddressChecksum FROM Conversion.tvf_AddressChecksum( 'ClientContacts' )
        EXCEPT
    SELECT  LegacyID, LegacyTableName, AddressID, AddressChecksum FROM Conversion.tvf_AddressChecksum( 'Address' ) ;
    SELECT  @totalRecords = @@ROWCOUNT ;

    IF  ( @totalRecords = 0  )
        BEGIN
            PRINT 'Address data unchanged, has changed, processAddresses ending' ;
            GOTO endOfProc ;
        END
    ELSE
        PRINT 'Data has changed, migrating legacy Address data' ;


--  4)  load records where AddressID is 0, these are INSERTs
    SELECT  @currentAddressID = ISNULL( IDENT_CURRENT('dbo.Address'), 0 ) ;

    INSERT  #processAddressData
    SELECT  AddressID           = @currentAddressID + ROW_NUMBER() OVER ( ORDER BY (SELECT NULL) )
          , LegacyTableName     = LegacyTableName
          , LegacyID            = LegacyID
          , Address1            = Address1
          , Address2            = Address2
          , City                = City
          , [State]             = [State]
          , Zip                 = Zip
          , ChangeDate          = ChangeDate
          , ChangeBy            = ChangeBy
      FROM  Conversion.vw_LegacyAddress
     WHERE  AddressID = 0
    SELECT  @recordsToInsert = @@ROWCOUNT ;

      WITH  inserts AS (
            SELECT  * FROM Conversion.vw_LegacyAddress
             WHERE  AddressID = 0 )
    SELECT  @newFirmAddress          = ( SELECT COUNT(*) FROM inserts WHERE LegacyTableName = 'Firms' )
          , @newClientAddress        = ( SELECT COUNT(*) FROM inserts WHERE LegacyTableName = 'Clients' )
          , @newFirmContactAddress   = ( SELECT COUNT(*) FROM inserts WHERE LegacyTableName = 'FirmContacts' )
          , @newClientContactAddress = ( SELECT COUNT(*) FROM inserts WHERE LegacyTableName = 'ClientContacts' ) ;


--  5)  load records where AddressID != 0, these are UPDATEs
    INSERT  #processAddressData
    SELECT  AddressID, LegacyTableName, LegacyID
                , Address1, Address2
                , City, [State], Zip
                , ChangeDate, ChangeBy
      FROM  Conversion.vw_LegacyAddress AS a
     WHERE  EXISTS ( SELECT 1 FROM #changedAddresses AS b WHERE b.AddressID = a.AddressID AND a.AddressID > 0 ) ;
    SELECT  @recordsToUpdate = @@ROWCOUNT ;

      WITH  updates AS (
            SELECT  *
              FROM  Conversion.vw_LegacyAddress AS a
             WHERE  EXISTS ( SELECT 1 FROM #changedAddresses AS b WHERE b.AddressID = a.AddressID AND a.AddressID > 0 ) )

    SELECT  @changedFirmAddress          = ( SELECT COUNT(*) FROM updates WHERE LegacyTableName = 'Firms' )
          , @changedClientAddress        = ( SELECT COUNT(*) FROM updates WHERE LegacyTableName = 'Clients' )
          , @changedFirmContactAddress   = ( SELECT COUNT(*) FROM updates WHERE LegacyTableName = 'FirmContacts' )
          , @changedClientContactAddress = ( SELECT COUNT(*) FROM updates WHERE LegacyTableName = 'ClientContacts' ) ;


--  6)  Throw error if no records are loaded
    SELECT  @totalRecords = @recordsToInsert + @recordsToUpdate ;
    IF  @totalRecords = 0
    BEGIN
        PRINT   'Error:  changes detected but not captured' ;
        SELECT  @rc = 16 ;
        GOTO    endOfProc ;
    END


--  7)  MERGE #processAddressData with dbo.Address
    DECLARE @AddressChanges AS TABLE( action            NVARCHAR(10)
                                    , LegacyID          INT
                                    , LegacyTableName   VARCHAR(30)
                                    , AddressID         INT
                                    , ChangeDate        DATETIME
                                    , ChangeBy          VARCHAR(30) ) ;

    SET IDENTITY_INSERT dbo.Address ON ;

     MERGE  dbo.Address          AS tgt
     USING  #processAddressData  AS src
        ON  tgt.AddressID = src.AddressID
      WHEN  MATCHED THEN
            UPDATE
               SET  Address1     = src.Address1
                  , Address2     = src.Address2
                  , City         = src.City
                  , [State]      = src.[State]
                  , Zip          = src.Zip
                  , ModifiedDate = src.ChangeDate
                  , ModifiedUser = src.ChangeBy
      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( AddressID
                        , Address1, Address2, Address3
                        , City, [State], Zip
                        , Verified
                        , ModifiedDate, ModifiedUser )
            VALUES ( src.AddressID
                        , src.Address1, src.Address2, ''
                        , src.City, src.[State], src.Zip
                        , 0
                        , src.ChangeDate, src.ChangeBy )
    OUTPUT  $action, inserted.AddressID
      INTO  @AddressChanges ( action, AddressID ) ;
    SELECT  @recordsMERGEd = @@ROWCOUNT ;

    IF  @recordsMERGEd <> @totalRecords
    BEGIN
        PRINT     'Processing Error: @totalRecords  = ' + CAST( @totalRecords AS VARCHAR(20) )
                + '                  @recordsMERGEd = ' + CAST( @recordsMERGEd AS VARCHAR(20) ) + ' .' ;
        SELECT    @rc = 16 ;
    END


--  8)  Load @AddressChanges from 7) with legacy address data
    UPDATE  @AddressChanges
       SET  LegacyID        = pad.LegacyID
          , LegacyTableName = pad.LegacyTableName
          , ChangeDate      = pad.ChangeDate
          , ChangeBy        = pad.ChangeBy
      FROM  @AddressChanges     AS ac
INNER JOIN  #processAddressData AS pad
        ON  pad.AddressID = ac.AddressID ;

      WITH  inserts AS ( SELECT * FROM @AddressChanges WHERE action = 'INSERT' )
    SELECT  @recordsINSERTed          = ( SELECT COUNT(*) FROM inserts )
          , @isrtFirmAddress          = ( SELECT COUNT(*) FROM inserts WHERE LegacyTableName = 'Firms' )
          , @isrtClientAddress        = ( SELECT COUNT(*) FROM inserts WHERE LegacyTableName = 'Clients' )
          , @isrtFirmContactAddress   = ( SELECT COUNT(*) FROM inserts WHERE LegacyTableName = 'FirmContacts')
          , @isrtClientContactAddress = ( SELECT COUNT(*) FROM inserts WHERE LegacyTableName = 'ClientContacts') ;

      WITH  updates AS ( SELECT * FROM @AddressChanges WHERE action = 'UPDATE' )
    SELECT  @recordsUPDATEd           = ( SELECT COUNT(*) FROM updates )
          , @updtFirmAddress          = ( SELECT COUNT(*) FROM updates WHERE LegacyTableName = 'Firms' )
          , @updtClientAddress        = ( SELECT COUNT(*) FROM updates WHERE LegacyTableName = 'Clients' )
          , @updtFirmContactAddress   = ( SELECT COUNT(*) FROM updates WHERE LegacyTableName = 'FirmContacts')
          , @updtClientContactAddress = ( SELECT COUNT(*) FROM updates WHERE LegacyTableName = 'ClientContacts') ;

      WITH  deletes AS ( SELECT * FROM @AddressChanges WHERE action = 'DELETE' )
    SELECT  @recordsDELETEd           = ( SELECT COUNT(*) FROM deletes )
          , @dletFirmAddress          = ( SELECT COUNT(*) FROM deletes WHERE LegacyTableName = 'Firms' )
          , @dletClientAddress        = ( SELECT COUNT(*) FROM deletes WHERE LegacyTableName = 'Clients' )
          , @dletFirmContactAddress   = ( SELECT COUNT(*) FROM deletes WHERE LegacyTableName = 'FirmContacts')
          , @dletClientContactAddress = ( SELECT COUNT(*) FROM deletes WHERE LegacyTableName = 'ClientContacts') ;


    IF  @recordsINSERTed <> @recordsToInsert
    BEGIN
        PRINT     'Error ON INSERT:  @recordsToInsert = ' + CAST( @recordsToInsert AS VARCHAR(20) )
                + '                  @recordsINSERTed = ' + CAST( @recordsINSERTed AS VARCHAR(20) ) + ' .' ;
        SELECT    @rc = 16 ;
    END

    IF @recordsUPDATEd <> @recordsToUpdate
    BEGIN
        PRINT     'Error ON UPDATE:  @recordsToUpdate = ' + CAST( @recordsToUpdate AS VARCHAR(20) )
                + '                  @recordsUPDATEd  = ' + CAST( @recordsUPDATEd AS VARCHAR(20) ) + ' .' ;
        SELECT    @rc = 16 ;
    END

    IF @recordsDELETEd <> @recordsToDelete
    BEGIN
        PRINT     'Error ON DELETE:  @recordsToDelete = ' + CAST( @recordsToDelete AS VARCHAR(20) )
                + '                  @recordsDELETEd  = ' + CAST( @recordsDELETEd AS VARCHAR(20) ) + ' .' ;
        SELECT    @rc = 16 ;
    END

    IF  ( @rc = 16 ) GOTO endOfProc ;

--  9)  INSERT dbo.FirmAddresses data from @AddressChanges
    INSERT  dbo.FirmAddresses ( FirmID, AddressID, AddressTypeID, ModifiedDate, ModifiedUser )
    SELECT  LegacyID, AddressID, 3, ChangeDate, ChangeBy
      FROM  @AddressChanges
     WHERE  LegacyTableName = 'Firms' AND action = 'INSERT' ;

-- 10)  INSERT dbo.ClientAddresses data from @AddressChanges
    INSERT  dbo.ClientAddresses ( ClientID, AddressID, AddressTypeID, ModifiedDate, ModifiedUser )
    SELECT  LegacyID, AddressID, 3, ChangeDate, ChangeBy
      FROM  @AddressChanges
     WHERE  LegacyTableName = 'Clients' AND action = 'INSERT' ;

-- 11)  INSERT dbo.ContactAddresses data from @AddressChanges
    INSERT  dbo.ContactAddresses ( ContactID, AddressID, AddressTypeID, ModifiedDate, ModifiedUser )
    SELECT  lc.ContactID, AddressID, 3, ChangeDate, ChangeBy
      FROM  @AddressChanges AS ac
INNER JOIN  Conversion.LegacyContacts AS lc
        ON  lc.LegacyContactID = ac.LegacyID AND lc.LegacyTableName = ac.LegacyTableName
     WHERE  ac.LegacyTableName LIKE '%Contacts' AND action = 'INSERT' ;

-- 12)  INSERT Conversion.LegacyAddresses to link legacy data to converted dbo.Address table
    INSERT  Conversion.LegacyAddresses ( LegacyID, LegacyTableName, AddressID )
    SELECT  LegacyID, LegacyTableName, AddressID
      FROM  @AddressChanges AS ac
     WHERE  action = 'INSERT' ;


endOfProc:
-- 13)  Reset CONTEXT_INFO to re-enable converted table triggers
    SET     CONTEXT_INFO 0x0 ;


-- 14)  Print out control totals.
    PRINT 'Conversion.processAddresses CONTROL TOTALS ' ;
    PRINT '    Changed records               = ' + CAST( @totalRecords                AS VARCHAR(20) ) ;
    PRINT '        new records               = ' + CAST( @recordsToInsert             AS VARCHAR(20) ) ;
    PRINT '            FirmAddress           = ' + CAST( @newFirmAddress              AS VARCHAR(20) ) ;
    PRINT '            ClientAddress         = ' + CAST( @newClientAddress            AS VARCHAR(20) ) ;
    PRINT '            FirmContactAddress    = ' + CAST( @newFirmContactAddress       AS VARCHAR(20) ) ;
    PRINT '            ClientContactAddress  = ' + CAST( @newClientContactAddress     AS VARCHAR(20) ) ;
    PRINT '' ;
    PRINT '        modified records          = ' + CAST( @recordsToUpdate             AS VARCHAR(20) ) ;
    PRINT '            FirmAddress           = ' + CAST( @changedFirmAddress          AS VARCHAR(20) ) ;
    PRINT '            ClientAddress         = ' + CAST( @changedClientAddress        AS VARCHAR(20) ) ;
    PRINT '            FirmContactAddress    = ' + CAST( @changedFirmContactAddress   AS VARCHAR(20) ) ;
    PRINT '            ClientContactAddress  = ' + CAST( @changedClientContactAddress AS VARCHAR(20) ) ;
    PRINT '' ;
    PRINT '        deleted records           = ' + CAST( @recordsToDelete             AS VARCHAR(20) ) ;
    PRINT '            FirmAddress           = ' + CAST( @deletedFirmAddress          AS VARCHAR(20) ) ;
    PRINT '            ClientAddress         = ' + CAST( @deletedClientAddress        AS VARCHAR(20) ) ;
    PRINT '            FirmContactAddress    = ' + CAST( @deletedFirmContactAddress   AS VARCHAR(20) ) ;
    PRINT '            ClientContactAddress  = ' + CAST( @deletedClientContactAddress AS VARCHAR(20) ) ;
    PRINT '' ;
    PRINT '' ;
    PRINT '    Processed records             = ' + CAST( @recordsMERGEd               AS VARCHAR(20) ) ;
    PRINT '        INSERTed                  = ' + CAST( @recordsINSERTed             AS VARCHAR(20) ) ;
    PRINT '            FirmAddress           = ' + CAST( @isrtFirmAddress             AS VARCHAR(20) ) ;
    PRINT '            ClientAddress         = ' + CAST( @isrtClientAddress           AS VARCHAR(20) ) ;
    PRINT '            FirmContactAddress    = ' + CAST( @isrtFirmContactAddress      AS VARCHAR(20) ) ;
    PRINT '            ClientContactAddress  = ' + CAST( @isrtClientContactAddress    AS VARCHAR(20) ) ;
    PRINT '' ;
    PRINT '        UPDATEs                   = ' + CAST( @recordsUPDATEd              AS VARCHAR(20) ) ;
    PRINT '            FirmAddress           = ' + CAST( @updtFirmAddress             AS VARCHAR(20) ) ;
    PRINT '            ClientAddress         = ' + CAST( @updtClientAddress           AS VARCHAR(20) ) ;
    PRINT '            FirmContactAddress    = ' + CAST( @updtFirmContactAddress      AS VARCHAR(20) ) ;
    PRINT '            ClientContactAddress  = ' + CAST( @updtClientContactAddress    AS VARCHAR(20) ) ;
    PRINT '' ;
    PRINT '        DELETEs                   = ' + CAST( @recordsDELETEd              AS VARCHAR(20) ) ;
    PRINT '            FirmAddress           = ' + CAST( @dletFirmAddress             AS VARCHAR(20) ) ;
    PRINT '            ClientAddress         = ' + CAST( @dletClientAddress           AS VARCHAR(20) ) ;
    PRINT '            FirmContactAddress    = ' + CAST( @dletFirmContactAddress      AS VARCHAR(20) ) ;
    PRINT '            ClientContactAddress  = ' + CAST( @dletClientContactAddress    AS VARCHAR(20) ) ;
    PRINT '' ;
END
