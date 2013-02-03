CREATE TABLE dbo.IssueFeeEhlers (
    IssueFeeEhlersID INT             NOT NULL   IDENTITY
  , IssueID          INT             NOT NULL
  , FeeTypeID        INT             NOT NULL
  , Fee              DECIMAL (15, 2) NOT NULL   CONSTRAINT DF_IssueFeeEhlers_Fee    DEFAULT 0
  , Note             VARCHAR (200)   NOT NULL   CONSTRAINT DF_IssueFeeEhlers_Note   DEFAULT ('')
  , ModifiedDate     DATETIME        NOT NULL    CONSTRAINT DF_IssueFeeEhlers_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser     VARCHAR (20)    NOT NULL    CONSTRAINT DF_IssueFeeEhlers_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_IssueFeeEhlers PRIMARY KEY CLUSTERED ( IssueFeeEhlersID )
  , CONSTRAINT FK_IssueFeeEhlers_FeeType
        FOREIGN KEY ( FeeTypeID ) REFERENCES dbo.FeeType ( FeeTypeID )
  , CONSTRAINT FK_IssueFeeEhlers_Issue
        FOREIGN KEY ( IssueID ) REFERENCES dbo.Issue ( IssueID )
) ;
GO

CREATE INDEX IX_IssueFeeEhlers_IssueID ON dbo.IssueFeeEhlers ( IssueID ASC ) ;
