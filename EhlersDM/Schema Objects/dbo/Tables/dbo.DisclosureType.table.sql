CREATE TABLE dbo.DisclosureType (
    DisclosureTypeID    INT             NOT NULL    IDENTITY
  , Value               VARCHAR (100)   NOT NULL
  , DisplaySequence     INT             NOT NULL    CONSTRAINT DF_DisclosureType_DisplaySequence DEFAULT ((0))
  , Active              BIT             NOT NULL    CONSTRAINT DF_DisclosureType_Active DEFAULT ((1))
  , Description         VARCHAR (200)   NULL
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_DisclosureType_ModifiedDate DEFAULT (getdate())
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_DisclosureType_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , LegacyValue         VARCHAR (50)    NULL
  , CONSTRAINT PK_DisclosureType PRIMARY KEY CLUSTERED ( DisclosureTypeID ASC )
  , CONSTRAINT UX_DisclosureType_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
