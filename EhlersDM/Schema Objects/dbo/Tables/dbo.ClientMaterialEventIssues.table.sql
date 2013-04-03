CREATE TABLE dbo.ClientMaterialEventIssues (
    ClientMaterialEventIssuesID INT             NOT NULL    IDENTITY
  , ClientMaterialEventID       INT             NOT NULL
  , IssueID                     INT             NOT NULL
  , ModifiedDate                DATETIME        NOT NULL    CONSTRAINT DF_ClientMaterialEventIssues_ModifiedDate DEFAULT (getdate())
  , ModifiedUser                VARCHAR (20)    NOT NULL    CONSTRAINT DF_ClientMaterialEventIssues_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_ClientMaterialEventIssues PRIMARY KEY CLUSTERED ( ClientMaterialEventIssuesID ASC )
  , CONSTRAINT UX_ClientMaterialEventIssues UNIQUE NONCLUSTERED ( ClientMaterialEventID ASC, IssueID ASC )
  , CONSTRAINT FK_ClientMaterialEventIssues_ClientMaterialEvent
        FOREIGN KEY ( ClientMaterialEventID ) REFERENCES dbo.ClientMaterialEvent ( ClientMaterialEventID )
  , CONSTRAINT FK_ClientMaterialEventIssues_Issue
        FOREIGN KEY ( IssueID ) REFERENCES dbo.Issue ( IssueID )
) ;
GO

CREATE INDEX IX_ClientMaterialEventIssues_ClientMaterialEventID ON dbo.ClientMaterialEventIssues ( ClientMaterialEventID ASC ) ;
GO

CREATE INDEX IX_ClientMaterialEventIssues_IssueID ON dbo.ClientMaterialEventIssues ( IssueID ASC ) ;
