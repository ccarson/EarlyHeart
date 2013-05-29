CREATE PROCEDURE Conversion.processIssueMeetings
AS
/*
************************************************************************************************************************************

  Procedure:  Conversion.processIssueMeetings
     Author:  Chris Carson
    Purpose:  Loads legacy Meetings data into dbo.IssueMeeting

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
          , @processName            AS VARCHAR(100) = 'processIssueMeetings'
          , @errorMessage           AS VARCHAR(MAX) = NULL
          , @errorQuery             AS VARCHAR(MAX) = NULL
          , @legacyCount            AS INT = 0
          , @convertedCount         AS INT = 0
          , @convertedActual        AS INT = 0
          , @recordMERGEs           AS INT = 0
          , @newCount               AS INT = 0
          , @droppedCount           AS INT = 0
          , @total                  AS INT = 0
          , @updatedCount           AS INT = 0
          , @fromConversion      AS VARBINARY(128) = CAST( 'fromConversion' AS VARBINARY(128) ) ;

    DECLARE @controlTotalsError     AS VARCHAR (200)    = N'Control Total Failure:  %s = %d, %s = %d' ;

    DECLARE @mergeResults           AS TABLE ( Action NVARCHAR (10) ) ;

--  1)  Set CONTEXT_INFO to prevent converted tables from triggering changes
    SET CONTEXT_INFO @fromConversion ;


--  2)  Create temp storage for changed data from source tables
BEGIN TRY
    SELECT  @legacyCount     = COUNT(*) FROM Conversion.vw_LegacyMeetings ;
    SELECT  @convertedCount  = COUNT(*) FROM dbo.IssueMeeting WHERE MeetingPurposeID IN ( 3, 9 ) ;
    SELECT  @convertedActual = @convertedCount ;


--  3)  MERGE legacy issues data into dbo.IssueMeeting
      WITH  inserts AS (
            SELECT  IssueID, MeetingPurposeID, MeetingTypeID, MeetingDate, MeetingTime, AwardTime FROM Conversion.vw_LegacyMeetings
                EXCEPT
            SELECT  IssueID, MeetingPurposeID, MeetingTypeID, MeetingDate, MeetingTime, AwardTime FROM dbo.IssueMeeting ) ,

            deletes AS (
            SELECT  IssueID, MeetingPurposeID, MeetingTypeID, MeetingDate, MeetingTime, AwardTime FROM dbo.IssueMeeting
             WHERE  MeetingPurposeID IN ( 3, 9 )
                EXCEPT
            SELECT  IssueID, MeetingPurposeID, MeetingTypeID, MeetingDate, MeetingTime, AwardTime FROM Conversion.vw_LegacyMeetings ) ,

            issues AS (
            SELECT IssueID from inserts
                UNION
            SELECT IssueID from deletes ) ,

            newData AS (
            SELECT  IssueID, MeetingPurposeID, MeetingTypeID, MeetingDate, MeetingTime, AwardTime, ModifiedDate, ModifiedUser
              FROM  Conversion.vw_LegacyMeetings   AS lgm
             WHERE  EXISTS ( SELECT 1 FROM inserts AS ins
                              WHERE ins.IssueID = lgm.IssueID and ins.MeetingPurposeID = lgm.MeetingPurposeID ) ),

            issueMeetings AS (
            SELECT  * FROM dbo.IssueMeeting
             WHERE  IssueID IN ( SELECT IssueID FROM issues )
               AND  MeetingPurposeID IN ( 3, 9 ) )

     MERGE  issueMeetings   AS tgt
     USING  newData         AS src ON src.IssueID = tgt.IssueID AND src.MeetingPurposeID = tgt.MeetingPurposeID
      WHEN  MATCHED THEN
            UPDATE  SET     MeetingTypeID   = src.MeetingTypeID
                          , MeetingDate     = src.MeetingDate
                          , MeetingTime     = src.MeetingTime
                          , AwardTime       = src.AwardTime
                          , ModifiedDate    = src.ModifiedDate
                          , ModifiedUser    = src.ModifiedUser

      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( IssueID, MeetingPurposeID, MeetingTypeID
                        , MeetingDate, MeetingTime, AwardTime
                        , ModifiedDate, ModifiedUser )
            VALUES ( src.IssueID, src.MeetingPurposeID, src.MeetingTypeID
                        , src.MeetingDate, src.MeetingTime, src.AwardTime
                        , src.ModifiedDate, src.ModifiedUser )

      WHEN  NOT MATCHED BY SOURCE THEN
            DELETE
    OUTPUT  $action INTO @mergeResults ( Action ) ;
    SELECT  @recordMERGEs = @@ROWCOUNT ;


--  3)  SELECT final control counts
    SELECT  @convertedActual    = COUNT(*) FROM dbo.IssueMeeting WHERE MeetingPurposeID IN ( 3, 9 );
    SELECT  @newCount           = COUNT(*) FROM @mergeResults WHERE Action = 'INSERT' ;
    SELECT  @updatedCount       = COUNT(*) FROM @mergeResults WHERE Action = 'UPDATE' ;
    SELECT  @droppedCount       = COUNT(*) FROM @mergeResults WHERE Action = 'DELETE' ;


--  4)  Validate control counts
    IF  @convertedActual <> @legacyCount
        RAISERROR( @controlTotalsError, 16, 1, 'Converted Meetings', @convertedActual, 'Legacy Meetings', @legacyCount ) ;

    SELECT @total =  @convertedCount + @newCount - @droppedCount ;
    IF  @convertedActual <> @total
        RAISERROR( @controlTotalsError, 16, 1, 'Converted Meetings', @convertedActual, 'Existing Records + Changes', @total ) ;


END TRY
BEGIN CATCH
    EXECUTE dbo.processEhlersError ;
    RETURN  16 ;
END CATCH



endOfProc:
-- 16)  Reset CONTEXT_INFO to re-enable triggering on converted tables
    SET CONTEXT_INFO 0x0 ;


-- 17) Print control totals
    PRINT 'Conversion.processIssueMeetings ' ;
    PRINT 'CONTROL TOTALS ' ;
    PRINT '    Existing Meetings records    = ' + CAST( @convertedCount         AS VARCHAR(20) ) ;
    PRINT '         new Meetings            = ' + CAST( @newCount               AS VARCHAR(20) ) ;
    PRINT '         dropped Meetings        = ' + CAST( @droppedCount           AS VARCHAR(20) ) ;
    PRINT '' ;
    PRINT '    Converted Meetings           = ' + CAST( @convertedActual        AS VARCHAR(20) ) ;
    PRINT '' ;

    RETURN @rc ;
END
