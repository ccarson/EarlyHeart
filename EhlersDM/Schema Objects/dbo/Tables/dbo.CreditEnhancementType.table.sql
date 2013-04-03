CREATE TABLE dbo.CreditEnhancementType (
    CreditEnhancementTypeID INT             NOT NULL    IDENTITY
  , Value                   VARCHAR (100)   NOT NULL
  , DisplaySequence         INT             NOT NULL    CONSTRAINT DF_CreditEnhancementType_DisplaySequence DEFAULT ((0))
  , Active                  BIT             NOT NULL    CONSTRAINT DF_CreditEnhancementType_Active DEFAULT ((1))
  , Description             VARCHAR (200)   NULL
  , ModifiedDate            DATETIME        NOT NULL    CONSTRAINT DF_CreditEnhancementType_ModifiedDate DEFAULT (getdate())
  , ModifiedUser            VARCHAR (20)    NOT NULL    CONSTRAINT DF_CreditEnhancementType_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , LegacyValue             VARCHAR (50)    NULL
  , CONSTRAINT PK_CreditEnhancementType PRIMARY KEY CLUSTERED ( CreditEnhancementTypeID ASC )
  , CONSTRAINT UX_CreditEnhancementType_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
