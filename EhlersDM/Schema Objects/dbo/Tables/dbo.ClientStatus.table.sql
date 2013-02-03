CREATE TABLE dbo.ClientStatus (
    ClientStatusID  INT             NOT NULL    IDENTITY
  , Value           VARCHAR (100)   NOT NULL
  , DisplaySequence INT             NOT NULL    CONSTRAINT DF_ClientStatus_DisplaySequence DEFAULT 0
  , Active          BIT             NOT NULL    CONSTRAINT DF_ClientStatus_Active DEFAULT 1
  , Description     VARCHAR (200)   NULL
  , ModifiedDate    DATETIME        NOT NULL    CONSTRAINT DF_ClientStatus_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser    VARCHAR (20)    NOT NULL    CONSTRAINT DF_ClientStatus_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , LegacyValue     VARCHAR (50)    NULL
  , CONSTRAINT PK_ClientStatus PRIMARY KEY CLUSTERED ( ClientStatusID ASC )
  , CONSTRAINT UX_ClientStatus_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
