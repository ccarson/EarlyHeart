CREATE TABLE dbo.Project (
    ProjectID        INT            NOT NULL    CONSTRAINT PK_Project PRIMARY KEY CLUSTERED IDENTITY
  , ClientID         INT            NOT NULL
  , IssueID          INT            NULL
  , ProjectServiceID INT            NOT NULL
  , CommissionTypeID INT            NULL
  , Name             VARCHAR (150)  NOT NULL
  , InterTeam        BIT            NOT NULL    CONSTRAINT DF_Project_InterTeam         DEFAULT ((0))
  , InvestProceeds   BIT            NOT NULL    CONSTRAINT DF_Project_InvestProceeds    DEFAULT ((0))
  , Notes            VARCHAR (MAX)  NOT NULL    CONSTRAINT DF_Project_Notes             DEFAULT ('')
  , ModifiedDate     DATETIME       NOT NULL    CONSTRAINT DF_Project_ModifiedDate      DEFAULT (getdate())
  , ModifiedUser     VARCHAR (20)   NOT NULL    CONSTRAINT DF_Project_ModifiedUser      DEFAULT ([dbo].[udf_GetSystemUser]())

  , CONSTRAINT FK_Project_Client
        FOREIGN KEY ( ClientID ) REFERENCES dbo.Client ( ClientID )
  , CONSTRAINT FK_Project_CommissionType
        FOREIGN KEY ( CommissionTypeID ) REFERENCES dbo.CommissionType ( CommissionTypeID )
  , CONSTRAINT FK_Project_Issue
        FOREIGN KEY ( IssueID ) REFERENCES dbo.Issue ( IssueID )
  , CONSTRAINT FK_Project_ProjectService
        FOREIGN KEY ( ProjectServiceID ) REFERENCES dbo.ProjectService ( ProjectServiceID ) ) ;
GO

CREATE INDEX IX_Project_ClientID ON dbo.Project ( ClientID ASC ) ;
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description'
                             , @value = N'Field to be used when project service is Debt Issuance, then we ignore the commission type on the Project Service table'
                             , @level0type = N'SCHEMA'
                             , @level0name = N'dbo'
                             , @level1type = N'TABLE'
                             , @level1name = N'Project'
                             , @level2type = N'COLUMN'
                             , @level2name = N'CommissionTypeID' ;
