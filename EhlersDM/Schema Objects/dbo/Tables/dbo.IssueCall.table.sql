CREATE TABLE dbo.IssueCall (
    IssueCallID          INT             NOT NULL  IDENTITY
  , IssueID              INT             NOT NULL
  , CallTypeID           INT             NOT NULL
  , CallDate             DATE            NULL
  , CallPricePercent     DECIMAL (12, 8) NOT NULL
  , FirstCallableMatDate DATE            NULL
  , ModifiedDate         DATETIME        NOT NULL    CONSTRAINT DF_IssueCall_ModifiedDate DEFAULT (getdate())
  , ModifiedUser         VARCHAR (20)    NOT NULL    CONSTRAINT DF_IssueCall_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_IssueCall PRIMARY KEY CLUSTERED ( IssueCallID ASC )
  , CONSTRAINT FK_IssueCallDate_CallType
        FOREIGN KEY ( CallTypeID ) REFERENCES dbo.CallType ( CallTypeID )
  , CONSTRAINT FK_IssueCallDate_Issue
        FOREIGN KEY ( IssueID ) REFERENCES dbo.Issue ( IssueID )
) ;
GO

CREATE INDEX IX_IssueCall_IssueID ON dbo.IssueCall ( IssueID ASC ) ;
