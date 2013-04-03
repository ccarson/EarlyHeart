CREATE TABLE dbo.FormOfGovernment (
    FormOfGovernmentID INT           NOT NULL   IDENTITY
  , Value              VARCHAR (100) NOT NULL
  , DisplaySequence    INT           NOT NULL    CONSTRAINT DF_FormOfGovernment_DisplaySequence DEFAULT ((0))
  , Active             BIT           NOT NULL    CONSTRAINT DF_FormOfGovernment_Active DEFAULT ((1))
  , Description        VARCHAR (200) NULL
  , ModifiedDate       DATETIME      NOT NULL    CONSTRAINT DF_FormOfGovernment_ModifiedDate DEFAULT (getdate())
  , ModifiedUser       VARCHAR (20)  NOT NULL    CONSTRAINT DF_FormOfGovernment_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , LegacyValue        VARCHAR (50)  NULL
  , CONSTRAINT PK_FormOfGovernment PRIMARY KEY CLUSTERED ( FormOfGovernmentID ASC )
  , CONSTRAINT UX_FormOfGovernment_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
