CREATE TABLE dbo.FinanceType (
    FinanceTypeID   INT             NOT NULL    IDENTITY
  , Value           VARCHAR (100)   NOT NULL
  , DisplaySequence INT             NOT NULL    CONSTRAINT DF_FinanceType_DisplaySequence DEFAULT ((0))
  , Active          BIT             NOT NULL    CONSTRAINT DF_FinanceType_Active DEFAULT ((1))
  , Description     VARCHAR (200)   NULL
  , ModifiedDate    DATETIME        NOT NULL    CONSTRAINT DF_FinanceType_ModifiedDate DEFAULT (getdate())
  , ModifiedUser    VARCHAR (20)    NOT NULL    CONSTRAINT DF_FinanceType_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , LegacyValue     VARCHAR (50)    NULL
  , CONSTRAINT PK_FinanceType PRIMARY KEY CLUSTERED ( FinanceTypeID ASC )
  , CONSTRAINT UX_FinanceType_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
