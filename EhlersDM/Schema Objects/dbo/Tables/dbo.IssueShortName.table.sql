CREATE TABLE dbo.IssueShortName (
    IssueShortNameID INT           NOT NULL IDENTITY
  , Value            VARCHAR (100) NOT NULL
  , DisplaySequence  INT           NOT NULL    CONSTRAINT DF_IssueShortName_DisplaySequence DEFAULT ((0))
  , Active           BIT           NOT NULL    CONSTRAINT DF_IssueShortName_Active DEFAULT ((1))
  , Description      VARCHAR (200) NULL
  , ModifiedDate     DATETIME      NOT NULL    CONSTRAINT DF_IssueShortName_ModifiedDate DEFAULT (getdate())
  , ModifiedUser     VARCHAR (20)  NOT NULL    CONSTRAINT DF_IssueShortName_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , LegacyValue      VARCHAR (50)  NULL
  , CONSTRAINT PK_IssueShortName PRIMARY KEY CLUSTERED ( IssueShortNameID ASC )
  , CONSTRAINT UX_IssueShortName_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
