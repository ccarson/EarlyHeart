CREATE TABLE dbo.CallFrequency (
    CallFrequencyID INT             NOT NULL    IDENTITY
  , Value           VARCHAR (100)   NOT NULL
  , DisplaySequence INT             NOT NULL    CONSTRAINT DF_CallFrequency_DisplaySequence DEFAULT 0
  , Active          BIT             NOT NULL    CONSTRAINT DF_CallFrequency_Active DEFAULT 1
  , Description     VARCHAR (200)   NULL
  , ModifiedDate    DATETIME        NOT NULL    CONSTRAINT DF_CallFrequency_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser    VARCHAR (20)    NOT NULL    CONSTRAINT DF_CallFrequency_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , LegacyValue     VARCHAR (50)    NULL
  , CONSTRAINT PK_CallFrequency PRIMARY KEY CLUSTERED ( CallFrequencyID ASC )
  , CONSTRAINT UX_CallFrequency_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;