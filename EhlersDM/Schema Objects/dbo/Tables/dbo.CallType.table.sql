CREATE TABLE dbo.CallType (
    CallTypeID      INT             NOT NULL    IDENTITY
  , Value           VARCHAR (100)   NOT NULL
  , DisplaySequence INT             NOT NULL    CONSTRAINT DF_CallType_DisplaySequence DEFAULT 0
  , Active          BIT             NOT NULL    CONSTRAINT DF_CallType_Active DEFAULT 1
  , Description     VARCHAR (200)   NULL
  , ModifiedDate    DATETIME        NOT NULL    CONSTRAINT DF_CallType_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser    VARCHAR (20)    NOT NULL    CONSTRAINT DF_CallType_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , LegacyValue     VARCHAR (50)    NULL
  , CONSTRAINT PK_CallType PRIMARY KEY CLUSTERED ( CallTypeID ASC )
  , CONSTRAINT UX_CallType_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
