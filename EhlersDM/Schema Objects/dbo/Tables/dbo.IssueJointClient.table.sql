CREATE TABLE dbo.IssueJointClient (
    IssueJointClientID INT          NOT NULL    IDENTITY
  , IssueID            INT          NOT NULL
  , ClientID           INT          NOT NULL
  , Ordinal            INT          NOT NULL    CONSTRAINT DF_IssueJointClient_Ordinal DEFAULT ((0))
  , ModifiedDate       DATETIME     NOT NULL    CONSTRAINT DF_IssueJointClient_ModifiedDate DEFAULT (getdate())
  , ModifiedUser       VARCHAR (20) NOT NULL    CONSTRAINT DF_IssueJointClient_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_IssueJointClient PRIMARY KEY CLUSTERED ( IssueJointClientID ASC )
  , CONSTRAINT UX_IssueJointClient UNIQUE NONCLUSTERED ( ClientID ASC, IssueID ASC, Ordinal ASC )
  , CONSTRAINT FK_IssueJointClient_Client
        FOREIGN KEY ( ClientID ) REFERENCES dbo.Client ( ClientID )
  , CONSTRAINT FK_IssueJointClient_Issue
        FOREIGN KEY ( IssueID ) REFERENCES dbo.Issue ( IssueID )
) ;
GO

CREATE INDEX IX_IssueJointClient_ClientID ON dbo.IssueJointClient ( ClientID ASC ) ;
GO

CREATE INDEX IX_IssueJointClient_IssueID ON dbo.IssueJointClient ( IssueID ASC ) ;
