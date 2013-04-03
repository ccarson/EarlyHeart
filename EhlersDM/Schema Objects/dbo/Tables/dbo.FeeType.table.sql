CREATE TABLE dbo.FeeType (
    FeeTypeID       INT           NOT NULL  CONSTRAINT PK_FeeType                   PRIMARY KEY CLUSTERED     IDENTITY 
  , Value           VARCHAR (100) NOT NULL  CONSTRAINT UX_FeeType_Value             UNIQUE NONCLUSTERED
  , DisplaySequence INT           NOT NULL  CONSTRAINT DF_FeeType_DisplaySequence   DEFAULT ((0))
  , Active          BIT           NOT NULL  CONSTRAINT DF_FeeType_Active            DEFAULT ((1))
  , Description     VARCHAR (200) NULL
  , IsEhlersFee     BIT           NOT NULL  CONSTRAINT DF_FeeType_IsEhlersFee       DEFAULT ((0)) 
  , IsContactFee    BIT           NOT NULL  CONSTRAINT DF_FeeType_IsFirmContactFee  DEFAULT ((0)) 
  , IsCOIFee        BIT           NOT NULL  CONSTRAINT DF_FeeType_IsCOIFee          DEFAULT ((0))
  , ModifiedDate    DATETIME      NOT NULL  CONSTRAINT DF_FeeType_ModifiedDate      DEFAULT (getdate())
  , ModifiedUser    VARCHAR (20)  NOT NULL  CONSTRAINT DF_FeeType_ModifiedUser      DEFAULT ([dbo].[udf_GetSystemUser]())
  , LegacyValue     VARCHAR (50)  NULL
);


