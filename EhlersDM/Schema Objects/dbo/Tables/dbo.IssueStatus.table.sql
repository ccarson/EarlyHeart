CREATE TABLE dbo.IssueStatus (
    IssueStatusID       INT             NOT NULL    IDENTITY
  , Value               VARCHAR (100)   NOT NULL
  , DisplaySequence     INT             NOT NULL    CONSTRAINT DF_IssueStatus_DisplaySequence DEFAULT 0
  , Active              BIT             NOT NULL    CONSTRAINT DF_IssueStatus_Active DEFAULT 1
  , Description         VARCHAR (200)   NULL
  , BusinessRuleActive  BIT             NOT NULL    CONSTRAINT DF_IssueStatus_BusinessRuleActive DEFAULT 0
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_IssueStatus_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_IssueStatus_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , LegacyValue         VARCHAR (50)    NULL
  , CONSTRAINT PK_IssueStatus PRIMARY KEY CLUSTERED ( IssueStatusID ASC )
  , CONSTRAINT UX_IssueStatus_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
