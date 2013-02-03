CREATE TABLE dbo.ElectionType (
    ElectionTypeID  INT             NOT NULL    IDENTITY
  , Value           VARCHAR (100)   NOT NULL
  , DisplaySequence INT             NOT NULL    CONSTRAINT DF_ElectionType_DisplaySequence DEFAULT 0
  , Active          BIT             NOT NULL    CONSTRAINT DF_ElectionType_Active DEFAULT 1
  , Description     VARCHAR (200)   NULL
  , ModifiedDate    DATETIME        NOT NULL    CONSTRAINT DF_ElectionType_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser    VARCHAR (20)    NOT NULL    CONSTRAINT DF_ElectionType_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , LegacyValue     VARCHAR (50)    NULL
  , CONSTRAINT PK_ElectionType PRIMARY KEY CLUSTERED ( ElectionTypeID ASC )
  , CONSTRAINT UX_ElectionType_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
