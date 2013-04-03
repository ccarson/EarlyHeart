CREATE TABLE dbo.ClientReportIssues (
    ClientReportIssuesID    INT             NOT NULL    IDENTITY
  , IssueID                 INT             NOT NULL
  , ClientReportID          INT             NOT NULL
  , ModifiedDate            DATETIME        NOT NULL    CONSTRAINT DF_ClientReportIssues_ModifiedDate DEFAULT (getdate())
  , ModifiedUser            VARCHAR (20)    NOT NULL    CONSTRAINT DF_ClientReportIssues_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_ClientReportIssues PRIMARY KEY CLUSTERED ( ClientReportIssuesID ASC )
  , CONSTRAINT UX_ClientReportIssues UNIQUE NONCLUSTERED ( ClientReportID ASC, IssueID ASC )
  , CONSTRAINT FK_ClientReportIssues_Client
        FOREIGN KEY ( IssueID ) REFERENCES dbo.Issue ( IssueID )
  , CONSTRAINT FK_ClientReportIssues_ClientReport
        FOREIGN KEY ( ClientReportID ) REFERENCES dbo.ClientReport ( ClientReportID )
) ;
GO

CREATE INDEX IX_ClientReportIssues_IssueID ON dbo.ClientReportIssues ( IssueID ASC ) ;
GO

CREATE INDEX IX_ClientReportIssues_ClientReportID ON dbo.ClientReportIssues ( ClientReportID ASC ) ;
