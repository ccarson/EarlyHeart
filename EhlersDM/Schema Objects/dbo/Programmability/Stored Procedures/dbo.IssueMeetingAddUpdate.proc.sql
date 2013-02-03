/*
CREATE Proc [IssueMeetingAddUpdate]
	  ( @inIssueMeetingID int = NULL,
	    @inIssueID int,
        @inMeetingPurpose varchar(20),
        @inMeetingType varchar(20),
        @inMeetingDate date,
        @inMeetingTime time = null,
        @inAwardTime time = null,
        @inLastUpdateDate date = NULL,
        @inLastUpdateID varchar(20)  = 'Missing')
as

-------------------------------------------------------------------------------------------
    KRounds     New
-------------------------------------------------------------------------------------------

BEGIN
  	SET NOCOUNT ON;

    DECLARE @HoldReturn int = -9999,
            @ErrorMessage    VARCHAR(4000),
            --@ErrorNumber     INT,
            --@ErrorSeverity   INT,
            --@ErrorState      INT,
            @ErrorLine       VARCHAR(16),
            @ErrorProcedure  VARCHAR(200);

    BEGIN TRY

        --BEGIN TRANSACTION
        IF isnull(@inIssueMeetingID, 0 ) > 0
          BEGIN
            UPDATE IssueMeetings
              SET
         	    IssueID = @inIssueID,
                MeetingPurpose = @inMeetingPurpose,
                MeetingType    = @inMeetingType,
                MeetingDate    = @inMeetingDate,
                MeetingTime    = @inMeetingTime,
                AwardTime      = @inAwardTime,
                LastUpdateDate = GETDATE(),
                LastUpdateID   = @inLastUpdateID

              WHERE IssueMeetingID = @inIssueMeetingID;
            SET @HoldReturn = @inIssueMeetingID;
          END;

    IF @@ROWCOUNT < 1 or @inIssueMeetingID IS NULL
      BEGIN
        INSERT into IssueMeetings
           (IssueID,
            MeetingPurpose,
            MeetingType,
            MeetingDate,
            MeetingTime,
            AwardTime,
            LastUpdateDate,
            LastUpdateID)
        SELECT
            @inIssueID,
            @inMeetingPurpose,
            @inMeetingType,
            @inMeetingDate,
            @inMeetingTime,
            @inAwardTime,
            GETDATE(),
            @inLastUpdateID;

        SET @HoldReturn = @@IDENTITY;
      END;
      --COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH

        SELECT
            --@ErrorNumber = ERROR_NUMBER(),
            --@ErrorSeverity = ERROR_SEVERITY(),
            --@ErrorState = ERROR_STATE(),
            @ErrorLine = 'errr',--ERROR_LINE(),
            @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-'),
            @ErrorMessage = 'Error # ' + CONVERT(varchar,ERROR_NUMBER()) +' ' + ERROR_MESSAGE();


        --ROLLBACK TRANSACTION;
        --SET @HoldReturn = -1;

        EXEC @HoldReturn = AppErrorLogAdd
            'UserNameHere',
            'IssueMeetingAddUpdate',
            @ErrorMessage,
            '',
            @ErrorProcedure,
            @ErrorLine
    END CATCH

    RETURN @HoldReturn;

END
*/
