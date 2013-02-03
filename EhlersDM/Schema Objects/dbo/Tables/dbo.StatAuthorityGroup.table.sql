CREATE TABLE dbo.StatAuthorityGroup (
    StatAuthorityGroupID INT           NOT NULL  IDENTITY
  , Value                VARCHAR (100) NOT NULL
  , Description          VARCHAR (200) NULL
  , ModifiedDate         DATETIME      NOT NULL    CONSTRAINT DF_StatAuthorityGroup_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser         VARCHAR (20)  NOT NULL    CONSTRAINT DF_StatAuthorityGroup_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , LegacyValue          VARCHAR (50)  NULL
  , CONSTRAINT PK_StatAuthorityGroup PRIMARY KEY CLUSTERED ( StatAuthorityGroupID ASC )
  , CONSTRAINT UX_StatAuthorityGroup_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
