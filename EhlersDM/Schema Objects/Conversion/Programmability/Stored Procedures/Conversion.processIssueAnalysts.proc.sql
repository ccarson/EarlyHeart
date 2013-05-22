CREATE PROCEDURE Conversion.processIssueAnalysts
AS
/*
************************************************************************************************************************************

  Procedure:  Conversion.processIssueAnalysts
     Author:  Chris Carson
    Purpose:  converts legacy Clients Analyst Data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:


    Notes:

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;

    DECLARE @rc                     AS INT              = 0
          , @processName            AS VARCHAR(100)     = 'processIssueAnalysts'
          , @errorMessage           AS VARCHAR(MAX)     = NULL
          , @errorQuery             AS VARCHAR(MAX)     = NULL 
          , @processIssueAnalysts   AS VARBINARY(128)    = CAST( 'processIssueAnalysts' AS VARBINARY(128) ) ;
          

    DECLARE @analystChanges         AS INT = 0
          , @analystDELETEs         AS INT = 0
          , @analystErrorsCount     AS INT = 0
          , @analystINSERTs         AS INT = 0
          , @ClientAnalysts         AS INT = 0
          , @ClientAnalystsActual   AS INT = 0
          , @ClientAnalystsExpected AS INT = 0
          , @droppedAnalystsCount   AS INT = 0
          , @newAnalystsCount       AS INT = 0 ; 

          
          
    DECLARE @newAnalysts            AS TABLE ( ClientID                     INT  
                                             , EhlersEmployeeJobGroupsID    INT
                                             , Ordinal                      INT ) ; 

    DECLARE @droppedAnalysts        AS TABLE ( ClientID                     INT  
                                             , EhlersEmployeeJobGroupsID    INT
                                             , Ordinal                      INT ) ; 

    DECLARE @analystErrors          AS TABLE ( ClientID                     INT  
                                             , ClientName                   VARCHAR(100) 
                                             , EhlersContact1               VARCHAR(20) 
                                             , EhlersContact2               VARCHAR(20)                                              
                                             , EhlersContact3               VARCHAR(20)                   
                                             , OriginatingFA1               VARCHAR(20)                   
                                             , OriginatingFA2               VARCHAR(20)                   
                                             , Ordinal                      INT ) ;                                              
                                             
--  1)  Set CONTEXT_INFO to prevent converted tables from triggering changes
    SET CONTEXT_INFO @processIssueAnalysts ;


--  2)  Create temp storage for changed data from source tables
BEGIN TRY
    SELECT  @ClientAnalysts = COUNT(*) FROM Conversion.tvf_ConvertedAnalysts( 'Converted' ) ; 

    
    INSERT  @newAnalysts
    SELECT  * FROM Conversion.tvf_ConvertedAnalysts ( 'Legacy' )
        EXCEPT
    SELECT  * FROM Conversion.tvf_ConvertedAnalysts ( 'Converted' ) ; 
    SELECT  @newAnalystsCount = COUNT(*) FROM @newAnalysts ;
    
    
    INSERT  @droppedAnalysts
    SELECT  * FROM Conversion.tvf_ConvertedAnalysts ( 'Converted' )
        EXCEPT
    SELECT  * FROM Conversion.tvf_ConvertedAnalysts ( 'Legacy' ) ; 
    SELECT  @droppedAnalystsCount = COUNT(*) FROM @droppedAnalysts ;

    SELECT  @analystChanges         = @newAnalystsCount + @droppedAnalystsCount
          , @ClientAnalystsExpected = @ClientAnalysts + @newAnalystsCount - @droppedAnalystsCount ;
    
    IF  @analystChanges = 0
    BEGIN
        SELECT @ClientAnalystsActual = @ClientAnalystsExpected ;
        PRINT   'Analysts on edata.Clients unchanged ' ;
        GOTO endOfProc ;
    END 

    PRINT   'Data has changed, migrating analysts on edata.Clients ' ;
    
    INSERT  @analystErrors
    SELECT  l.ClientID
          , c.ClientName
	      , l.EhlersContact1
	      , l.EhlersContact2
	      , l.EhlersContact3
	      , l.OriginatingFA1
	      , l.OriginatingFA2
	      , n.Ordinal 
	  FROM  Conversion.tvf_LegacyAnalysts('Legacy') AS l 
INNER JOIN  @newAnalysts                            AS n ON n.ClientID = l.ClientID
INNER JOIN  Conversion.vw_LegacyClients             AS c ON c.ClientID = l.ClientID
     WHERE  n.EhlersEmployeeJobGroupsID IS NULL ; 
    SELECT  @analystErrorsCount = @@ROWCOUNT ; 
    
    IF  @analystErrorsCount > 0 
        SELECT  @errorMessage = '</br><H2><b>These Client Analysts will not convert.</b></H2></br></br>' 
                              + '<b>Instructions for resolving reported errors:</b></br>' 
                              + '&nbsp;&nbsp;1)&nbsp;&nbsp;Use the Ordinal column to determine which Analyst initials cannot convert. </br>' 
                              + '&nbsp;&nbsp;2)&nbsp;&nbsp;Make the appropriate entries into the Employee and EmployeeJobGroups tables </br>' 
                              + '&nbsp;&nbsp;3)&nbsp;&nbsp;Mark the new Employee or EmployeeJobGroups entries as Inactive </br>' 
                              + '</br><b>ALTERNATE METHODS ( not recommended )</b></br>' 
                              + '&nbsp;&nbsp;A)&nbsp;&nbsp;Clear the entries from the legacy Clients application <i>( not recommended )</i></br>' 
                              + '&nbsp;&nbsp;B)&nbsp;&nbsp;Update the current client with corrected analyst data</br></br>' 
              , @errorQuery   = N'<b>Client Analysts that can not convert</b></br></br>'
                              + N'<table border="1">' 
                              + N'<tr><th>ClientID</th>'
                              + N'<th>Client Name</th>'
                              + N'<th>EhlersContact1</th>'
                              + N'<th>EhlersContact2</th>'
                              + N'<th>EhlersContact3</th>'
                              + N'<th>OriginatingFA1</th>'                              
                              + N'<th>OriginatingFA2</th>'
                              + N'<th>Ordinal</th></tr>' 
                              + CAST ( ( SELECT td = ClientID, ''
                                              , td = ISNULL( ClientName, '' ), ''     
                                              , td = ISNULL( EhlersContact1, '--' ), ''     
                                              , td = ISNULL( EhlersContact2, '--' ), ''                             
                                              , td = ISNULL( EhlersContact3, '--' ), ''                             
                                              , td = ISNULL( OriginatingFA1, '--' ), ''                             
                                              , td = ISNULL( OriginatingFA2, '--' ), ''                             
                                              , td = Ordinal
                                           FROM @analystErrors
                                          ORDER BY 1
                                            FOR XML PATH('tr'), TYPE ) AS NVARCHAR(MAX) ) 
                              + N'</table>' ;    
    
    
      WITH  jobGroups AS ( 
            SELECT  EhlersEmployeeJobGroupsID
              FROM  dbo.EhlersEmployeeJobGroups AS ejg 
        INNER JOIN  dbo.EhlersJobGroup          AS jg  ON jg.EhlersJobGroupID = ejg.EhlersJobGroupID
             WHERE  jg.Value IN ( 'FA', 'FS' ) ) , 
             
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
            SELECT * FROM Conversion.tvf_ConvertedAnalysts ( 'Legacy' ) 
             WHERE EhlersEmployeeJobGroupsID IS NOT NULL ) , 
            
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

    INSERT  dbo.ClientAnalysts ( ClientID, EhlersEmployeeJobGroupsID, Ordinal , ModifiedDate, ModifiedUser ) 
    SELECT  * FROM records ; 
    SELECT  @analystINSERTs = @@ROWCOUNT ; 
    
    SELECT  @ClientAnalystsActual = COUNT(*) FROM Conversion.tvf_ConvertedAnalysts ( 'Converted' ) ; 
        
    
    IF  ( @ClientAnalystsExpected <> ( @ClientAnalystsActual + @analystErrorsCount ) )
    BEGIN
        PRINT   'Processing Error: @ClientAnalystsExpected  = ' + CAST( @ClientAnalystsExpected AS VARCHAR(20) ) ;
        PRINT   '                    @ClientAnalystsActual  = ' + CAST( @ClientAnalystsActual   AS VARCHAR(20) ) ;
        PRINT   '                    @analystErrorsCount    = ' + CAST( @analystErrorsCount     AS VARCHAR(20) ) ;
        SELECT  @rc = 16 ;
    END
    
    IF  ( @analystErrorsCount = 0 )
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
    PRINT 'Conversion.processClientAnalysts ' ; 
    PRINT 'CONTROL TOTALS ' ;
    PRINT '    Client Analyst records    = ' + CAST( @ClientAnalysts          AS VARCHAR(20) ) ;
    PRINT '         new analysts         = ' + CAST( @newAnalystsCount        AS VARCHAR(20) ) ;
    PRINT '         dropped analysts     = ' + CAST( @droppedAnalystsCount    AS VARCHAR(20) ) ;
    PRINT '' ; 
    PRINT '    EXPECTED COUNT            = ' + CAST( @ClientAnalystsExpected  AS VARCHAR(20) ) ;
    PRINT '' ; 
    PRINT '    Client Analyst records    = ' + CAST( @ClientAnalysts          AS VARCHAR(20) ) ;
    PRINT '         INSERTs              = ' + CAST( @analystINSERTs          AS VARCHAR(20) ) ;
    PRINT '         DELETEs              = ' + CAST( @analystDELETEs          AS VARCHAR(20) ) ;
    PRINT '' ; 
    PRINT '    ACTUAL COUNT              = ' + CAST( @ClientAnalystsActual    AS VARCHAR(20) ) ;
    PRINT '' ;
    PRINT '    Client Analyst Errors     = ' + CAST( @analystErrorsCount      AS VARCHAR(20) ) ;
    PRINT '' ;

    RETURN @rc ;
END
