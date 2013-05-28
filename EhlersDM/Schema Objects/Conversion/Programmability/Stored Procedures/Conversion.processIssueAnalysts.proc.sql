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
          , @IssueAnalysts         AS INT = 0
          , @IssueAnalystsActual   AS INT = 0
          , @IssueAnalystsExpected AS INT = 0
          , @droppedAnalystsCount   AS INT = 0
          , @newAnalystsCount       AS INT = 0 ;



    DECLARE @newAnalysts            AS TABLE ( IssueId                      INT
                                             , EhlersEmployeeJobGroupsID    INT
                                             , Ordinal                      INT ) ;

    DECLARE @droppedAnalysts        AS TABLE ( IssueId                      INT
                                             , EhlersEmployeeJobGroupsID    INT
                                             , Ordinal                      INT ) ;


--  1)  Set CONTEXT_INFO to prevent converted tables from triggering changes
    SET CONTEXT_INFO @processIssueAnalysts ;


    
BEGIN TRY
    SELECT  @IssueAnalysts = COUNT(*) FROM Conversion.tvf_ConvertedIssueAnalysts( 'Converted' ) ;
    
      WITH  inserts AS (
            SELECT  IssueID, EhlersEmployeeJobGroupsID, Ordinal FROM Conversion.tvf_ConvertedIssueAnalysts ( 'Legacy' )
                EXCEPT
            SELECT  IssueID, EhlersEmployeeJobGroupsID, Ordinal FROM Conversion.tvf_ConvertedIssueAnalysts ( 'Converted' ) ) ,

            deletes AS (
            SELECT  IssueID, EhlersEmployeeJobGroupsID, Ordinal FROM Conversion.tvf_ConvertedIssueAnalysts ( 'Converted' )
                EXCEPT
            SELECT  IssueID, EhlersEmployeeJobGroupsID, Ordinal FROM Conversion.tvf_ConvertedIssueAnalysts ( 'Legacy' ) ) , 

            issues AS (
            SELECT  IssueID FROM inserts
                UNION
            SELECT  IssueID FROM deletes ) ,

            jobGroups AS (
            SELECT  EhlersEmployeeJobGroupsID
              FROM  dbo.EhlersEmployeeJobGroups AS ejg
        INNER JOIN  dbo.EhlersJobGroup          AS jg  ON jg.EhlersJobGroupID = ejg.EhlersJobGroupID
             WHERE  jg.Value IN ( 'FA', 'FS', 'DC', 'BSC' ) ) 

    DELETE  dbo.IssueEhlersEmployees
     WHERE  IssueID IN ( SELECT IssueID FROM issues ) 
       AND  EhlersEmployeeJobGroupsID IN ( SELECT EhlersEmployeeJobGroupsID FROM jobGroups ) ; 
    SELECT  @analystDELETEs = @@ROWCOUNT ;
             
             
      WITH  inserts AS (
            SELECT  IssueID, EhlersEmployeeJobGroupsID, Ordinal FROM Conversion.tvf_ConvertedIssueAnalysts ( 'Legacy' )
                EXCEPT
            SELECT  IssueID, EhlersEmployeeJobGroupsID, Ordinal FROM Conversion.tvf_ConvertedIssueAnalysts ( 'Converted' ) ) ,

            newData AS (
            SELECT  IssueID                     = ins.IssueID
                  , EhlersEmployeeJobGroupsID   = ins.EhlersEmployeeJobGroupsID
                  , Ordinal                     = ins.Ordinal
                  , IsSaleDayAvailable          = 1
                  , IsSaleDayAttending          = 1
                  , ModifiedDate                = iss.ChangeDate
                  , ModifiedUser                = ISNULL( NULLIF( iss.ChangeBy, 'processIssues' ), 'processIssueAnalysts' )
              FROM  inserts                     AS ins
        INNER JOIN  Conversion.vw_LegacyIssues  AS iss ON iss.IssueID = ins.IssueID )

    INSERT  dbo.IssueEhlersEmployees ( 
            IssueID, EhlersEmployeeJobGroupsID, Ordinal, IsSaleDayAvailable, IsSaleDayAttending, ModifiedDate, ModifiedUser )
    SELECT  IssueID, EhlersEmployeeJobGroupsID, Ordinal, IsSaleDayAvailable, IsSaleDayAttending, ModifiedDate, ModifiedUser 
      FROM  newData ; 
    SELECT  @analystINSERTs = @@ROWCOUNT ;
             

    SELECT  @IssueAnalystsActual = COUNT(*) FROM Conversion.tvf_ConvertedIssueAnalysts ( 'Converted' ) ;


    IF  ( @IssueAnalystsExpected <> ( @IssueAnalystsActual + @analystErrorsCount ) )
    BEGIN
        PRINT   'Processing Error: @ClientAnalystsExpected  = ' + CAST( @IssueAnalystsExpected AS VARCHAR(20) ) ;
        PRINT   '                    @ClientAnalystsActual  = ' + CAST( @IssueAnalystsActual   AS VARCHAR(20) ) ;
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
    PRINT '    Client Analyst records    = ' + CAST( @IssueAnalysts          AS VARCHAR(20) ) ;
    PRINT '         new analysts         = ' + CAST( @newAnalystsCount        AS VARCHAR(20) ) ;
    PRINT '         dropped analysts     = ' + CAST( @droppedAnalystsCount    AS VARCHAR(20) ) ;
    PRINT '' ;
    PRINT '    EXPECTED COUNT            = ' + CAST( @IssueAnalystsExpected  AS VARCHAR(20) ) ;
    PRINT '' ;
    PRINT '    Client Analyst records    = ' + CAST( @IssueAnalysts          AS VARCHAR(20) ) ;
    PRINT '         INSERTs              = ' + CAST( @analystINSERTs          AS VARCHAR(20) ) ;
    PRINT '         DELETEs              = ' + CAST( @analystDELETEs          AS VARCHAR(20) ) ;
    PRINT '' ;
    PRINT '    ACTUAL COUNT              = ' + CAST( @IssueAnalystsActual    AS VARCHAR(20) ) ;
    PRINT '' ;
    PRINT '    Client Analyst Errors     = ' + CAST( @analystErrorsCount      AS VARCHAR(20) ) ;
    PRINT '' ;

    RETURN @rc ;
END
