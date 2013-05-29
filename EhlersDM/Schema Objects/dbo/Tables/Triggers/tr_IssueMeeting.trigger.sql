CREATE TRIGGER  tr_IssueMeeting
            ON  dbo.IssueMeeting
AFTER INSERT, UPDATE, DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_IssueMeeting
     Author:    Chris Carson
    Purpose:    Synchronizes dbo.IssueMeeting with edata.Issues


    revisor         date                description
    ---------       ----------          ----------------------------
    ccarson         2013-01-24          created
    ccarson         ###DATE###          Issues Conversion



************************************************************************************************************************************
*/
BEGIN
BEGIN TRY

    IF  NOT EXISTS ( SELECT 1 FROM inserted WHERE MeetingPurposeID IN ( 3,9 ) )
        IF  NOT EXISTS ( SELECT 1 FROM deleted WHERE MeetingPurposeID IN ( 3,9 ) )
            RETURN ;

    SET NOCOUNT ON ;

    DECLARE @codeBlockNum       AS INT
          , @codeBlockDesc      AS SYSNAME
          , @codeBlockDesc01    AS SYSNAME  = 'Stop processing when trigger is fired from Conversion'
          , @codeBlockDesc02    AS SYSNAME  = 'Stop processing unless Firm data has actually changed'
          , @codeBlockDesc03    AS SYSNAME  = 'MERGE trigger data onto edata.Issues' ;



    DECLARE @fromConversion     AS VARBINARY (128)  = CAST( 'fromConversion' AS VARBINARY (128) ) ;



/**/SELECT  @codeBlockNum = 01, @codeBlockDesc = @codeBlockDesc01 ; --  Stop processing when trigger is fired from Conversion
    IF  CONTEXT_INFO() = @fromConversion
        RETURN ;


/**/SELECT  @codeBlockNum = 02, @codeBlockDesc = @codeBlockDesc02 ; --  MERGE trigger table data into edata.Issues
      WITH  issues AS (
            SELECT  IssueID FROM inserted WHERE MeetingPurposeID IN ( 3, 9 )
                UNION
            SELECT  IssueID FROM deleted WHERE MeetingPurposeID IN ( 3, 9 ) ) ,

            triggerData AS (
            SELECT  TOP 100 PERCENT
                    iss.IssueID, preSaleMeetingType, PreSaleDate, PreSaleTime, AwardTime
              FROM  issues                          AS iss
         LEFT JOIN  Conversion.vw_ConvertedMeetings AS cvm ON cvm.IssueID = iss.IssueID
             ORDER  BY IssueID ) ,

            issueData AS (
            SELECT  TOP 100 PERCENT *
              FROM  edata.Issues
             WHERE  IssueId IN ( SELECT IssueID FROM issues )
             ORDER  BY IssueId )

     MERGE  issueData       AS tgt
     USING  triggerData     AS src ON src.IssueID = src.IssueId
      WHEN  MATCHED THEN
            UPDATE SET      PreSaleMeetingType  = src.PreSaleMeetingType
                          , PreSaleDate         = src.PreSaleDate
                          , PreSaleTime         = src.PreSaleTime
                          , AwardTime           = src.AwardTime
                          , ChangeDate          = GETDATE()
                          , ChangeBy            = 'CVIssueMeeting' ;


END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION ;
    EXECUTE dbo.processEhlersError ;
END CATCH
END