CREATE PROCEDURE Conversion.processClientDCs
AS
/*
************************************************************************************************************************************

  Procedure:  Conversion.processClientDCs
     Author:  Chris Carson
    Purpose:  converts legacy Clients Disclosure Coordinator Data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:


    Notes:
    This proc is similar to processClientAnalysts, except it uses the ClientDCs views rather than ClientAnalysts

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;

    DECLARE @rc                     AS INT = 0
          , @analystChanges         AS INT = 0
          , @analystDELETEs         AS INT = 0
          , @analystINSERTs         AS INT = 0
          , @clientAnalysts         AS INT = 0
          , @clientAnalystsActual   AS INT = 0
          , @clientAnalystsExpected AS INT = 0
          , @droppedClientAnalysts  AS INT = 0
          , @newClientAnalysts      AS INT = 0
          , @processName            AS VARCHAR(100) = 'processClientAnalysts'
          , @errorMessage           AS VARCHAR(MAX) = NULL
          , @errorQuery             AS VARCHAR(MAX) = NULL
          , @processClientAnalysts  AS VARBINARY(128) = CAST( 'processClientAnalysts' AS VARBINARY(128) ) ;
          
    DECLARE @newAnalysts            AS TABLE ( ClientID                     INT  
                                             , EhlersEmployeeJobGroupsID    INT
                                             , Ordinal                      INT ) ; 

    DECLARE @droppedAnalysts        AS TABLE ( ClientID                     INT  
                                             , EhlersEmployeeJobGroupsID    INT
                                             , Ordinal                      INT ) ; 

                                             
--  1)  Set CONTEXT_INFO to prevent converted tables from triggering changes
    SET CONTEXT_INFO @processClientAnalysts ;


--  2)  Create temp storage for changed data from source tables
BEGIN TRY

    SELECT  @ClientAnalysts = COUNT(*) FROM Conversion.tvf_ConvertedDCs( 'Converted' ) ; 

    
    INSERT  @newAnalysts
    SELECT  * FROM Conversion.tvf_ConvertedDCs ( 'Legacy' )
        EXCEPT
    SELECT  * FROM Conversion.tvf_ConvertedDCs ( 'Converted' ) ; 
    SELECT  @newClientAnalysts = COUNT(*) FROM @newAnalysts ;
    
    
    INSERT  @droppedAnalysts
    SELECT  * FROM Conversion.tvf_ConvertedDCs ( 'Converted' )
        EXCEPT
    SELECT  * FROM Conversion.tvf_ConvertedDCs ( 'Legacy' ) ; 
    SELECT  @droppedClientAnalysts = COUNT(*) FROM @droppedAnalysts ;

    SELECT  @analystChanges         = @newClientAnalysts + @droppedClientAnalysts
          , @ClientAnalystsExpected = @ClientAnalysts + @newClientAnalysts - @droppedClientAnalysts ;
    
    IF  @analystChanges = 0
    BEGIN
        SELECT @ClientAnalystsActual = @ClientAnalystsExpected ;
        PRINT   'Analysts on edata.Clients unchanged ' ;
        GOTO endOfProc ;
    END 

    PRINT   'Data has changed, migrating analysts on edata.Clients ' ;

    
      WITH  jobGroups AS ( 
            SELECT  EhlersEmployeeJobGroupsID
              FROM  dbo.EhlersEmployeeJobGroups AS ejg 
        INNER JOIN  dbo.EhlersJobGroup          AS jg  ON jg.EhlersJobGroupID = ejg.EhlersJobGroupID
             WHERE  jg.Value =  'DC' ) , 
             
            clients AS ( 
            SELECT  ClientID FROM @newAnalysts
                UNION
            SELECT  ClientID FROM @droppedAnalysts ) , 

            records AS ( 
            SELECT * FROM dbo.ClientAnalysts AS ca 
             WHERE EXISTS ( SELECT 1 FROM clients   AS c WHERE c.ClientID = ca.ClientID ) 
               AND EXISTS ( SELECT 1 FROM jobGroups AS j WHERE j.EhlersEmployeeJobGroupsID = ca.EhlersEmployeeJobGroupsID ) ) 

    DELETE  records ; 
    SELECT  @analystDELETEs = @@ROWCOUNT ; 
    
    
      WITH  analysts AS ( 
            SELECT * FROM Conversion.tvf_ConvertedDCs ( 'Legacy' ) ) , 

            clients AS ( 
            SELECT  ClientID FROM @newAnalysts
                UNION
            SELECT  ClientID FROM @droppedAnalysts ) , 

            records AS ( 
            SELECT  ClientID                  = a.ClientID
                  , EhlersEmployeeJobGroupsID = a.EhlersEmployeeJobGroupsID
                  , Ordinal                   = a.Ordinal
                  , ModifiedDate              = l.ChangeDate
                  , ModifiedUser              = l.ChangeBy
              FROM  analysts AS a 
        INNER JOIN  Conversion.vw_LegacyClients     AS l ON    l.ClientID = a.ClientID 
             WHERE  EXISTS ( SELECT 1 FROM clients  AS c WHERE c.ClientID = a.ClientID ) ) 

    INSERT  dbo.ClientAnalysts ( ClientID, EhlersEmployeeJobGroupsID, Ordinal, ModifiedDate, ModifiedUser ) 
    SELECT  * FROM records ; 
    SELECT  @analystINSERTs = @@ROWCOUNT ; 
    
    SELECT  @ClientAnalystsActual = COUNT(*) FROM Conversion.tvf_ConvertedDCs ( 'Converted' ) ; 
        
    
    IF  ( @ClientAnalystsExpected <> @ClientAnalystsActual ) 
    BEGIN
        PRINT   'Processing Error: @ClientAnalystsExpected  = ' + CAST( @ClientAnalystsExpected AS VARCHAR(20) )
        PRINT   '                  @ClientAnalystsActual    = ' + CAST( @ClientAnalystsActual   AS VARCHAR(20) ) + ' .' ;
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
    PRINT 'Conversion.processClientDCs ' ; 
    PRINT 'CONTROL TOTALS ' ;
    PRINT '    Client Analyst records    = ' + CAST( @ClientAnalysts          AS VARCHAR(20) ) ;
    PRINT '         new analysts         = ' + CAST( @newClientAnalysts       AS VARCHAR(20) ) ;
    PRINT '         dropped analysts     = ' + CAST( @droppedClientAnalysts   AS VARCHAR(20) ) ;
    PRINT '' ; 
    PRINT '    EXPECTED COUNT            = ' + CAST( @ClientAnalystsExpected  AS VARCHAR(20) ) ;
    PRINT '' ; 
    PRINT '    Client Analyst records    = ' + CAST( @ClientAnalysts          AS VARCHAR(20) ) ;
    PRINT '         INSERTs              = ' + CAST( @analystINSERTs          AS VARCHAR(20) ) ;
    PRINT '         DELETEs              = ' + CAST( @analystDELETEs          AS VARCHAR(20) ) ;
    PRINT '' ; 
    PRINT '    ACTUAL COUNT              = ' + CAST( @ClientAnalystsActual    AS VARCHAR(20) ) ;
    PRINT '' ;

    RETURN @rc ;
END
GO

