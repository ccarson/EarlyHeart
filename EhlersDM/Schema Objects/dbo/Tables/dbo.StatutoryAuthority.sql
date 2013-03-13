CREATE TABLE dbo.StatutoryAuthority (
    StatutoryAuthorityID INT            NOT NULL CONSTRAINT PK_StatAuthorityType PRIMARY KEY CLUSTERED  IDENTITY 
  , Value                VARCHAR (100)  NOT NULL
  , DisplaySequence      INT            NOT NULL CONSTRAINT DF_StatutoryAuthority_DisplayOrder   DEFAULT 0
  , Active               BIT            NOT NULL CONSTRAINT DF_StatutoryAuthority_Active         DEFAULT 1
  , Description          VARCHAR (200)  NULL
  , Statute              VARCHAR (100)  NOT NULL CONSTRAINT DF_StatutoryAuthority_StatueNumber   DEFAULT '' 
  , ModifiedDate         DATETIME       NOT NULL CONSTRAINT DF_StatutoryAuthority_ModifiedDate   DEFAULT GETDATE()
  , ModifiedUser         VARCHAR (20)   NOT NULL CONSTRAINT DF_StatutoryAuthority_ModifiedUser   DEFAULT dbo.udf_GetSystemUser()
  , LegacyValue          VARCHAR (50)   NULL
  
  , CONSTRAINT UX_StatAuthorityType_Unique UNIQUE NONCLUSTERED ( Value ASC, Statute ASC )
);

