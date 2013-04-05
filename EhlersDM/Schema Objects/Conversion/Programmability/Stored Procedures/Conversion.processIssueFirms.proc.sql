CREATE PROCEDURE Conversion.processIssueFirms
AS
/*
************************************************************************************************************************************

  Procedure:    Conversion.processIssueFirms
     Author:    Chris Carson
    Purpose:    converts legacy edata.IssueProfSvcs data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Set CONTEXT_INFO to prevent converted tables from triggering changes
    2)  SELECT initial control counts
    3)  Check for changes in IssueFirms data, skip to next section if no changes
    4)  INSERT new IssueFirms records into @changedIssueFirms
    5)  INSERT dropped IssueFirms records into @changedIssueFirms
    6)  UPDATE @changedIssueFirms with user data from vw_LegacyIssues
    7)  INSERT unchanged IssusFirms records for affected Issues
    8)  MERGE input data into dbo.IssueFirms
    9)  SELECT control counts and validate
   10)  Reset CONTEXT_INFO to re-enable triggering on converted tables
   11)  Print control totals


    Notes:

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;


    DECLARE @fromConversion AS VARBINARY (128) = CAST( 'fromConversion' AS VARBINARY (128) ) ;
          , @processStartTime       AS VARCHAR (30)     = CONVERT( VARCHAR(30), GETDATE(), 121 )
          , @processEndTime         AS VARCHAR (30)     = NULL
          , @processElapsedTime     AS INT              = 0 ;


    DECLARE @codeBlockDesc01        AS SYSNAME    = 'Validate input parameters'
          , @codeBlockDesc02        AS SYSNAME    = 'SET CONTEXT_INFO, inhibiting triggers when invoked'
          , @codeBlockDesc03        AS SYSNAME    = 'SELECT initial control counts'
          , @codeBlockDesc04        AS SYSNAME    = 'INSERT changed data into temp storage'
          , @codeBlockDesc05        AS SYSNAME    = 'Stop processing if there are no data changes'
          , @codeBlockDesc06        AS SYSNAME    = 'INSERT new data into temp storage'
          , @codeBlockDesc07        AS SYSNAME    = 'INSERT updated data into temp storage'
          , @codeBlockDesc08        AS SYSNAME    = 'MERGE temp storage into dbo.Firm'
          , @codeBlockDesc09        AS SYSNAME    = 'SELECT final control counts'
          , @codeBlockDesc10        AS SYSNAME    = 'Control Total Validation'
          , @codeBlockDesc11        AS SYSNAME    = 'Reset CONTEXT_INFO, allowing triggers to fire when invoked'
          , @codeBlockDesc12        AS SYSNAME    = 'Print control totals' ;


    DECLARE @codeBlockNum           AS INT
          , @codeBlockDesc          AS SYSNAME
          , @errorTypeID            AS INT
          , @errorSeverity          AS INT
          , @errorState             AS INT
          , @errorNumber            AS INT
          , @errorLine              AS INT
          , @errorProcedure         AS SYSNAME
          , @errorMessage           AS VARCHAR (MAX) = NULL
          , @errorData              AS VARCHAR (MAX) = NULL ;


    DECLARE @changesCount       AS INT = 0
          , @convertedActual    AS INT = 0
          , @convertedChecksum  AS INT = 0
          , @convertedCount     AS INT = 0
          , @droppedCount       AS INT = 0
          , @legacyChecksum     AS INT = 0
          , @legacyCount        AS INT = 0
          , @newCount           AS INT = 0
          , @recordDELETEs      AS INT = 0
          , @recordINSERTs      AS INT = 0
          , @recordMERGEs       AS INT = 0 
          , @unchangedCount     AS INT = 0 ;


    DECLARE @changedIssueFirms  AS TABLE ( IssueID          INT
                                         , FirmCategoriesID INT
                                         , ModifiedDate     DATETIME
                                         , ModifiedUser     VARCHAR (20) ) ;

    DECLARE @mergeResults       AS TABLE( Action            NVARCHAR(10)
                                        , IssueID           INT
                                        , FirmCategoriesID  INT ) ;



--  1)  Set CONTEXT_INFO to prevent converted tables from triggering changes
BEGIN TRY
    SET CONTEXT_INFO @fromConversion ;


--  2)  SELECT initial control counts
    SELECT  @legacyCount        = COUNT(*) FROM Conversion.tvf_IssueFirms( 'Legacy' ) ;
    SELECT  @convertedCount     = COUNT(*) FROM Conversion.tvf_IssueFirms( 'Converted' ) ;
    SELECT  @convertedActual    = @convertedCount ;


--  3)  Check for changes in IssueFirms data, skip to next section if no changes
    SELECT @legacyChecksum    = CHECKSUM_AGG(CHECKSUM( IssueID, FirmCategoriesID, FirmID, FirmCategoryID, Category )) FROM Conversion.tvf_IssueFirms( 'Legacy' ) ;
    SELECT @convertedChecksum = CHECKSUM_AGG(CHECKSUM( IssueID, FirmCategoriesID, FirmID, FirmCategoryID, Category )) FROM Conversion.tvf_IssueFirms( 'Converted' ) ;

    IF  ( @legacyChecksum = @convertedChecksum )
        GOTO endOfProc ;


--  4)  INSERT new IssueFirms records into @changedIssueFirms
    INSERT  @changedIssueFirms ( IssueID, FirmCategoriesID )
    SELECT  IssueID, FirmCategoriesID FROM Conversion.tvf_IssueFirms ( 'Legacy' )
        EXCEPT
    SELECT  IssueID, FirmCategoriesID FROM Conversion.tvf_IssueFirms ( 'Converted' ) ;
    SELECT  @newCount = @@ROWCOUNT ;


--  5)  INSERT dropped IssueFirms records into @changedIssueFirms
    INSERT  @changedIssueFirms ( IssueID, FirmCategoriesID )
    SELECT  IssueID, FirmCategoriesID FROM Conversion.tvf_IssueFirms ( 'Converted' )
        EXCEPT
    SELECT  IssueID, FirmCategoriesID FROM Conversion.tvf_IssueFirms ( 'Legacy' ) ;
    SELECT  @droppedCount = @@ROWCOUNT ;

    
--  6)  UPDATE @changedIssueFirms with user data from vw_LegacyIssues
    UPDATE  @changedIssueFirms
       SET  ModifiedDate = b.ChangeDate
          , ModifiedUser = ISNULL( NULLIF ( b.ChangeBy, 'processIssues' ), 'processIssueFirms' )
      FROM  @changedIssueFirms          AS a
INNER JOIN  Conversion.vw_LegacyIssues  AS b ON b.IssueID = a.IssueID ;
    SELECT  @changesCount = @@ROWCOUNT ;

    
--  7)  INSERT unchanged IssusFirms records for affected Issues
    INSERT  @changedIssueFirms ( IssueID, FirmCategoriesID )
    SELECT  IssueID, FirmCategoriesID FROM Conversion.tvf_IssueFirms ( 'Legacy' ) AS l 
        WHERE EXISTS ( SELECT 1 from Conversion.tvf_IssueFirms ( 'Converted' ) AS c where c.IssueID = l.IssueID and c.FirmCategoriesID = l.firmCategoriesID ) 
          AND EXISTS ( SELECT 1 FROM @changedIssueFirms AS i where i.IssueID = l.IssueID ) ;
    SELECT  @unchangedCount = @@ROWCOUNT ;

    
--  8)  MERGE input data into dbo.IssueFirms
      WITH  existingIssueFirms AS (
            SELECT * FROM dbo.IssueFirms AS a
             WHERE EXISTS ( SELECT 1 FROM @changedIssueFirms AS b
                             WHERE b.IssueID = a.IssueID ) )

     MERGE  existingIssueFirms AS tgt
     USING  @changedIssueFirms AS src ON tgt.IssueID = src.IssueID AND tgt.FirmCategoriesID = src.FirmCategoriesID
      WHEN  MATCHED AND src.ModifiedDate IS NOT NULL THEN
            DELETE
      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( IssueID, FirmCategoriesID, ModifiedDate, ModifiedUser )
            VALUES ( src.IssueID, src.FirmCategoriesID, src.ModifiedDate, src.ModifiedUser )
    OUTPUT  $action
          , COALESCE ( inserted.IssueID, deleted.IssueID )
          , COALESCE ( inserted.FirmCategoriesID, deleted.FirmCategoriesID )
      INTO  @mergeResults ( Action, IssueID, FirmCategoriesID ) ;
    SELECT  @recordMERGEs = @@ROWCOUNT ;


--  9)  SELECT control counts and validate
    SELECT  @recordINSERTs   = COUNT(*) FROM @mergeResults WHERE action = 'INSERT' ;
    SELECT  @recordDELETEs   = COUNT(*) FROM @mergeResults WHERE action = 'DELETE' ;
    SELECT  @convertedActual = COUNT(*) FROM Conversion.tvf_IssueFirms( 'Converted' ) ;

    IF  ( @convertedActual <> ( @convertedCount + @recordINSERTs - @recordDELETEs ) )
        OR
        ( @convertedActual <> @legacyCount )
        OR
        ( @recordINSERTs <> @newCount )
        OR
        ( @recordDELETEs <> @droppedCount )
        OR
        ( @recordMERGEs <> @changesCount )
        OR
        ( @changesCount <> ( @recordINSERTs + @recordDELETEs ) )
    BEGIN
        PRINT 'Control Totals Error!  Please review counts and processing!' ;
        PRINT '' ;
        PRINT '@convertedActual = ' + STR( @convertedActual, 8 ) ;
        PRINT '@convertedCount  = ' + STR( @convertedCount, 8 ) ;
        PRINT '@recordINSERTs   = ' + STR( @recordINSERTs, 8 ) ;
        PRINT '@recordDELETEs   = ' + STR( @recordDELETEs, 8 ) ;
        PRINT '' ;
        PRINT '@convertedActual = ' + STR( @convertedActual, 8 ) ;
        PRINT '@legacyCount     = ' + STR( @legacyCount, 8 ) ;
        PRINT '' ;
        PRINT '@recordINSERTs   = ' + STR( @recordINSERTs, 8 ) ;
        PRINT '@newCount        = ' + STR( @newCount, 8 ) ;
        PRINT '' ;
        PRINT '@recordDELETEs   = ' + STR( @recordDELETEs, 8 ) ;
        PRINT '@droppedCount    = ' + STR( @droppedCount, 8 ) ;
        PRINT '' ;
        PRINT '@recordMERGEs    = ' + STR( @recordMERGEs, 8 ) ;
        PRINT '@changesCount    = ' + STR( @changesCount, 8 ) ;
        PRINT '' ;
        PRINT '@changesCount    = ' + STR( @changesCount, 8 ) ;
        PRINT '@recordINSERTs   = ' + STR( @recordINSERTs, 8 ) ;
        PRINT '@recordDELETEs   = ' + STR( @recordDELETEs, 8 ) ;
    END


END TRY
BEGIN CATCH
    EXECUTE dbo.processEhlersError ;
END CATCH


endOfProc:

-- 10)  Reset CONTEXT_INFO to re-enable triggering on converted tables
    SET CONTEXT_INFO 0x0 ;


-- 11)  Print control totals
    SELECT  @processEndTime     = GETDATE()
          , @processElapsedTime = DATEDIFF( ms, @processStartTime, @processEndTime ) ;

    PRINT   'Conversion.processIssueFirms CONTROL TOTALS ' ;
    PRINT   'IssueFirms on legacy system             = ' + STR( @legacyCount, 8 ) ;
    PRINT   '' ;
    PRINT   'Existing IssueFirms converted system    = ' + STR( @unchangedCount, 8 ) ;
    PRINT   '     + new records                      = ' + STR( @newCount, 8 ) ;
    PRINT   '     - dropped records                  = ' + STR( @droppedCount, 8 ) ;
    PRINT   '                                           ======= ' ;
    PRINT   'Total IssusFirms on converted system    = ' + STR( @convertedActual, 8 ) ;
    PRINT   '' ;
    PRINT   '' ;
    PRINT   'Database Change Details ' ;
    PRINT   '' ;
    PRINT   '     Total INSERTs dbo.IssueFirms       = ' + STR( @recordINSERTs, 8 ) ;
    PRINT   '     Total DELETEs dbo.IssueFirms       = ' + STR( @recordDELETEs, 8 ) ;
    PRINT   '' ;
    PRINT   '     TOTAL changes on dbo.IssueFirms    = ' + STR( @recordMERGEs, 8 ) ;
    PRINT   '' ;
    PRINT   'processIssues START : ' + CONVERT( VARCHAR (30), @processStartTime, 121 ) ;
    PRINT   'processIssues   END : ' + CONVERT( VARCHAR (30), @processEndTime, 121 ) ;
    PRINT   '       Elapsed Time : ' + CAST ( @processElapsedTime AS VARCHAR (20) ) + ' ms' ;


END
GO
