CREATE TABLE dbo.IssueClientsContacts (
    IssueClientsContactsID  INT             NOT NULL    IDENTITY
  , IssueID                 INT             NOT NULL
  , ClientContactsID        INT             NOT NULL
  , ContactRole             VARCHAR (2)     NOT NULL    CONSTRAINT DF_IssueClientsContacts_ContactRole  DEFAULT ('')
  , Ordinal                 INT             NOT NULL    CONSTRAINT DF_IssueClientsContacts_Ordinal      DEFAULT 0
  , ModifiedDate            DATETIME        NOT NULL    CONSTRAINT DF_IssueClientsContacts_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser            VARCHAR (20)    NOT NULL    CONSTRAINT DF_IssueClientsContacts_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_IssueClientsContacts PRIMARY KEY CLUSTERED ( IssueClientsContactsID ASC )
  , CONSTRAINT FK_IssueClientsContacts_ClientContacts
        FOREIGN KEY ( ClientContactsID ) REFERENCES dbo.ClientContacts ( ClientContactsID )
  , CONSTRAINT FK_IssueClientsContacts_Issue
        FOREIGN KEY ( IssueID ) REFERENCES dbo.Issue ( IssueID )
) ;
GO

CREATE INDEX IX_IssueClientsContacts_IssueID ON dbo.IssueClientsContacts ( IssueID ASC ) ; 
