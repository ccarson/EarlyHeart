CREATE TABLE dbo.IssueMeeting (
    IssueMeetingID     INT          NOT NULL  IDENTITY
  , IssueID            INT          NOT NULL
  , IssueJointClientID INT          NULL
  , MeetingPurposeID   INT          NOT NULL
  , MeetingTypeID      INT          NULL
  , MeetingDate        DATE         NULL
  , MeetingTime        TIME (7)     NULL
  , AwardTime          TIME (7)     NULL
  , ModifiedDate       DATETIME     NOT NULL    CONSTRAINT DF_IssueMeeting_ModifiedDate DEFAULT (getdate())
  , ModifiedUser       VARCHAR (20) NOT NULL    CONSTRAINT DF_IssueMeeting_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_IssueMeeting PRIMARY KEY CLUSTERED ( IssueMeetingID ASC )
  , CONSTRAINT FK_IssueMeeting_Issue
        FOREIGN KEY ( IssueID ) REFERENCES dbo.Issue ( IssueID )
  , CONSTRAINT FK_IssueMeeting_IssueJointClient
        FOREIGN KEY ( IssueJointClientID ) REFERENCES dbo.IssueJointClient ( IssueJointClientID )
  , CONSTRAINT FK_IssueMeeting_MeetingPurpose
        FOREIGN KEY ( MeetingPurposeID ) REFERENCES dbo.MeetingPurpose ( MeetingPurposeID )
  , CONSTRAINT FK_IssueMeeting_MeetingType
        FOREIGN KEY ( MeetingTypeID ) REFERENCES dbo.MeetingType ( MeetingTypeID )
) ;
GO

CREATE INDEX IX_IssueMeeting_IssueID ON dbo.IssueMeeting ( IssueID ASC ) ;
