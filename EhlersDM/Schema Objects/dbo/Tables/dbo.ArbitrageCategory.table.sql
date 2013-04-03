CREATE TABLE dbo.ArbitrageCategory (
    ArbitrageCategoryID INT             NOT NULL  IDENTITY
  , Value               VARCHAR (100)   NOT NULL
  , DisplaySequence     INT             NOT NULL    CONSTRAINT DF_ArbitrageCategory_DisplaySequence DEFAULT ((0))
  , Active              BIT             NOT NULL    CONSTRAINT DF_ArbitrageCategory_Active DEFAULT ((1))
  , Description         VARCHAR (200)   NULL
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_ArbitrageCategory_ModifiedDate DEFAULT (getdate())
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_ArbitrageCategory_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , LegacyValue         VARCHAR (50)    NULL
  , CONSTRAINT PK_ArbitrageCategory PRIMARY KEY CLUSTERED ( ArbitrageCategoryID ASC )
  , CONSTRAINT UX_ArbitrageCategory_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
