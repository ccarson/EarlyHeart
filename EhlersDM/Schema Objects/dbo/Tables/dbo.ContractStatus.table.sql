CREATE TABLE dbo.ContractStatus (
    ContractStatusID    INT             NOT NULL    IDENTITY
  , Value               VARCHAR (100)   NOT NULL
  , DisplaySequence     INT             NOT NULL    CONSTRAINT DF_ContractStatus_DisplaySequence DEFAULT ((0))
  , Active              BIT             NOT NULL    CONSTRAINT DF_ContractStatus_Active DEFAULT ((1))
  , Description         VARCHAR (200)   NULL
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_ContractStatus_ModifiedDate DEFAULT (getdate())
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_ContractStatus_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , LegacyValue         VARCHAR (50)    NULL
  , CONSTRAINT PK_ContractStatus PRIMARY KEY CLUSTERED ( ContractStatusID ASC )
  , CONSTRAINT UX_ContractStatus_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
