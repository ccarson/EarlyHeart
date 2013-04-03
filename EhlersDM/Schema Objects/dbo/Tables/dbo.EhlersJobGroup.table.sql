CREATE TABLE dbo.EhlersJobGroup (
    EhlersJobGroupID    INT             NOT NULL    IDENTITY
  , Value               VARCHAR (100)   NOT NULL
  , Active              BIT             NOT NULL    CONSTRAINT DF_EhlersJobGroup_Active DEFAULT ((1))
  , Description         VARCHAR (200)   NULL
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_EhlersJobGroup_ModifiedDate DEFAULT (getdate())
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_EhlersJobGroup_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , LegacyValue         VARCHAR (50)    NULL
  , CONSTRAINT PK_EhlersJobGroup PRIMARY KEY CLUSTERED ( EhlersJobGroupID ASC )
  , CONSTRAINT UX_EhlersJobGroup_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
