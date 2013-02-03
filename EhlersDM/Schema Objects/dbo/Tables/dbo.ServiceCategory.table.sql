CREATE TABLE dbo.ServiceCategory (
    ServiceCategoryID INT           NOT NULL    IDENTITY
  , Value             VARCHAR (100) NOT NULL
  , DisplaySequence   INT           NOT NULL    CONSTRAINT DF_ServiceCategory_DisplaySequence DEFAULT 0
  , Active            BIT           NOT NULL    CONSTRAINT DF_ServiceCategory_Active DEFAULT 1
  , Description       VARCHAR (200) NULL
  , ModifiedDate      DATETIME      NOT NULL    CONSTRAINT DF_ServiceCategory_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser      VARCHAR (20)  NOT NULL    CONSTRAINT DF_ServiceCategory_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , LegacyValue       VARCHAR (50)  NULL
  , CONSTRAINT PK_ServiceCategory PRIMARY KEY CLUSTERED ( ServiceCategoryID ASC )
  , CONSTRAINT UX_ServiceCategory_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
