CREATE TABLE dbo.FeeType (
    FeeTypeID       INT             NOT NULL    IDENTITY
  , Value           VARCHAR (100)   NOT NULL
  , DisplaySequence INT             NOT NULL    CONSTRAINT DF_FeeType_DisplaySequence DEFAULT 0
  , Active          BIT             NOT NULL    CONSTRAINT DF_FeeType_Active DEFAULT 1
  , Description     VARCHAR (200)   NULL
  , ModifiedDate    DATETIME        NOT NULL    CONSTRAINT DF_FeeType_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser    VARCHAR (20)    NOT NULL    CONSTRAINT DF_FeeType_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , LegacyValue     VARCHAR (50)    NULL
  , CONSTRAINT PK_FeeType PRIMARY KEY CLUSTERED ( FeeTypeID ASC )
  , CONSTRAINT UX_FeeType_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
