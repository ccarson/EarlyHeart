CREATE PROCEDURE Conversion.processCalls
AS
/*
************************************************************************************************************************************

  Procedure:    Conversion.processCalls
     Author:    Chris Carson
    Purpose:    converts legacy data from dbo.Calls


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Set CONTEXT_INFO to prevent converted tables from triggering changes
    2)  Create temp storage for changed data
    3)  Check for changes, skip to next process if none
    4)  load records where IssueCallID == 0, these are INSERTs
    5)  load records where IssueCallID != 0, these are UPDATEDs
    6)  Throw error if no records are loaded
    7)  MERGE #processCallsData with dbo.IssueCall
    8)  Reset CONTEXT_INFO to re-enable converted table triggers
    9)  Print control totals

    Notes:

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;

    DECLARE @currentIssueCallID  AS INT = 0
          , @rc                  AS INT = 0
          , @recordsINSERTed     AS INT = 0
          , @recordsToDelete     AS INT = 0
          , @recordsToInsert     AS INT = 0
          , @recordsDELETEd      AS INT = 0
          , @recordsMERGEd       AS INT = 0
          , @recordsToUpdate     AS INT = 0
          , @recordsUPDATEd      AS INT = 0
          , @totalRecords        AS INT = 0
          , @processCalls        AS VARBINARY(128) = CAST( 'processCalls' AS VARBINARY(128) ) ;


--  1)  Set CONTEXT_INFO to prevent converted tables from triggering changes
    SET CONTEXT_INFO @processCalls ;


--  2)  Create temp storage for changed data
    IF  OBJECT_ID('tempdb..#processCallsData') IS NOT NULL
        DROP TABLE #processCallsData ;
    CREATE  TABLE #processCallsData (
            IssueCallID       INT   NOT NULL  PRIMARY KEY CLUSTERED
          , IssueID           INT   NOT NULL
          , FirstCallDate     DATE
          , CallPrice         DECIMAL(12,8)
          , CallableMatDate   DATE ) ;

    IF  OBJECT_ID ('tempdb..#changedCalls') IS NOT NULL
        DROP TABLE #changedCalls ;
    CREATE  TABLE    #changedCalls (
            IssueCallID         INT
          , IssueCallChecksum   VARBINARY(128) ) ;


--  3)  Check for changes, skip to next process if none
    INSERT  #changedCalls
    SELECT  IssueCallID, IssueCallChecksum
      FROM  Conversion.tvf_IssueCallChecksum( 'Legacy' )
        EXCEPT
    SELECT  IssueCallID, IssueCallChecksum
      FROM  Conversion.tvf_IssueCallChecksum( 'Converted' ) ;
    SELECT  @totalRecords = @@ROWCOUNT ;

    IF  ( @totalRecords = 0  )
        BEGIN
            PRINT 'No data has changed, exiting processCalls' ;
            GOTO endOfProc ;
        END
    ELSE
        PRINT 'Data has changed, migrating Calls data' ;


--  4)  load records where IssueCallID == 0, these are INSERTs
    SELECT  @currentIssueCallID = ISNULL( IDENT_CURRENT('dbo.IssueCall'), 0 ) ;

    INSERT  #processCallsData
    SELECT  IssueCallID     = @currentIssueCallID +
                              ROW_NUMBER() OVER ( ORDER BY (SELECT NULL) )
          , IssueID         = IssueID
          , FirstCallDate   = FirstCallDate
          , CallPrice       = CallPrice
          , CallableMatDate = CallableMatDate
      FROM  Conversion.vw_LegacyCalls
     WHERE  IssueCallID = 0
     ORDER  BY 2,3,4 ;
    SELECT  @recordsToInsert = @@ROWCOUNT ;


--  5)  load records where IssueCallID != 0, these are UPDATEDs
    INSERT  #processCallsData
    SELECT  IssueCallID
          , IssueID
          , FirstCallDate
          , CallPrice
          , CallableMatDate
      FROM  Conversion.vw_LegacyCalls AS a
     WHERE  a.IssueCallID <> 0
            AND EXISTS ( SELECT 1 FROM #changedCalls AS b WHERE a.IssueCallID = b.IssueCallID ) ;
    SELECT  @recordsToUpdate = @@ROWCOUNT ;


--  6)  Throw error if no records are loaded
    SELECT  @totalRecords = @recordsToInsert + @recordsToUpdate ;
    IF  @totalRecords = 0
    BEGIN
        PRINT   'Error:  changes detected but not captured' ;
        SELECT  @rc = 16 ;
        GOTO    endOfProc ;
    END


--  7)  MERGE #processCallsData with dbo.IssueCall
    DECLARE @SummaryOfChanges AS TABLE( Change NVARCHAR(10) ) ;

    SET IDENTITY_INSERT dbo.IssueCall ON ;

     MERGE  dbo.IssueCall     AS tgt
     USING  #processCallsData AS src
        ON  tgt.IssueCallID = src.IssueCallID
      WHEN  MATCHED THEN
            UPDATE
               SET  CallDate               = src.FirstCallDate
                  , CallPricePercent       = src.CallPrice
                  , FirstCallableMatDate   = src.CallableMatDate
                  , ModifiedDate           = GETDATE()
                  , ModifiedUser           = 'processCalls'
      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( IssueCallID, IssueID, CallTypeID
                        , CallDate
                        , CallPricePercent
                        , FirstCallableMatDate
                        , ModifiedDate, ModifiedUser )
            VALUES ( src.IssueCallID, src.IssueID, 3
                        , src.FirstCallDate
                        , src.CallPrice
                        , src.CallableMatDate
                        , GETDATE(), 'processCalls' )
    OUTPUT  $action
      INTO  @SummaryOfChanges ;
    SELECT  @recordsMERGEd = @@ROWCOUNT ;

    SET IDENTITY_INSERT dbo.IssueCall OFF ;

    IF  @recordsMERGEd <> @totalRecords
    BEGIN
        PRINT   'Processing Error: @totalRecords  = ' + CAST( @totalRecords AS VARCHAR(20) )
              + '                  @recordsMERGEd = ' + CAST( @recordsMERGEd AS VARCHAR(20) ) + ' .' ;
        SELECT  @rc = 16 ;
    END


    SELECT     @recordsINSERTed = COUNT(*) FROM @SummaryOfChanges WHERE Change = 'INSERT' ;
    IF  @recordsINSERTed <> @recordsToInsert
    BEGIN
        PRINT   'Error ON INSERT:  @recordsToInsert = ' + CAST( @recordsToInsert AS VARCHAR(20) )
              + '                  @recordsINSERTed = ' + CAST( @recordsINSERTed AS VARCHAR(20) ) + ' .' ;
        SELECT  @rc = 16 ;
    END

    SELECT  @recordsUPDATEd = COUNT(*) FROM @SummaryOfChanges WHERE Change = 'UPDATE' ;
    IF @recordsUPDATEd <> @recordsToUpdate
    BEGIN
        PRINT   'Error ON UPDATE:  @recordsToUpdate = ' + CAST( @recordsToUpdate AS VARCHAR(20) )
              + '                  @recordsUPDATEd  = ' + CAST( @recordsUPDATEd AS VARCHAR(20) ) + ' .' ;
        SELECT  @rc = 16 ;
    END

    SELECT     @recordsDELETEd = COUNT(*) FROM @SummaryOfChanges WHERE Change = 'DELETE' ;
    IF @recordsDELETEd <> @recordsToDelete
    BEGIN
        PRINT   'Error ON UPDATE:  @recordsToDelete = ' + CAST( @recordsToDelete AS VARCHAR(20) )
              + '                  @recordsDELETEd  = ' + CAST( @recordsDELETEd AS VARCHAR(20) ) + ' .' ;
        SELECT  @rc = 16 ;
    END


endOfProc:
--  8)  Reset CONTEXT_INFO to re-enable converted table triggers
     SET CONTEXT_INFO 0x0 ;


--  9)  Print control totals
    PRINT 'CONTROL TOTALS ' ;
    PRINT '    Changed records                  = ' + CAST( @totalRecords    AS VARCHAR(20) ) ;
    PRINT '         new records                 = ' + CAST( @recordsToInsert AS VARCHAR(20) ) ;
    PRINT '         modified records            = ' + CAST( @recordsToUpdate AS VARCHAR(20) ) ;
    PRINT '         deleted records             = ' + CAST( @recordsToDelete AS VARCHAR(20) ) ;
    PRINT '' ;
    PRINT '    Processed records                = ' + CAST( @recordsMERGEd   AS VARCHAR(20) ) ;
    PRINT '         INSERTs to dbo.IssueCall    = ' + CAST( @recordsINSERTed AS VARCHAR(20) ) ;
    PRINT '         UPDATEs to dbo.IssueCall    = ' + CAST( @recordsUPDATEd  AS VARCHAR(20) ) ;
    PRINT '         DELETEs from dbo.IssueCall  = ' + CAST( @recordsDELETEd  AS VARCHAR(20) ) ;
    PRINT '' ;

    RETURN  @rc ;
END
