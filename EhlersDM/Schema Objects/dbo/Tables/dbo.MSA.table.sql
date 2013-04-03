CREATE TABLE dbo.MSA (
    MSAID           INT           NOT NULL  IDENTITY
  , Value           VARCHAR (100) NOT NULL
  , DisplaySequence INT           NOT NULL    CONSTRAINT DF_MSA_DisplaySequence DEFAULT ((0))
  , Active          BIT           NOT NULL    CONSTRAINT DF_MSA_Active DEFAULT ((1))
  , Description     VARCHAR (200) NULL
  , ModifiedDate    DATETIME      NOT NULL    CONSTRAINT DF_MSA_ModifiedDate DEFAULT (getdate())
  , ModifiedUser    VARCHAR (20)  NOT NULL    CONSTRAINT DF_MSA_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , LegacyValue     VARCHAR (50)  NULL
  , CONSTRAINT PK_MSA PRIMARY KEY CLUSTERED ( MSAID ASC )
  , CONSTRAINT UX_MSA_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
