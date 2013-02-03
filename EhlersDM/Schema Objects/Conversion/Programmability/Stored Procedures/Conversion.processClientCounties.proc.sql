CREATE PROCEDURE Conversion.processClientCounties
AS
/*
************************************************************************************************************************************

  Procedure:  Conversion.processClientCounties
     Author:  Chris Carson
    Purpose:  converts legacy Clients data


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
          , @ClientCounties         AS INT = 0
          , @ClientCountiesActual   AS INT = 0
          , @ClientCountiesExpected AS INT = 0
          , @countyChanges          AS INT = 0
          , @countyDELETEs          AS INT = 0
          , @countyINSERTs          AS INT = 0
          , @droppedClientCounties  AS INT = 0
          , @newClientCounties      AS INT = 0
          , @processName            AS VARCHAR(100) = 'processClientCounties'
          , @errorMessage           AS VARCHAR(MAX) = NULL
          , @errorQuery             AS VARCHAR(MAX) = NULL
          , @processClientCounties  AS VARBINARY(128) = CAST( 'processClientCounties' AS VARBINARY(128) ) ;
          
    DECLARE @newCounties            AS TABLE ( ClientID           INT  
                                             , OverlapClientID    INT
                                             , Ordinal            INT ) ; 

    DECLARE @droppedCounties        AS TABLE ( ClientID           INT  
                                             , OverlapClientID    INT
                                             , Ordinal            INT ) ; 

--  1)  Set CONTEXT_INFO to prevent converted tables from triggering changes
    SET CONTEXT_INFO @processClientCounties ;

BEGIN TRY
    SELECT  @ClientCounties = COUNT(*) FROM dbo.ClientOverlap WHERE OverlapTypeID = 1 ; 

    
    INSERT  @newCounties
    SELECT  * FROM Conversion.tvf_ConvertedCounties ( 'Legacy' )
        EXCEPT
    SELECT  * FROM Conversion.tvf_ConvertedCounties ( 'Converted' ) ; 
    SELECT  @newClientCounties = @@ROWCOUNT ;
    
    
    INSERT  @droppedCounties 
    SELECT  * FROM Conversion.tvf_ConvertedCounties ( 'Converted' )
        EXCEPT
    SELECT  * FROM Conversion.tvf_ConvertedCounties ( 'Legacy' ) ; 
    SELECT  @droppedClientCounties = @@ROWCOUNT ;
    
    SELECT  @countyChanges = @newClientCounties + @droppedClientCounties ; 
    
    SELECT  @ClientCountiesExpected = @ClientCounties + @newClientCounties - @droppedClientCounties ;
    
    IF  @countyChanges = 0
    BEGIN
        SELECT @ClientCountiesActual = @ClientCountiesExpected ;
        PRINT   'Counties on edata.dbo.Clients unchanged ' ;
        GOTO endOfProc ;
    END 

    PRINT   'Data has changed, migrating counties on edata.dbo.Clients ' ;
    
      WITH  allCounties AS ( 
            SELECT * FROM dbo.ClientOverlap
             WHERE OverlapTypeID = 1 ) , 
            
            records AS ( 
            SELECT * FROM allCounties AS c 
             WHERE EXISTS ( SELECT 1 FROM @newCounties     AS n WHERE n.ClientID = c.ClientID ) 
                OR EXISTS ( SELECT 1 FROM @droppedCounties AS d WHERE d.ClientID = c.ClientID ) )
                
    DELETE  records ; 
    SELECT  @countyDELETEs = @@ROWCOUNT ; 

    
      WITH  records AS ( 
            SELECT  ClientID        = c.ClientID
                  , OverlapClientID = c.OverlapClientID
                  , OverlapTypeID   = 1
                  , Ordinal         = c.Ordinal
                  , ModifiedDate    = l.ChangeDate
                  , ModifiedUser    = l.ChangeBy
              FROM  Conversion.tvf_ConvertedCounties ( 'Legacy' ) AS c
        INNER JOIN  Conversion.vw_LegacyClients                   AS l ON l.ClientID = c.ClientID 
             WHERE  EXISTS ( SELECT 1 FROM @newCounties     AS n WHERE n.ClientID = c.ClientID ) 
                OR  EXISTS ( SELECT 1 FROM @droppedCounties AS d WHERE d.ClientID = c.ClientID ) ) 
        
    INSERT  dbo.ClientOverlap ( ClientID, OverlapClientID, OverlapTypeID   
                                    , Ordinal, ModifiedDate, ModifiedUser ) 
    SELECT  * FROM records ; 
    SELECT  @countyINSERTs = @@ROWCOUNT ; 
    
    SELECT  @ClientCountiesActual = COUNT(*) FROM dbo.ClientOverlap WHERE OverlapTypeID = 1 ; 
    
    
    IF  ( @ClientCountiesExpected <> @ClientCountiesActual ) 
    BEGIN
        PRINT   'Processing Error: @ClientCountiesExpected  = ' + CAST( @ClientCountiesExpected AS VARCHAR(20) )
              + '                  @ClientCountiesActual    = ' + CAST( @ClientCountiesActual   AS VARCHAR(20) ) + ' .' ;
        SELECT  @rc = 16 ;
    END
    
    GOTO endOfProc ;
    
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
    PRINT 'Conversion.processClientCounties ' ; 
    PRINT 'CONTROL TOTALS ' ;
    PRINT '    dbo.ClientOverlap records = ' + CAST( @ClientCounties          AS VARCHAR(20) ) ;
    PRINT '         new counties         = ' + CAST( @newClientCounties       AS VARCHAR(20) ) ;
    PRINT '         dropped counties     = ' + CAST( @droppedClientCounties   AS VARCHAR(20) ) ;
    PRINT '' ; 
    PRINT '    EXPECTED COUNT            = ' + CAST( @ClientCountiesExpected  AS VARCHAR(20) ) ;
    PRINT '' ; 
    PRINT '    dbo.ClientOverlap records = ' + CAST( @ClientCounties          AS VARCHAR(20) ) ;
    PRINT '         INSERTs              = ' + CAST( @countyINSERTs           AS VARCHAR(20) ) ;
    PRINT '         DELETEs              = ' + CAST( @countyDELETEs           AS VARCHAR(20) ) ;
    PRINT '' ; 
    PRINT '    ACTUAL COUNT              = ' + CAST( @ClientCountiesActual    AS VARCHAR(20) ) ;
    PRINT '' ;

    RETURN @rc ;
END
