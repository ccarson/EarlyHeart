CREATE TABLE dbo.InterestType (
    InterestTypeID  INT           NOT NULL  IDENTITY
  , Value           VARCHAR (100) NOT NULL
  , DisplaySequence INT           NOT NULL    CONSTRAINT DF_InterestType_DisplaySequence DEFAULT 0
  , Active          BIT           NOT NULL    CONSTRAINT DF_InterestType_Active DEFAULT 1
  , Description     VARCHAR (200) NULL
  , ModifiedDate    DATETIME      NOT NULL    CONSTRAINT DF_InterestType_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser    VARCHAR (20)  NOT NULL    CONSTRAINT DF_InterestType_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , LegacyValue     VARCHAR (50)  NULL
  , CONSTRAINT PK_InterestType PRIMARY KEY CLUSTERED ( InterestTypeID ASC )
  , CONSTRAINT UX_InterestType_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
