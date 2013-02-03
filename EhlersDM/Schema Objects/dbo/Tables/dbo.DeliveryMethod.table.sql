CREATE TABLE dbo.DeliveryMethod (
    DeliveryMethodID    INT             NOT NULL    IDENTITY
  , Value               VARCHAR (100)   NOT NULL
  , DisplaySequence     INT             NOT NULL    CONSTRAINT DF_DeliveryMethod_DisplaySequence DEFAULT 0
  , Active              BIT             NOT NULL    CONSTRAINT DF_DeliveryMethod_Active DEFAULT 1
  , Description         VARCHAR (200)   NULL
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_DeliveryMethod_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_DeliveryMethod_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , LegacyValue         VARCHAR (50)    NULL
  , CONSTRAINT PK_DeliveryMethod PRIMARY KEY CLUSTERED ( DeliveryMethodID ASC )
  , CONSTRAINT UX_DeliveryMethod_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
