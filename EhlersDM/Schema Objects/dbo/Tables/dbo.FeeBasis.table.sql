CREATE TABLE dbo.FeeBasis (
    FeeBasisID      INT             NOT NULL    IDENTITY
  , Value           VARCHAR (100)   NOT NULL
  , DisplaySequence INT             NOT NULL    CONSTRAINT DF_FeeBasis_DisplaySequence DEFAULT 0
  , Active          BIT             NOT NULL    CONSTRAINT DF_FeeBasis_Active DEFAULT 1
  , Description     VARCHAR (200)   NULL
  , ModifiedDate    DATETIME        NOT NULL    CONSTRAINT DF_FeeBasis_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser    VARCHAR (20)    NOT NULL    CONSTRAINT DF_FeeBasis_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , LegacyValue     VARCHAR (50)    NULL
  , CONSTRAINT PK_FeeBasis PRIMARY KEY CLUSTERED ( FeeBasisID ASC )
  , CONSTRAINT UX_FeeBasis_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
