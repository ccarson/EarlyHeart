CREATE TABLE dbo.FirmCategory (
    FirmCategoryID  INT             NOT NULL    IDENTITY
  , Value           VARCHAR (100)   NOT NULL
  , DisplaySequence INT             NOT NULL    CONSTRAINT DF_FirmCategory_DisplaySequence DEFAULT ((0))
  , Active          BIT             NOT NULL    CONSTRAINT DF_FirmCategory_Active DEFAULT ((1))
  , Description     VARCHAR (200)   NULL
  , ModifiedDate    DATETIME        NOT NULL    CONSTRAINT DF_FirmCategory_ModifiedDate DEFAULT (getdate())
  , ModifiedUser    VARCHAR (20)    NOT NULL    CONSTRAINT DF_FirmCategory_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , LegacyValue     VARCHAR (50)    NULL
  , CONSTRAINT PK_FirmCategory PRIMARY KEY CLUSTERED ( FirmCategoryID ASC )
  , CONSTRAINT UX_FirmCategory_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
