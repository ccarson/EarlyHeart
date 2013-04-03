CREATE TABLE dbo.ArbitrageStatus (
    ArbitrageStatusID   INT             NOT NULL    IDENTITY
  , Value               VARCHAR (100)   NOT NULL
  , DisplaySequence     INT             NOT NULL    CONSTRAINT DF_ArbitrageStatus_DisplaySequence DEFAULT ((0))
  , Active              BIT             NOT NULL    CONSTRAINT DF_ArbitrageStatus_Active DEFAULT ((1))
  , Description         VARCHAR (200)   NULL
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_ArbitrageStatus_ModifiedDate DEFAULT (getdate())
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_ArbitrageStatus_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , LegacyValue         VARCHAR (50)    NULL
  , CONSTRAINT PK_ArbitrageStatus PRIMARY KEY CLUSTERED ( ArbitrageStatusID ASC )
  , CONSTRAINT UX_ArbitrageStatus_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
