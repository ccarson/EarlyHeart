CREATE TABLE dbo.ArbitrageComputationType (
    ArbitrageComputationTypeID  INT             NOT NULL    IDENTITY
  , Value                       VARCHAR (100)   NOT NULL
  , DisplaySequence             INT             NOT NULL    CONSTRAINT DF_ArbitrageComputationType_DisplaySequence DEFAULT ((0))
  , Active                      BIT             NOT NULL    CONSTRAINT DF_ArbitrageComputationType_Active DEFAULT ((1))
  , Description                 VARCHAR (200)   NULL
  , ModifiedDate                DATETIME        NOT NULL    CONSTRAINT DF_ArbitrageComputationType_ModifiedDate DEFAULT (getdate())
  , ModifiedUser                VARCHAR (20)    NOT NULL    CONSTRAINT DF_ArbitrageComputationType_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , LegacyValue                 VARCHAR (50)    NULL
  , CONSTRAINT PK_ArbitrageComputationType PRIMARY KEY CLUSTERED ( ArbitrageComputationTypeID ASC )
  , CONSTRAINT UX_ArbitrageComputationType_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
