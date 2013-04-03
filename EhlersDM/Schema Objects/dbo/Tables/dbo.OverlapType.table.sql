CREATE TABLE dbo.OverlapType (
    OverlapTypeID   INT           NOT NULL  IDENTITY
  , Value           VARCHAR (100) NOT NULL
  , DisplaySequence INT           NOT NULL    CONSTRAINT DF_OverlapType_DisplaySequence DEFAULT ((0))
  , Active          BIT           NOT NULL    CONSTRAINT DF_OverlapType_Active DEFAULT ((1))
  , Description     VARCHAR (200) NULL
  , ModifiedDate    DATETIME      NOT NULL    CONSTRAINT DF_OverlapType_ModifiedDate DEFAULT (getdate())
  , ModifiedUser    VARCHAR (20)  NOT NULL    CONSTRAINT DF_OverlapType_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , LegacyValue     VARCHAR (50)  NULL
  , CONSTRAINT PK_OverlapType PRIMARY KEY CLUSTERED ( OverlapTypeID ASC )
  , CONSTRAINT UX_OverlapType_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
