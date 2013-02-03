CREATE TABLE dbo.JurisdictionType (
    JurisdictionTypeID  INT           NOT NULL  IDENTITY
  , Value               VARCHAR (100) NOT NULL
  , DisplaySequence     INT           NOT NULL    CONSTRAINT DF_JurisdictionType_DisplaySequence DEFAULT 0
  , Active              BIT           NOT NULL    CONSTRAINT DF_JurisdictionType_Active DEFAULT 1
  , Description         VARCHAR (200) NULL
  , ModifiedDate        DATETIME      NOT NULL    CONSTRAINT DF_JurisdictionType_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser        VARCHAR (20)  NOT NULL    CONSTRAINT DF_JurisdictionType_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , DefaultOSValue      VARCHAR (50)  NOT NULL  CONSTRAINT DF_JurisdictionType_DefaultOSValue   DEFAULT ('')
  , LegacyValue         VARCHAR (50)  NULL
  , CONSTRAINT PK_JurisdictionType PRIMARY KEY CLUSTERED ( JurisdictionTypeID ASC )
  , CONSTRAINT UX_JurisdictionType_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
