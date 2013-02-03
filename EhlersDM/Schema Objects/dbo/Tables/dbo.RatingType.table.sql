CREATE TABLE dbo.RatingType (
    RatingTypeID    INT           NOT NULL  IDENTITY
  , Value           VARCHAR (100) NOT NULL
  , DisplaySequence INT           NOT NULL    CONSTRAINT DF_RatingType_DisplaySequence DEFAULT 0
  , Active          BIT           NOT NULL    CONSTRAINT DF_RatingType_Active DEFAULT 1
  , Description     VARCHAR (200) NULL
  , ModifiedDate    DATETIME      NOT NULL    CONSTRAINT DF_RatingType_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser    VARCHAR (20)  NOT NULL    CONSTRAINT DF_RatingType_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , LegacyValue     VARCHAR (50)  NULL
  , CONSTRAINT PK_RatingType PRIMARY KEY CLUSTERED ( RatingTypeID ASC )
  , CONSTRAINT UX_RatingType_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
