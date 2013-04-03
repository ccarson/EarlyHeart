CREATE TABLE dbo.IssueType (
    IssueTypeID     INT           NOT NULL  IDENTITY
  , Value           VARCHAR (100) NOT NULL
  , DisplaySequence INT           NOT NULL    CONSTRAINT DF_IssueType_DisplaySequence DEFAULT ((0))
  , Active          BIT           NOT NULL    CONSTRAINT DF_IssueType_Active DEFAULT ((1))
  , Description     VARCHAR (200) NULL
  , ModifiedDate    DATETIME      NOT NULL    CONSTRAINT DF_IssueType_ModifiedDate DEFAULT (getdate())
  , ModifiedUser    VARCHAR (20)  NOT NULL    CONSTRAINT DF_IssueType_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , LegacyValue     VARCHAR (50)  NULL
  , CONSTRAINT PK_IssueType PRIMARY KEY CLUSTERED ( IssueTypeID ASC )
  , CONSTRAINT UX_IssueType_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
