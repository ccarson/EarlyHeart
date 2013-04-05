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
    ccarson         ###DATE###          revised error reporting

    Logic Summary:
    1)  SET CONTEXT_INFO, inhibiting triggers when invoked
    2)  SELECT initial control counts
    3)  INSERT changed address data into temp storage
    4)  Stop processing if there are no data changes
    5)  INSERT records from vw_LegacyAddress where AddressID == 0
    6)  INSERT records from vw_LegacyAddress where AddressID != 0
    7)  MERGE temp storage into dbo.Address
    8)  UPDATE @addressMergeResults legacy address data
    9)  INSERT dbo.FirmAddresses data from @addressMergeResults
   10)  INSERT dbo.ClientAddresses data from @addressMergeResults
   11)  INSERT dbo.ContactAddresses data from @addressMergeResults
   12)  INSERT Conversion.LegacyAddresses from @addressMergeResults
   13)  SELECT final control counts
   14)  Control Total Validation
   15)  Reset CONTEXT_INFO to re-enable converted table triggers
   16)  Print out control totals

    NOTES
    Error handling algorithim based on article here:  
        http://blogs.msdn.com/b/anthonybloesch/archive/2009/03/10/sql-server-error-handling-best-practice.aspx
    
************************************************************************************************************************************
*/
BEGIN
BEGIN TRY


    SET NOCOUNT ON ;

    DECLARE @fromConversion AS VARBINARY (128) = CAST( 'fromConversion' AS VARBINARY (128) ) ;
          , @processStartTime               AS VARCHAR (30)     = CONVERT( VARCHAR(30), GETDATE(), 121 )
          , @processEndTime                 AS VARCHAR (30)     = NULL
          , @processElapsedTime             AS INT              = 0 ;


    DECLARE @codeBlockDesc01                AS SYSNAME          = 'SET CONTEXT_INFO, inhibiting triggers when invoked'
          , @codeBlockDesc02                AS SYSNAME          = 'SELECT initial control counts'
          , @codeBlockDesc03                AS SYSNAME          = 'INSERT changed address data into temp storage'
          , @codeBlockDesc04                AS SYSNAME          = 'Stop processing if there are no data changes'
          , @codeBlockDesc05                AS SYSNAME          = 'INSERT records from vw_LegacyAddress where AddressID == 0'
          , @codeBlockDesc06                AS SYSNAME          = 'INSERT records from vw_LegacyAddress where AddressID != 0'
          , @codeBlockDesc07                AS SYSNAME          = 'MERGE temp storage into dbo.Address'
          , @codeBlockDesc08                AS SYSNAME          = 'UPDATE @addressMergeResults legacy address data'
          , @codeBlockDesc09                AS SYSNAME          = 'INSERT dbo.FirmAddresses data from @addressMergeResults'
          , @codeBlockDesc10                AS SYSNAME          = 'INSERT dbo.ClientAddresses data from @addressMergeResults'
          , @codeBlockDesc11                AS SYSNAME          = 'INSERT dbo.ContactAddresses data from @addressMergeResults'
          , @codeBlockDesc12                AS SYSNAME          = 'INSERT Conversion.LegacyAddresses from @addressMergeResults'
          , @codeBlockDesc13                AS SYSNAME          = 'SELECT final control counts'
          , @codeBlockDesc14                AS SYSNAME          = 'Control Total Validation'
          , @codeBlockDesc15                AS SYSNAME          = 'Reset CONTEXT_INFO to re-enable converted table triggers'
          , @codeBlockDesc16                AS SYSNAME          = 'Print out control totals' ;


    DECLARE @codeBlockNum                   AS INT
          , @codeBlockDesc                  AS SYSNAME
          , @errorTypeID                    AS INT
          , @errorSeverity                  AS INT
          , @errorState                     AS INT
          , @errorNumber                    AS INT
          , @errorLine                      AS INT
          , @errorProcedure                 AS SYSNAME
          , @errorMessage                   AS VARCHAR (MAX)    = NULL
          , @errorData                      AS VARCHAR (MAX)    = NULL ; 
          
    DECLARE @isNested                       AS BIT              = CASE WHEN @@TRANCOUNT > 0 THEN 1 ELSE 0 END
          , @transactionPoint               AS CHAR(32)         = REPLACE( CAST( NEWID() AS CHAR (36) ), '-', '' )
          

    DECLARE @changesClient                  AS INT              = 0
          , @changesClientContact           AS INT              = 0
          , @changesCount                   AS INT              = 0
          , @changesFirm                    AS INT              = 0
          , @changesFirmContact             AS INT              = 0
          , @clientAddressINSERTs           AS INT              = 0
          , @contactAddressINSERTs          AS INT              = 0
          , @convertedActual                AS INT              = 0
          , @convertedCount                 AS INT              = 0
          , @currentAddressID               AS INT              = 0
          , @firmAddressINSERTs             AS INT              = 0
          , @legacyAddressINSERTs           AS INT              = 0
          , @legacyCount                    AS INT              = 0
          , @newClientContactCount          AS INT              = 0
          , @newClientCount                 AS INT              = 0
          , @newCount                       AS INT              = 0
          , @newFirmContactCount            AS INT              = 0
          , @newFirmCount                   AS INT              = 0
          , @recordClientContactINSERTs     AS INT              = 0
          , @recordClientContactUPDATEs     AS INT              = 0
          , @recordClientINSERTs            AS INT              = 0
          , @recordClientUPDATEs            AS INT              = 0
          , @recordFirmContactINSERTs       AS INT              = 0
          , @recordFirmContactUPDATEs       AS INT              = 0
          , @recordFirmINSERTs              AS INT              = 0
          , @recordFirmUPDATEs              AS INT              = 0
          , @recordINSERTs                  AS INT              = 0
          , @recordMERGEs                   AS INT              = 0
          , @recordUPDATEs                  AS INT              = 0
          , @total                          AS INT              = 0
          , @updatedClientContactCount      AS INT              = 0
          , @updatedClientCount             AS INT              = 0
          , @updatedCount                   AS INT              = 0
          , @updatedFirmContactCount        AS INT              = 0
          , @updatedFirmCount               AS INT              = 0 ;


    DECLARE @controlTotalsError             AS VARCHAR (200)    = N'Control Total Failure:  %s = %d, %s = %d' ;


    DECLARE @changingAddressData            AS TABLE ( AddressID        INT NOT NULL    PRIMARY KEY CLUSTERED
                                                     , LegacyTableName  VARCHAR (30)
                                                     , LegacyID         INT
                                                     , Address1         VARCHAR (50)
                                                     , Address2         VARCHAR (50)
                                                     , City             VARCHAR (50)
                                                     , [State]          VARCHAR (5)
                                                     , Zip              VARCHAR (10)
                                                     , ChangeDate       DATETIME
                                                     , ChangeBy         VARCHAR (50) ) ;


    DECLARE @changedAddresses               AS TABLE ( LegacyID         INT
                                                     , LegacyTableName  VARCHAR (30)
                                                     , AddressID        INT
                                                     , AddressChecksum  VARBINARY (128) ) ;


    DECLARE @addressMergeResults            AS TABLE ( action           NVARCHAR (10)
                                                     , LegacyID         INT
                                                     , LegacyTableName  VARCHAR (30)
                                                     , AddressID        INT
                                                     , ChangeDate       DATETIME
                                                     , ChangeBy         VARCHAR (30) ) ;


/**/SELECT  @codeBlockNum   = 1
/**/      , @codeBlockDesc  = @codeBlockDesc01 ;  --  SET CONTEXT_INFO, inhibiting triggers when invoked

    SET CONTEXT_INFO @processAddresses ;


/**/SELECT  @codeBlockNum   = 2
/**/      , @codeBlockDesc  = @codeBlockDesc02 ;  --  SELECT initial control counts

    SELECT  @legacyCount        = COUNT(*) FROM Conversion.vw_LegacyAddress ;
    SELECT  @convertedCount     = COUNT(*) FROM Conversion.vw_ConvertedAddress ;
    SELECT  @convertedActual    = @convertedCount ;


/**/SELECT  @codeBlockNum   = 3
/**/      , @codeBlockDesc  = @codeBlockDesc03 ;  --  INSERT changed address data into temp storage

    INSERT  @changedAddresses
    SELECT  LegacyID, LegacyTableName, AddressID, AddressChecksum FROM Conversion.tvf_AddressChecksum( 'Firms' )
        EXCEPT
    SELECT  LegacyID, LegacyTableName, AddressID, AddressChecksum FROM Conversion.tvf_AddressChecksum( 'Address' ) ;
    SELECT  @changesFirm    = @@ROWCOUNT ;
    SELECT  @changesCount   = @changesFirm ;

    INSERT  @changedAddresses
    SELECT  LegacyID, LegacyTableName, AddressID, AddressChecksum FROM Conversion.tvf_AddressChecksum( 'Clients' )
        EXCEPT
    SELECT  LegacyID, LegacyTableName, AddressID, AddressChecksum FROM Conversion.tvf_AddressChecksum( 'Address' ) ;
    SELECT  @changesClient  = @@ROWCOUNT ;
    SELECT  @changesCount   = @changesCount + @changesClient ;

    INSERT  @changedAddresses
    SELECT  LegacyID, LegacyTableName, AddressID, AddressChecksum FROM Conversion.tvf_AddressChecksum( 'FirmContacts' )
        EXCEPT
    SELECT  LegacyID, LegacyTableName, AddressID, AddressChecksum FROM Conversion.tvf_AddressChecksum( 'Address' ) ;
    SELECT  @changesFirmContact = @@ROWCOUNT ;
    SELECT  @changesCount       = @changesCount + @changesFirmContact ;

    INSERT  @changedAddresses
    SELECT  LegacyID, LegacyTableName, AddressID, AddressChecksum FROM Conversion.tvf_AddressChecksum( 'ClientContacts' )
        EXCEPT
    SELECT  LegacyID, LegacyTableName, AddressID, AddressChecksum FROM Conversion.tvf_AddressChecksum( 'Address' ) ;
    SELECT  @changesClientContact   = @@ROWCOUNT ;
    SELECT  @changesCount           = @changesFirm + @changesFirmContact + @changesClient + @changesClientContact ;


/**/SELECT  @codeBlockNum   = 4
/**/      , @codeBlockDesc  = @codeBlockDesc04 ;  --  Stop processing if there are no data changes

    IF  @changesCount = 0 GOTO endOfProc ;


/**/SELECT  @codeBlockNum   = 5
/**/      , @codeBlockDesc  = @codeBlockDesc05 ;  --  INSERT records from vw_LegacyAddress where AddressID == 0

    SELECT  @currentAddressID = ISNULL( IDENT_CURRENT('dbo.Address'), 0 ) ;

    INSERT  @changingAddressData
    SELECT  AddressID           = @currentAddressID + ROW_NUMBER() OVER ( ORDER BY (SELECT NULL) )
          , LegacyTableName     = LegacyTableName
          , LegacyID            = LegacyID
          , Address1            = Address1
          , Address2            = Address2
          , City                = City
          , State               = State
          , Zip                 = Zip
          , ChangeDate          = ChangeDate
          , ChangeBy            = ChangeBy
      FROM  Conversion.vw_LegacyAddress
     WHERE  AddressID = 0
    SELECT  @newCount = @@ROWCOUNT ;

      WITH  inserts AS (
            SELECT  * FROM Conversion.vw_LegacyAddress
             WHERE  AddressID = 0 )
    SELECT  @newFirmCount          = ( SELECT COUNT(*) FROM inserts WHERE LegacyTableName = 'Firms' )
          , @newClientCount        = ( SELECT COUNT(*) FROM inserts WHERE LegacyTableName = 'Clients' )
          , @newFirmContactCount   = ( SELECT COUNT(*) FROM inserts WHERE LegacyTableName = 'FirmContacts' )
          , @newClientContactCount = ( SELECT COUNT(*) FROM inserts WHERE LegacyTableName = 'ClientContacts' ) ;


/**/SELECT  @codeBlockNum   = 6
/**/      , @codeBlockDesc  = @codeBlockDesc06 ;  --  INSERT records from vw_LegacyAddress where AddressID != 0

    INSERT  @changingAddressData
    SELECT  AddressID, LegacyTableName, LegacyID
                , Address1, Address2
                , City, State, Zip
                , ChangeDate, ChangeBy
      FROM  Conversion.vw_LegacyAddress AS a
     WHERE  a.AddressID > 0
       AND  EXISTS ( SELECT 1 FROM @changedAddresses AS b WHERE b.AddressID = a.AddressID ) ;
    SELECT  @updatedCount = @@ROWCOUNT ;

      WITH  updates AS (
            SELECT  *
              FROM  Conversion.vw_LegacyAddress AS a
             WHERE  a.AddressID > 0
               AND  EXISTS ( SELECT 1 FROM @changedAddresses AS b WHERE b.AddressID = a.AddressID ) )

    SELECT  @updatedFirmCount          = ( SELECT COUNT(*) FROM updates WHERE LegacyTableName = 'Firms' )
          , @updatedClientCount        = ( SELECT COUNT(*) FROM updates WHERE LegacyTableName = 'Clients' )
          , @updatedFirmContactCount   = ( SELECT COUNT(*) FROM updates WHERE LegacyTableName = 'FirmContacts' )
          , @updatedClientContactCount = ( SELECT COUNT(*) FROM updates WHERE LegacyTableName = 'ClientContacts' ) ;


/**/SELECT  @codeBlockNum   = 7
/**/      , @codeBlockDesc  = @codeBlockDesc07 ;  --  BEGIN TRANSACTION

    IF  ( @isNested = 1 ) 
        SAVE TRANSACTION @transactionPoint ;
    ELSE
        BEGIN TRANSACTION @transactionPoint ;


/**/SELECT  @codeBlockNum   = 7
/**/      , @codeBlockDesc  = @codeBlockDesc07 ;  --  MERGE temp storage into dbo.Address

    SET IDENTITY_INSERT dbo.Address ON ;

     MERGE  dbo.Address           AS tgt
     USING  @changingAddressData  AS src ON tgt.AddressID = src.AddressID
      WHEN  MATCHED THEN
            UPDATE
               SET  Address1     = src.Address1
                  , Address2     = src.Address2
                  , City         = src.City
                  , State        = src.State
                  , Zip          = src.Zip
                  , ModifiedDate = src.ChangeDate
                  , ModifiedUser = src.ChangeBy
      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( AddressID, Address1, Address2, Address3
                        , City, [State], Zip, Verified
                        , ModifiedDate, ModifiedUser )
            VALUES ( src.AddressID, src.Address1, src.Address2, ''
                        , src.City, src.[State], src.Zip, 0
                        , src.ChangeDate, src.ChangeBy )
    OUTPUT  $action, inserted.AddressID
      INTO  @addressMergeResults ( action, AddressID ) ;
    SELECT  @recordMERGEs = @@ROWCOUNT ;

    SET IDENTITY_INSERT dbo.Address OFF ;


/**/SELECT  @codeBlockNum   = 8
/**/      , @codeBlockDesc  = @codeBlockDesc08 ;  --  UPDATE @addressMergeResults legacy address data

    UPDATE  @addressMergeResults
       SET  LegacyID        = ad.LegacyID
          , LegacyTableName = ad.LegacyTableName
          , ChangeDate      = ad.ChangeDate
          , ChangeBy        = ad.ChangeBy
      FROM  @addressMergeResults    AS ac
INNER JOIN  @changingAddressData    AS ad
        ON  ad.AddressID = ac.AddressID ;


/**/SELECT  @codeBlockNum   = 9
/**/      , @codeBlockDesc  = @codeBlockDesc09 ;  --  INSERT dbo.FirmAddresses data from @addressMergeResults

    INSERT  dbo.FirmAddresses ( FirmID, AddressID, AddressTypeID, ModifiedDate, ModifiedUser )
    SELECT  LegacyID, AddressID, 3, ChangeDate, ChangeBy
      FROM  @addressMergeResults
     WHERE  LegacyTableName = 'Firms' AND action = 'INSERT' ;
    SELECT  @firmAddressINSERTs = @@ROWCOUNT ;


/**/SELECT  @codeBlockNum   = 10
/**/      , @codeBlockDesc  = @codeBlockDesc10 ;  --  INSERT dbo.ClientAddresses data from @addressMergeResults

    INSERT  dbo.ClientAddresses ( ClientID, AddressID, AddressTypeID, ModifiedDate, ModifiedUser )
    SELECT  LegacyID, AddressID, 3, ChangeDate, ChangeBy
      FROM  @addressMergeResults
     WHERE  LegacyTableName = 'Clients' AND action = 'INSERT' ;
    SELECT  @clientAddressINSERTs = @@ROWCOUNT ;


/**/SELECT  @codeBlockNum   = 11
/**/      , @codeBlockDesc  = @codeBlockDesc11 ;  --  INSERT dbo.ContactAddresses data from @addressMergeResults

    INSERT  dbo.ContactAddresses ( ContactID, AddressID, AddressTypeID, ModifiedDate, ModifiedUser )
    SELECT  lc.ContactID, AddressID, 3, ChangeDate, ChangeBy
      FROM  @addressMergeResults        AS ac
INNER JOIN  Conversion.LegacyContacts   AS lc ON lc.LegacyContactID = ac.LegacyID AND lc.LegacyTableName = ac.LegacyTableName
     WHERE  ac.LegacyTableName LIKE '%Contacts' AND action = 'INSERT' ;
    SELECT  @contactAddressINSERTs = @@ROWCOUNT ;


/**/SELECT  @codeBlockNum   = 12
/**/      , @codeBlockDesc  = @codeBlockDesc12 ;  --  INSERT Conversion.LegacyAddresses from @addressMergeResults

    INSERT  Conversion.LegacyAddresses ( LegacyID, LegacyTableName, AddressID )
    SELECT  LegacyID, LegacyTableName, AddressID
      FROM  @addressMergeResults AS ac
     WHERE  action = 'INSERT' ;
    SELECT  @legacyAddressINSERTs = @@ROWCOUNT ;
    
    
/**/SELECT  @codeBlockNum   = 13
/**/      , @codeBlockDesc  = @codeBlockDesc13 ;  --  COMMIT

    IF  ( @isNested = 0 ) 
        COMMIT TRANSACTION ;


/**/SELECT  @codeBlockNum   = 13
/**/      , @codeBlockDesc  = @codeBlockDesc13 ;  --  SELECT final control counts

      WITH  inserts AS ( SELECT * FROM @addressMergeResults WHERE action = 'INSERT' )
    SELECT  @recordINSERTs              = ( SELECT COUNT(*) FROM inserts )
          , @recordFirmINSERTs          = ( SELECT COUNT(*) FROM inserts WHERE LegacyTableName = 'Firms' )
          , @recordClientINSERTs        = ( SELECT COUNT(*) FROM inserts WHERE LegacyTableName = 'Clients' )
          , @recordFirmContactINSERTs   = ( SELECT COUNT(*) FROM inserts WHERE LegacyTableName = 'FirmContacts')
          , @recordClientContactINSERTs = ( SELECT COUNT(*) FROM inserts WHERE LegacyTableName = 'ClientContacts') ;

      WITH  updates AS ( SELECT * FROM @addressMergeResults WHERE action = 'UPDATE' )
    SELECT  @recordUPDATEs              = ( SELECT COUNT(*) FROM updates )
          , @recordFirmUPDATEs          = ( SELECT COUNT(*) FROM updates WHERE LegacyTableName = 'Firms' )
          , @recordClientUPDATEs        = ( SELECT COUNT(*) FROM updates WHERE LegacyTableName = 'Clients' )
          , @recordFirmContactUPDATEs   = ( SELECT COUNT(*) FROM updates WHERE LegacyTableName = 'FirmContacts')
          , @recordClientContactUPDATEs = ( SELECT COUNT(*) FROM updates WHERE LegacyTableName = 'ClientContacts') ;

    SELECT  @convertedActual = COUNT(*) FROM Conversion.vw_ConvertedAddress ;


/**/SELECT  @codeBlockNum   = 14
/**/      , @codeBlockDesc  = @codeBlockDesc14 ;  --  Control Total Validation

    SELECT @total =  @convertedCount + @recordINSERTs
    IF  ( @convertedActual <> ( @convertedCount + @recordINSERTs ) )
        RAISERROR( @controlTotalsError, 16, 1, 'Converted Addresses', @convertedActual, 'Existing Addresses + Inserts', @total ) ;

    IF  ( @convertedActual <> @legacyCount )
        RAISERROR( @controlTotalsError, 16, 1, 'Converted Addresses', @convertedActual, 'Legacy Addresses', @legacyCount ) ;

    IF  ( @recordINSERTs <> @newCount )
        RAISERROR( @controlTotalsError, 16, 1, 'Inserted Addresses', @recordINSERTs,  'Expected Inserts', @newCount ) ;

    IF  ( @recordUPDATEs <> @updatedCount )
        RAISERROR( @controlTotalsError, 16, 1, 'Updated Addresses', @recordUPDATEs,  'Expected Updates', @updatedCount ) ;

    IF  ( @recordMERGEs <> @changesCount )
        RAISERROR( @controlTotalsError, 16, 1, 'Changed Addresses', @recordMERGEs,  'Expected Changes', @changesCount ) ;

    IF  ( @newFirmCount <> @recordFirmINSERTs )
        RAISERROR( @controlTotalsError, 16, 1, 'Inserted Firm Addresses ( Address )', @recordFirmINSERTs,  'Expected', @newFirmCount ) ;

    IF  ( @newClientCount <> @recordClientINSERTs )
        RAISERROR( @controlTotalsError, 16, 1, 'Inserted Client Addresses ( Address )', @recordClientINSERTs,  'Expected', @newClientCount ) ;

    IF  ( @newFirmContactCount <> @recordFirmContactINSERTs )
        RAISERROR( @controlTotalsError, 16, 1, 'Inserted FirmContact Addresses ( Address )', @recordFirmContactINSERTs,  'Expected', @newFirmContactCount ) ;

    IF  ( @newClientContactCount <> @recordClientContactINSERTs )
        RAISERROR( @controlTotalsError, 16, 1, 'Inserted ClientContact Addresses ( Address )', @recordClientContactINSERTs,  'Expected', @newClientContactCount ) ;

    IF  ( @updatedFirmCount <> @recordFirmUPDATEs )
        RAISERROR( @controlTotalsError, 16, 1, 'Updated Firm Addresses', @recordFirmUPDATEs,  'Expected', @updatedFirmCount ) ;

    IF  ( @updatedClientCount <> @recordClientUPDATEs )
        RAISERROR( @controlTotalsError, 16, 1, 'Updated Client Addresses', @recordClientUPDATEs,  'Expected', @updatedClientCount ) ;

    IF  ( @updatedFirmContactCount <> @recordFirmContactUPDATEs )
        RAISERROR( @controlTotalsError, 16, 1, 'Updated FirmContact Addresses', @recordFirmContactUPDATEs,  'Expected', @updatedFirmContactCount ) ;

    IF  ( @updatedClientContactCount <> @recordClientContactUPDATEs )
        RAISERROR( @controlTotalsError, 16, 1, 'Updated ClientContact Addresses', @recordClientContactUPDATEs,  'Expected', @updatedClientContactCount ) ;

    IF  ( @newFirmCount <> @firmAddressINSERTs )
        RAISERROR( @controlTotalsError, 16, 1, 'Inserted Firm Addresses', @firmAddressINSERTs,  'Expected', @newFirmCount ) ;

    IF  ( @newClientCount <> @clientAddressINSERTs )
        RAISERROR( @controlTotalsError, 16, 1, 'Inserted Client Addresses', @clientAddressINSERTs,  'Expected', @newClientCount ) ;

    SELECT @total = @newFirmContactCount + @newClientContactCount
    IF  ( ( @newFirmContactCount + @newClientContactCount ) <> @contactAddressINSERTs )
        RAISERROR( @controlTotalsError, 16, 1, 'Inserted Contact Addresses', @contactAddressINSERTs,  'Expected', @total ) ;

    IF  ( @legacyAddressINSERTs <> @recordINSERTs )
        RAISERROR( @controlTotalsError, 16, 1, 'Legacy Address Inserts', @legacyAddressINSERTs,  'Converted Address Inserts', @recordINSERTs ) ;


endOfProc:
/**/SELECT  @codeBlockNum   = 15
/**/      , @codeBlockDesc  = @codeBlockDesc15 ;  --  Reset CONTEXT_INFO to re-enable converted table triggers
    SET     CONTEXT_INFO 0x0 ;


/**/SELECT  @codeBlockNum   = 16
/**/      , @codeBlockDesc  = @codeBlockDesc16 ;  --  Print out control totals


    SELECT  @processEndTime     = CONVERT( VARCHAR(30), GETDATE(), 121 )
          , @processElapsedTime = DATEDIFF( ms, CAST( @processStartTime AS DATETIME ), CAST( @processEndTime AS DATETIME ) ) ;

    RAISERROR( 'Conversion.processAddresses CONTROL TOTALS ', 0, 0 ) ;
    RAISERROR( 'Legacy Addresses                         = % 8d', 0, 0, @legacyCount ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( 'Converted Addresses                      = % 8d', 0, 0, @convertedCount ) ;
    RAISERROR( '     + new records                       = % 8d', 0, 0, @newCount ) ;
    RAISERROR( '                                            ======= ', 0, 0 ) ;
    RAISERROR( 'Total Converted Addresses                = % 8d', 0, 0, @convertedActual ) ;
    RAISERROR( 'Changed Addresses already counted        = % 8d', 0, 0, @updatedCount ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( 'Database Change Details', 0, 0 ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( '     New Firm Addresses                  = % 8d', 0, 0, @recordFirmINSERTs ) ;
    RAISERROR( '     New Client Addresses                = % 8d', 0, 0, @recordClientINSERTs ) ;
    RAISERROR( '     New Firm Contact Addresses          = % 8d', 0, 0, @recordFirmContactINSERTs ) ;
    RAISERROR( '     New Client Contact Addresses        = % 8d', 0, 0, @recordClientContactINSERTs ) ;
    RAISERROR( '                                            ======= ', 0, 0 ) ;
    RAISERROR( '     INSERTs to dbo.Address              = % 8d', 0, 0, @recordINSERTs ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( '     INSERTs to dbo.FirmAddress          = % 8d', 0, 0, @firmAddressINSERTs ) ;
    RAISERROR( '     INSERTs to dbo.ClientAddress        = % 8d', 0, 0, @clientAddressINSERTs ) ;
    RAISERROR( '     INSERTs to dbo.ContactAddress       = % 8d', 0, 0, @contactAddressINSERTs ) ;
    RAISERROR( '                                            ======= ', 0, 0 ) ;
    RAISERROR( '     INSERTs to Conversion.LegacyAddress = % 8d', 0, 0, @legacyAddressINSERTs ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( '     Updated Firm Addresses              = % 8d', 0, 0, @recordFirmUPDATEs ) ;
    RAISERROR( '     Updated Client Addresses            = % 8d', 0, 0, @recordClientUPDATEs ) ;
    RAISERROR( '     Updated Firm Contact Addresses      = % 8d', 0, 0, @recordFirmContactUPDATEs ) ;
    RAISERROR( '     Updated Client Contact Addresses    = % 8d', 0, 0, @recordClientContactUPDATEs ) ;
    RAISERROR( '                                            ======= ', 0, 0 ) ;
    RAISERROR( '     UPDATEs to dbo.Address              = % 8d', 0, 0, @recordUPDATEs ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( 'processAddresses START : %s', 0, 0, @processStartTime ) ;
    RAISERROR( 'processAddresses   END : %s', 0, 0, @processEndTime ) ;
    RAISERROR( '          Elapsed Time : %d ms', 0, 0, @processElapsedTime ) ;

END TRY
BEGIN CATCH
    IF  @codeBlockNum = 
        SELECT  @errorData = '<b>temp storage contents from processAddresses procedure</b></br>'
                           + '<table border="1">'
                           + '<tr><th>AddressID</th><th>LegacyTableName</th><th>LegacyID</th><th>Address1</th>'
                           + '<th>Address2</th><th>City</th><th>State</th><th>Zip</th>'
                           + '<th>ChangeDate</th><th>ChangeBy</th></tr>'
                           + CAST ( ( SELECT  td = AddressID        , ''
                                           ,  td = LegacyTableName  , ''
                                           ,  td = LegacyID         , ''
                                           ,  td = Address1         , ''
                                           ,  td = Address2         , ''
                                           ,  td = City             , ''
                                           ,  td = [State]          , ''
                                           ,  td = Zip              , ''
                                           ,  td = ChangeDate       , ''
                                           ,  td = ChangeBy         , ''
                                        FROM  @changingAddressData
                                         FOR XML PATH('tr'), TYPE ) AS VARCHAR(MAX) )
                           + N'</table>' ;

    IF  @codeBlockNum BETWEEN 8 AND 12
        SELECT  @errorData = '<b>merge results from processAddresses procedure</b></br>'
                           + '<table border="1">'
                           + '<tr><th>action</th><th>LegacyID</th><th>LegacyTableName</th>'
                           + '<th>AddressID</th><th>ChangeDate</th><th>ChangeBy</th></tr>'
                           + CAST ( ( SELECT  td = action           , ''
                                           ,  td = LegacyID         , ''
                                           ,  td = LegacyTableName  , ''
                                           ,  td = AddressID        , ''
                                           ,  td = ChangeDate       , ''
                                           ,  td = ChangeBy         , ''
                                        FROM  @addressMergeResults
                                         FOR XML PATH('tr'), TYPE ) AS VARCHAR(MAX) )
                           + N'</table>' ;
   

    IF  XACT_STATE() = 1
        ROLLBACK TRANSACTION @transactionPoint ;

    SELECT  @errorTypeID    = 1
          , @errorSeverity  = ERROR_SEVERITY()
          , @errorState     = ERROR_STATE()
          , @errorNumber    = ERROR_NUMBER()
          , @errorLine      = ERROR_LINE()
          , @errorProcedure = ERROR_PROCEDURE()
          , @errorMessage   = ERROR_MESSAGE() ;
          
    IF  @errorMessage IS NULL
    BEGIN
        SELECT  @errorMessage = N'Error occurred in Code Block %d, %s ' + CHAR(13)
                              + N'Error %d, Level %d, State %d, Procedure %s, Line %d' + CHAR(13) 
                              + N'Message: ' + ERROR_MESSAGE() ;

        RAISERROR( @errorMessage, @errorSeverity, 1
                 , @codeBlockNum
                 , @codeBlockDesc
                 , @errorNumber
                 , @errorSeverity
                 , @errorState
                 , @errorProcedure
                 , @errorLine ) ;

        SELECT  @errorMessage = ERROR_MESSAGE() ;

        IF  @codeBlockDesc = @codeBlockDesc07
            SELECT  @errorData = '<b>temp storage contents from processAddresses procedure</b></br>'
                               + '<table border="1">'
                               + '<tr><th>AddressID</th><th>LegacyTableName</th><th>LegacyID</th><th>Address1</th>'
                               + '<th>Address2</th><th>City</th><th>State</th><th>Zip</th>'
                               + '<th>ChangeDate</th><th>ChangeBy</th></tr>'
                               + CAST ( ( SELECT  td = AddressID        , ''
                                               ,  td = LegacyTableName  , ''
                                               ,  td = LegacyID         , ''
                                               ,  td = Address1         , ''
                                               ,  td = Address2         , ''
                                               ,  td = City             , ''
                                               ,  td = [State]          , ''
                                               ,  td = Zip              , ''
                                               ,  td = ChangeDate       , ''
                                               ,  td = ChangeBy         , ''
                                            FROM  @changingAddressData
                                             FOR XML PATH('tr'), TYPE ) AS VARCHAR(MAX) )
                               + N'</table>' ;

        IF  @codeBlockNum BETWEEN 8 AND 12
            SELECT  @errorData = '<b>temp storage contents from processAddresses procedure</b></br>'
                               + '<table border="1">'
                               + '<tr><th>action</th><th>LegacyID</th><th>LegacyTableName</th>'
                               + '<th>AddressID</th><th>ChangeDate</th><th>ChangeBy</th></tr>'
                               + CAST ( ( SELECT  td = action           , ''
                                               ,  td = LegacyID         , ''
                                               ,  td = LegacyTableName  , ''
                                               ,  td = AddressID        , ''
                                               ,  td = ChangeDate       , ''
                                               ,  td = ChangeBy         , ''
                                            FROM  @addressMergeResults
                                             FOR XML PATH('tr'), TYPE ) AS VARCHAR(MAX) )
                               + N'</table>' ;

        EXECUTE dbo.processEhlersErrorNEW  @errorTypeID
                                      , @codeBlockNum
                                      , @codeBlockDesc
                                      , @errorNumber
                                      , @errorSeverity
                                      , @errorState
                                      , @errorProcedure
                                      , @errorLine
                                      , @errorMessage
                                      , @errorData ;

    END
        ELSE
    BEGIN
        SELECT  @errorSeverity  = ERROR_SEVERITY()
              , @errorState     = ERROR_STATE()

        RAISERROR( @errorMessage, @errorSeverity, @errorState ) ;
    END

END CATCH
END
