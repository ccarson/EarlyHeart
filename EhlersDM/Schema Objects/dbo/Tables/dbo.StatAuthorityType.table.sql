CREATE TABLE dbo.StatAuthorityType (
    StatAuthorityTypeID INT           NOT NULL  IDENTITY
  , Value               VARCHAR (100) NOT NULL
  , Description         VARCHAR (200) NULL
  , ModifiedDate        DATETIME      NOT NULL    CONSTRAINT DF_StatAuthorityType_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser        VARCHAR (20)  NOT NULL    CONSTRAINT DF_StatAuthorityType_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , LegacyValue         VARCHAR (50)  NULL
  , CONSTRAINT PK_StatAuthorityType PRIMARY KEY CLUSTERED ( StatAuthorityTypeID ASC )
  , CONSTRAINT UX_StatAuthorityType_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
