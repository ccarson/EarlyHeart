CREATE TABLE dbo.Project (
    ProjectID           INT             NOT NULL    IDENTITY
  , ClientID            INT             NOT NULL
  , IssueID             INT             NULL
  , ProjectServiceID    INT             NOT NULL
  , Name                VARCHAR (150)   NOT NULL
  , InterTeam           BIT             NOT NULL    CONSTRAINT DF_Project_InterTeam         DEFAULT 0
  , InvestProceeds      BIT             NOT NULL    CONSTRAINT DF_Project_InvestProceeds    DEFAULT 0
  , Notes               VARCHAR (MAX)   NOT NULL    CONSTRAINT DF_Project_Notes             DEFAULT ('')
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_Project_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_Project_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_Project PRIMARY KEY CLUSTERED ( ProjectID ASC )
  , CONSTRAINT FK_Project_Client
        FOREIGN KEY ( ClientID ) REFERENCES dbo.Client ( ClientID )
  , CONSTRAINT FK_Project_Issue
        FOREIGN KEY ( IssueID ) REFERENCES dbo.Issue ( IssueID )
  , CONSTRAINT FK_Project_ProjectService
        FOREIGN KEY ( ProjectServiceID ) REFERENCES dbo.ProjectService ( ProjectServiceID )
) ;
GO

CREATE INDEX IX_Project_ClientID ON dbo.Project ( ClientID ASC )
