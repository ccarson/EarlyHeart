CREATE TABLE dbo.PaymentType (
    PaymentTypeID   INT           NOT NULL  IDENTITY
  , Value           VARCHAR (100) NOT NULL
  , DisplaySequence INT           NOT NULL    CONSTRAINT DF_PaymentType_DisplaySequence DEFAULT ((0))
  , Active          BIT           NOT NULL    CONSTRAINT DF_PaymentType_Active DEFAULT ((1))
  , Description     VARCHAR (200) NULL
  , ModifiedDate    DATETIME      NOT NULL    CONSTRAINT DF_PaymentType_ModifiedDate DEFAULT (getdate())
  , ModifiedUser    VARCHAR (20)  NOT NULL    CONSTRAINT DF_PaymentType_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , LegacyValue     VARCHAR (50)  NULL
  , CONSTRAINT PK_PaymentType PRIMARY KEY CLUSTERED ( PaymentTypeID ASC )
  , CONSTRAINT UX_PaymentType_Value UNIQUE NONCLUSTERED ( Value )
) ;
