CREATE PROCEDURE Conversion.processClientServices
AS
/*
************************************************************************************************************************************

  Procedure:  Conversion.processClientServices
     Author:  Chris Carson
    Purpose:  converts legacy ClientsServices data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Set CONTEXT_INFO to prevent converted tables from triggering changes
    2)  Create temp storage for changed data from source tables
    3)  SELECT initial control counts
    4)  Test for changes with CHECKSUMs, exit proc if there are none
    5)  INSERT new client services into #processClientServicesData, SELECT control counts
    6)  INSERT dropped client services into #processClientServicesData, SELECT control counts
    7)  UPDATE #processClientServicesData with legacy Client change data
    8)  MERGE #processClientServicesData into dbo.ClientServices
    9)  SELECT control counts and validate
    10) Reset CONTEXT_INFO to re-enable triggering on converted tables
    11) Print control totals


    Notes:

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;

    DECLARE @rc                             AS INT            = 0
          , @processName                    AS VARCHAR(100)   = 'processClientServices'
          , @errorMessage                   AS VARCHAR(MAX)   = NULL
          , @errorQuery                     AS VARCHAR(MAX)   = NULL
          , @processClientServices          AS VARBINARY(128) = CAST( 'processClientServices' AS VARBINARY(128) ) ;

    DECLARE @clientServicesMergeCount       AS INT = 0
          , @convertedClientServicesActual  AS INT = 0
          , @convertedClientServicesCount   AS INT = 0
          , @droppedClientServicesActual    AS INT = 0
          , @droppedClientServicesCount     AS INT = 0
          , @legacyClientServicesCount      AS INT = 0
          , @newClientServicesActual        AS INT = 0
          , @newClientServicesCount         AS INT = 0 ;

    DECLARE @clientServicesMergeResults     AS TABLE( Action    NVARCHAR (10)
                                                    , ClientID  INT
                                                    , Active    BIT ) ;

BEGIN TRY


--  1)  Set CONTEXT_INFO to prevent converted tables from triggering changes
    SET CONTEXT_INFO @processClientServices ;


--  2)  Create temp storage for changed data from source tables
    IF  OBJECT_ID('tempdb..#processClientServicesData') IS NOT NULL
        DROP TABLE  #processClientServicesData ;

    CREATE TABLE    #processClientServicesData (
        ClientID         INT
      , ServiceCode      VARCHAR (20)
      , Active           BIT
      , ClientServiceID  INT
      , ModifiedDate     DATETIME
      , ModifiedUser     VARCHAR (20) ) ;


--  3)  SELECT initial control counts
    SELECT  @legacyClientServicesCount      = COUNT(*) FROM Conversion.vw_LegacyClientServices ;
    SELECT  @convertedClientServicesCount   = COUNT(*) FROM Conversion.vw_ConvertedClientServices ;
    SELECT  @convertedClientServicesActual  = @convertedClientServicesCount ;


--  4)  Test for changes with CHECKSUMs, exit proc if there are none
    IF  NOT EXISTS ( SELECT CHECKSUM_AGG( CHECKSUM(*) ) FROM Conversion.vw_LegacyClientServices
                        EXCEPT
                    SELECT CHECKSUM_AGG( CHECKSUM(*) ) FROM Conversion.vw_ConvertedClientServices )
    BEGIN
        PRINT   'no Client Services changes, exiting' ;
        GOTO    endOfProc ;
    END

    PRINT 'migrating changed Client Services data' ;

--  5)  INSERT new client services into #processClientServicesData, SELECT control counts
      WITH  newServices AS (
            SELECT * FROM Conversion.vw_LegacyClientServices
                EXCEPT
            SELECT * FROM Conversion.vw_ConvertedClientServices )

    INSERT  #processClientServicesData ( ClientID, ServiceCode, ClientServiceID, Active )
    SELECT  ClientID, ServiceCode, ClientServiceID, 1
      FROM  newServices ;
    SELECT  @newClientServicesCount = @@ROWCOUNT ;


--  6)  INSERT dropped client services into #processClientServicesData, SELECT control counts
      WITH  droppedServices AS (
            SELECT * FROM Conversion.vw_ConvertedClientServices
                EXCEPT
            SELECT * FROM Conversion.vw_LegacyClientServices )

    INSERT  #processClientServicesData ( ClientID, ServiceCode, ClientServiceID, Active )
    SELECT  ClientID, ServiceCode, ClientServiceID, 0
      FROM  droppedServices ;
    SELECT  @droppedClientServicesCount = @@ROWCOUNT ;


--  7)  UPDATE #processClientServicesData with legacy Client change data
    UPDATE  #processClientServicesData
       SET  ModifiedDate = b.ChangeDate
          , ModifiedUser = b.ChangeBy
      FROM  #processClientServicesData  AS a
INNER JOIN  Conversion.vw_LegacyClients AS b ON b.ClientID = a.ClientID ;


--  8)  MERGE #processClientServicesData into dbo.ClientServices
      WITH  clientServices AS (
            SELECT * FROM dbo.ClientServices AS a
             WHERE EXISTS ( SELECT 1 FROM #processClientServicesData AS b WHERE b.ClientID = a.ClientID ) )

     MERGE  clientServices              AS tgt
     USING  #processClientServicesData  AS src
        ON  tgt.ClientID = src.ClientID AND tgt.ClientServiceID = src.ClientServiceID
      WHEN  MATCHED AND tgt.Active <> src.Active THEN
            UPDATE SET  Active       = src.Active
                      , ModifiedDate = src.ModifiedDate
                      , ModifiedUser = src.ModifiedUser
      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( ClientID, ClientServiceID, Active
                        , ModifiedDate, ModifiedUser )
            VALUES ( src.ClientID, src.ClientServiceID, src.Active
                        , src.ModifiedDate, src.ModifiedUser )
    OUTPUT  $action, inserted.ClientID, inserted.Active
      INTO  @clientServicesMergeResults ( Action, ClientID, Active ) ;
    SELECT  @clientServicesMergeCount = @@ROWCOUNT ;


--  9)  SELECT control counts and validate
    SELECT  @newClientServicesActual        = COUNT(*) FROM @clientServicesMergeResults WHERE Active = 1 ;
    SELECT  @droppedClientServicesActual    = COUNT(*) FROM @clientServicesMergeResults WHERE Active = 0 ;
    SELECT  @convertedClientServicesActual  = COUNT(*) FROM Conversion.vw_ConvertedClientServices ;

    IF  ( @convertedClientServicesActual <> ( @convertedClientServicesCount + @newClientServicesCount  - @droppedClientServicesCount ) )
        OR
        ( @convertedClientServicesActual <> @legacyClientServicesCount )
        OR
        ( @clientServicesMergeCount <> ( @newClientServicesCount + @droppedClientServicesCount ) )

    BEGIN
        PRINT 'Control Totals Error!  Please review counts and processing!' ;
        SELECT  @rc = 16 ;
    END


END TRY
BEGIN CATCH
    EXECUTE dbo.processEhlersError ;
    RETURN  16 ;
END CATCH

endOfProc:
--  10) Reset CONTEXT_INFO to re-enable triggering on converted tables
    SET CONTEXT_INFO 0x0 ;


--  11) Print control totals
    PRINT 'Conversion.processClientServices CONTROL TOTALS ' ;
    PRINT '' ;
    PRINT 'Existing Client Services                 = ' + CAST( @convertedClientServicesCount   AS VARCHAR(20) ) ;
    PRINT '    + New Client Services                = ' + CAST( @newClientServicesCount         AS VARCHAR(20) ) ;
    PRINT '' ;
    PRINT '    - Dropped Client Services            = ' + CAST( @droppedClientServicesCount     AS VARCHAR(20) ) ;
    PRINT '                                           --------' ;
    PRINT 'Total Converted Client Services          = ' + CAST( @convertedClientServicesActual  AS VARCHAR(20) ) ;
    PRINT '' ;


    RETURN @rc ;
END
GO

