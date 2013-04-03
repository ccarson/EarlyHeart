CREATE TABLE dbo.IssueElections (
    IssueElectionsID INT          NOT NULL  IDENTITY
  , IssueID          INT          NOT NULL
  , ElectionID       INT          NOT NULL
  , ModifiedDate     DATETIME     NOT NULL    CONSTRAINT DF_IssueElections_ModifiedDate DEFAULT (getdate())
  , ModifiedUser     VARCHAR (20) NOT NULL    CONSTRAINT DF_IssueElections_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_IssueElections PRIMARY KEY CLUSTERED ( IssueElectionsID ASC )
  , CONSTRAINT UX_IssueElections UNIQUE NONCLUSTERED ( ElectionID ASC, IssueID ASC )
  , CONSTRAINT FK_IssueElections_Election
        FOREIGN KEY ( ElectionID ) REFERENCES dbo.Election ( ElectionID )
  , CONSTRAINT FK_IssueElections_Issue
        FOREIGN KEY ( IssueID ) REFERENCES dbo.Issue ( IssueID )
) ;
GO

CREATE INDEX IX_IssueElections_IssueID ON dbo.IssueElections ( IssueID ASC ) ;
