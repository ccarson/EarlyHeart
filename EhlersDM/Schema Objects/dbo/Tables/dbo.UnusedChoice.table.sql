CREATE TABLE dbo.UnusedChoice (
    UnusedChoiceID  INT           NOT NULL  IDENTITY
  , Value           VARCHAR (100) NOT NULL
  , DisplaySequence INT           NOT NULL    CONSTRAINT DF_UnusedChoice_DisplaySequence DEFAULT 0
  , Active          BIT           NOT NULL    CONSTRAINT DF_UnusedChoice_Active DEFAULT 1
  , Description     VARCHAR (200) NULL
  , ModifiedDate    DATETIME      NOT NULL    CONSTRAINT DF_UnusedChoice_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser    VARCHAR (20)  NOT NULL    CONSTRAINT DF_UnusedChoice_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , LegacyValue     VARCHAR (50)  NULL
  , CONSTRAINT PK_UnusedChoice PRIMARY KEY CLUSTERED ( UnusedChoiceID ASC )
  , CONSTRAINT UX_UnusedChoice_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
