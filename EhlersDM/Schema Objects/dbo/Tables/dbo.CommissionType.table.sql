CREATE TABLE dbo.CommissionType (
    CommissionTypeID    INT             NOT NULL    IDENTITY
  , Value               VARCHAR (100)   NOT NULL
  , DisplaySequence     INT             NOT NULL    CONSTRAINT DF_CommissionType_DisplaySequence DEFAULT ((0))
  , Active              BIT             NOT NULL    CONSTRAINT DF_CommissionType_Active DEFAULT ((1))
  , Description         VARCHAR (200)   NULL
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_CommissionType_ModifiedDate DEFAULT (getdate())
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_CommissionType_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , LegacyValue         VARCHAR (50)    NULL
  , CONSTRAINT PK_CommissionType PRIMARY KEY CLUSTERED ( CommissionTypeID ASC )
  , CONSTRAINT UX_CommissionType_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
