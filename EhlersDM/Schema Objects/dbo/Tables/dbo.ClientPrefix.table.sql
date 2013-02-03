CREATE TABLE dbo.ClientPrefix (
    ClientPrefixID  INT             NOT NULL    IDENTITY
  , Value           VARCHAR (100)   NOT NULL
  , DisplaySequence INT             NOT NULL    CONSTRAINT DF_ClientPrefix_DisplaySequence DEFAULT 0
  , Active          BIT             NOT NULL    CONSTRAINT DF_ClientPrefix_Active DEFAULT 1
  , Description     VARCHAR (200)   NULL
  , IsAll           BIT             NOT NULL    CONSTRAINT DF_ClientPrefix_IsAll            DEFAULT 0
  , IsMN            BIT             NOT NULL    CONSTRAINT DF_ClientPrefix_IsMN             DEFAULT 0
  , IsWI            BIT             NOT NULL    CONSTRAINT DF_ClientPrefix_IsWI             DEFAULT 0
  , IsIL            BIT             NOT NULL    CONSTRAINT DF_ClientPrefix_IsIL             DEFAULT 0
  , ModifiedDate    DATETIME        NOT NULL    CONSTRAINT DF_ClientPrefix_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser    VARCHAR (20)    NOT NULL    CONSTRAINT DF_ClientPrefix_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , LegacyValue     VARCHAR (100)   NULL
  , CONSTRAINT PK_ClientPrefix PRIMARY KEY CLUSTERED ( ClientPrefixID ASC )
  , CONSTRAINT UX_ClientPrefix_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
