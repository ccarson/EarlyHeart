CREATE TABLE dbo.ClientAuditCafrIssues (
    ClientAuditCafrIssuesID INT             NOT NULL    IDENTITY
  , ClientAuditCafrID       INT             NOT NULL
  , IssueID                 INT             NOT NULL
  , ModifiedDate            DATETIME        NOT NULL    CONSTRAINT DF_ClientAuditCafrIssues_ModifiedDate DEFAULT (getdate())
  , ModifiedUser            VARCHAR (20)    NOT NULL    CONSTRAINT DF_ClientAuditCafrIssues_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_ClientAuditCafrIssues PRIMARY KEY CLUSTERED ( ClientAuditCafrIssuesID ASC )
  , CONSTRAINT UX_ClientAuditCafrIssues UNIQUE NONCLUSTERED ( ClientAuditCafrID ASC, IssueID ASC )
  , CONSTRAINT FK_ClientAuditCafrIssues_ClientAuditCafr
        FOREIGN KEY ( ClientAuditCafrID ) REFERENCES dbo.ClientAuditCafr ( ClientAuditCafrID )
  , CONSTRAINT FK_ClientAuditCafrIssues_Issue
        FOREIGN KEY ( IssueID ) REFERENCES dbo.Issue ( IssueID )
) ;
GO

CREATE INDEX IX_ClientAuditCafrIssues_ClientAuditCafrID ON dbo.ClientAuditCafrIssues ( ClientAuditCafrID ASC ) ;
GO

CREATE INDEX IX_ClientAuditCafrIssues_IssueID ON dbo.ClientAuditCafrIssues ( IssueID ASC ) ;
