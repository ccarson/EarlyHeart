CREATE TABLE dbo.MailingType (
    MailingTypeID   INT           NOT NULL  IDENTITY
  , Value           VARCHAR (100) NOT NULL
  , DisplaySequence INT           NOT NULL    CONSTRAINT DF_MailingType_DisplaySequence DEFAULT 0
  , Active          BIT           NOT NULL    CONSTRAINT DF_MailingType_Active DEFAULT 1
  , Description     VARCHAR (200) NULL
  , IsClient        BIT           NOT NULL  CONSTRAINT DF_MailingType_IsClient  DEFAULT 0
  , IsFirm          BIT           NOT NULL  CONSTRAINT DF_MailingType_IsFirm    DEFAULT 0
  , ModifiedDate    DATETIME      NOT NULL    CONSTRAINT DF_MailingType_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser    VARCHAR (20)  NOT NULL    CONSTRAINT DF_MailingType_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , LegacyValue     VARCHAR (50)  NULL
  , CONSTRAINT PK_MailingType PRIMARY KEY CLUSTERED ( MailingTypeID ASC )
  , CONSTRAINT UX_MailingType_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
