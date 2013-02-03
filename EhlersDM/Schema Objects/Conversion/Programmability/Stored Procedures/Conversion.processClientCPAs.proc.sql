CREATE PROCEDURE Conversion.processClientCPAs
AS
/*
************************************************************************************************************************************

  Procedure:  Conversion.processClientCPAs
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

    DECLARE @rc                     AS INT = 0
          , @processName            AS VARCHAR(100) = 'processClientCPAs'
          , @errorMessage           AS VARCHAR(MAX) = NULL
          , @errorQuery             AS VARCHAR(MAX) = NULL
          , @ClientCPAChanges       AS INT = 0
          , @ClientCPAErrorCount    AS INT = 0
          , @ClientCPAs             AS INT = 0
          , @ClientCPAsActual       AS INT = 0
          , @clientCPAsDELETEd      AS INT = 0
          , @ClientCPAsExpected     AS INT = 0
          , @clientCPAsINSERTed     AS INT = 0
          , @droppedClientCPAsCount AS INT = 0
          , @newClientCPAsCount     AS INT = 0
          , @processClientCPAs      AS VARBINARY(128) = CAST( 'processClientCPAs' AS VARBINARY(128) ) ;

    DECLARE @newClientCPAs          AS TABLE ( ClientID         INT
                                             , ClientCPA        VARCHAR(100)
                                             , ClientCPAFirmID  INT
                                             , FirmCategoriesID INT ) ;

    DECLARE @droppedClientCPAs      AS TABLE ( ClientID         INT
                                             , ClientCPA        VARCHAR(100)
                                             , ClientCPAFirmID  INT
                                             , FirmCategoriesID INT ) ;


--  1)  Set CONTEXT_INFO to prevent converted tables from triggering changes
    SET CONTEXT_INFO @processClientCPAs ;


--  2)  Create temp storage for changed data from source tables
BEGIN TRY
    SELECT  @ClientCPAs = COUNT(*) FROM Conversion.tvf_ClientCPAs ( 'Converted' ) ;

    INSERT  @newClientCPAs
    SELECT  * FROM Conversion.tvf_ClientCPAs ( 'Legacy' )
        EXCEPT
    SELECT  * FROM Conversion.tvf_ClientCPAs ( 'Converted' ) ;
    SELECT  @newClientCPAsCount = @@ROWCOUNT ;


    INSERT  @droppedClientCPAs
    SELECT  * FROM Conversion.tvf_ClientCPAs ( 'Converted' )
        EXCEPT
    SELECT  * FROM Conversion.tvf_ClientCPAs ( 'Legacy' ) ;
    SELECT  @droppedClientCPAsCount = @@ROWCOUNT ;

    SELECT  @ClientCPAChanges = @newClientCPAsCount + @droppedClientCPAsCount ;

    SELECT  @ClientCPAsExpected = @ClientCPAs + @newClientCPAsCount - @droppedClientCPAsCount ;

    IF  @ClientCPAChanges = 0
    BEGIN
        SELECT @ClientCPAsActual = @ClientCPAsExpected ;
        PRINT   'ClientCPA data on edata.dbo.Clients unchanged ' ;
        GOTO endOfProc ;
    END

    PRINT   'Data has changed, migrating ClientCPA data from edata.dbo.Clients ' ;


      WITH  allClientCPAs AS (
            SELECT * FROM dbo.ClientFirms AS cf
             WHERE EXISTS ( SELECT 1 FROM Conversion.tvf_ClientCPAs ( 'Converted' ) AS c
                             WHERE c.ClientID = cf.ClientID and c.FirmCategoriesID = cf.FirmCategoriesID ) ) ,

            records AS (
            SELECT * FROM allClientCPAs AS c
             WHERE EXISTS ( SELECT 1 FROM @newClientCPAs     AS n WHERE n.ClientID = c.ClientID )
                OR EXISTS ( SELECT 1 FROM @droppedClientCPAs AS d WHERE d.ClientID = c.ClientID ) )

    DELETE  records ;
    SELECT  @clientCPAsDELETEd = @@ROWCOUNT ;


      WITH  records AS (
            SELECT  ClientID         = c.ClientID
                  , FirmCategoriesID = c.FirmCategoriesID
                  , ModifiedDate     = l.ChangeDate
                  , ModifiedUser     = l.ChangeBy
              FROM  Conversion.tvf_ClientCPAs ( 'Legacy' )    AS c
        INNER JOIN  Conversion.vw_LegacyClients               AS l ON l.ClientID = c.ClientID
             WHERE  EXISTS ( SELECT 1 FROM @newClientCPAs     AS n WHERE n.ClientID = c.ClientID )
                OR  EXISTS ( SELECT 1 FROM @droppedClientCPAs AS d WHERE d.ClientID = c.ClientID ) )

    INSERT  dbo.ClientFirms ( ClientID, FirmCategoriesID, ModifiedDate, ModifiedUser )
    SELECT  * FROM records WHERE FirmCategoriesID > 0 ;
    SELECT  @clientCPAsINSERTed = @@ROWCOUNT ;

    SELECT  @ClientCPAsActual = COUNT(*)
      FROM  Conversion.tvf_ClientCPAs ( 'Converted' ) ;


    IF  ( @ClientCPAsExpected <> ( @ClientCPAsActual + @ClientCPAErrorCount ) )
    BEGIN
        PRINT   'Processing Error: @ClientCPAsExpected    = ' + CAST( @ClientCPAsExpected   AS VARCHAR(20) ) ;
        PRINT   '                    @ClientCPAsActual    = ' + CAST( @ClientCPAsActual     AS VARCHAR(20) ) ;
        PRINT   '                    @ClientCPAErrorCount = ' + CAST( @ClientCPAErrorCount  AS VARCHAR(20) ) ;
        SELECT  @rc = 0 ;
        GOTO endOfProc ;
    END

    IF  ( @ClientCPAErrorCount = 0 )
        GOTO endOfProc ;
    ELSE
        GOTO processingError ;


END TRY
BEGIN CATCH
    EXECUTE dbo.processEhlersError ;
    RETURN  16 ;
END CATCH

processingError:
-- 10)  Invoke error handling on any business logic or audit count errors

    EXECUTE dbo.processEhlersError    @processName
                                    , @errorMessage
                                    , @errorQuery ;

endOfProc:
-- 16)  Reset CONTEXT_INFO to re-enable triggering on converted tables
    SET CONTEXT_INFO 0x0 ;


-- 17) Print control totals
    PRINT 'Conversion.processClientCPAs ' ;
    PRINT 'CONTROL TOTALS ' ;
    PRINT '    Existing ClientCPA records   = ' + CAST( @ClientCPAs             AS VARCHAR(20) ) ;
    PRINT '         new ClientCPAs          = ' + CAST( @newClientCPAsCount     AS VARCHAR(20) ) ;
    PRINT '         dropped ClientCPAs      = ' + CAST( @droppedClientCPAsCount AS VARCHAR(20) ) ;
    PRINT '' ;
    PRINT '    EXPECTED COUNT               = ' + CAST( @ClientCPAsExpected     AS VARCHAR(20) ) ;
    PRINT '' ;
    PRINT '    Converted ClientCPA records  = ' + CAST( @ClientCPAs             AS VARCHAR(20) ) ;
    PRINT '         INSERTs                 = ' + CAST( @clientCPAsINSERTed     AS VARCHAR(20) ) ;
    PRINT '         DELETEs                 = ' + CAST( @clientCPAsDELETEd      AS VARCHAR(20) ) ;
    PRINT '' ;
    PRINT '    ACTUAL COUNT                 = ' + CAST( @ClientCPAsActual       AS VARCHAR(20) ) ;
    PRINT '' ;
    PRINT '    ClientCPA Errors             = ' + CAST( @ClientCPAErrorCount    AS VARCHAR(20) ) ;
    PRINT '' ;

    RETURN @rc ;
END
