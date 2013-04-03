CREATE TABLE dbo.BondFormType (
    BondFormTypeID  INT             NOT NULL    IDENTITY
  , Value           VARCHAR (100)   NOT NULL
  , DisplaySequence INT             NOT NULL    CONSTRAINT DF_BondFormType_DisplaySequence DEFAULT ((0))
  , Active          BIT             NOT NULL    CONSTRAINT DF_BondFormType_Active DEFAULT ((1))
  , Description     VARCHAR (200)   NULL
  , ModifiedDate    DATETIME        NOT NULL    CONSTRAINT DF_BondFormType_ModifiedDate DEFAULT (getdate())
  , ModifiedUser    VARCHAR (20)    NOT NULL    CONSTRAINT DF_BondFormType_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , LegacyValue     VARCHAR (50)    NULL
  , CONSTRAINT PK_BondFormType PRIMARY KEY CLUSTERED ( BondFormTypeID ASC )
  , CONSTRAINT UX_BondFormType_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
