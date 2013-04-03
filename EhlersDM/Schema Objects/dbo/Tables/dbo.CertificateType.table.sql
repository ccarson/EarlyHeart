CREATE TABLE dbo.CertificateType (
    CertificateTypeID INT           NOT NULL    CONSTRAINT PK_CertificateType PRIMARY KEY CLUSTERED IDENTITY
  , Value             VARCHAR (100) NOT NULL
  , DisplaySequence   INT           NOT NULL    CONSTRAINT DF_CertificateType_DisplaySequence   DEFAULT ((0))
  , Active            BIT           NOT NULL    CONSTRAINT DF_CertificateType_Active            DEFAULT ((1))
  , Description       VARCHAR (200) NULL
  , ModifiedDate      DATETIME      NOT NULL    CONSTRAINT DF_CertificateType_ModifiedDate      DEFAULT (getdate())
  , ModifiedUser      VARCHAR (20)  NOT NULL    CONSTRAINT DF_CertificateType_ModifiedUser      DEFAULT ([dbo].[udf_GetSystemUser]())
  , LegacyValue       VARCHAR (50)  NULL

  , CONSTRAINT UX_CertificateType_Value UNIQUE NONCLUSTERED (Value ASC)
);
