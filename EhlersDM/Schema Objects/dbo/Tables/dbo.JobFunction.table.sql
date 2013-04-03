CREATE TABLE dbo.JobFunction (
    JobFunctionID   INT           NOT NULL  IDENTITY
  , Value           VARCHAR (100) NOT NULL
  , IsClient        BIT           NOT NULL  CONSTRAINT DF_JobFunction_IsClient  DEFAULT ((0))
  , IsFirm          BIT           NOT NULL  CONSTRAINT DF_JobFunction_IsFirm    DEFAULT ((0))
  , DisplaySequence INT           NOT NULL    CONSTRAINT DF_JobFunction_DisplaySequence DEFAULT ((0))
  , Active          BIT           NOT NULL    CONSTRAINT DF_JobFunction_Active DEFAULT ((1))
  , Description     VARCHAR (200) NULL
  , ModifiedDate    DATETIME      NOT NULL    CONSTRAINT DF_JobFunction_ModifiedDate DEFAULT (getdate())
  , ModifiedUser    VARCHAR (20)  NOT NULL    CONSTRAINT DF_JobFunction_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , LegacyValue     VARCHAR (50)  NULL
  , CONSTRAINT PK_JobFunction PRIMARY KEY CLUSTERED ( JobFunctionID ASC )
  , CONSTRAINT UX_JobFunction_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
