CREATE TABLE dbo.AuditorFeeType (
    AuditorFeeTypeID    INT             NOT NULL    IDENTITY
  , Value               VARCHAR (100)   NOT NULL
  , DisplaySequence     INT             NOT NULL    CONSTRAINT DF_AuditorFeeType_DisplaySequence DEFAULT 0
  , Active              BIT             NOT NULL    CONSTRAINT DF_AuditorFeeType_Active DEFAULT 1
  , Description         VARCHAR (200)   NULL
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_AuditorFeeType_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_AuditorFeeType_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , LegacyValue         VARCHAR (50)    NULL
  , CONSTRAINT PK_AuditorFeeType PRIMARY KEY CLUSTERED ( AuditorFeeTypeID ASC )
  , CONSTRAINT UX_AuditorFeeType_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
