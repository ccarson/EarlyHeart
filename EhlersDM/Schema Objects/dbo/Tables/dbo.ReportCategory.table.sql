CREATE TABLE dbo.ReportCategory (
    ReportCategoryID INT           NOT NULL     CONSTRAINT PK_ReportCategory PRIMARY KEY CLUSTERED  IDENTITY
  , Value            VARCHAR (100) NOT NULL     CONSTRAINT UX_ReportCategory_Value UNIQUE NONCLUSTERED
  , DisplaySequence  INT           NOT NULL     CONSTRAINT DF_ReportCategory_DisplaySequence    DEFAULT 0
  , Active           BIT           NOT NULL     CONSTRAINT DF_ReportCategory_Active             DEFAULT 1
  , Description      VARCHAR (200) NULL
  , ModifiedDate     DATETIME      NOT NULL     CONSTRAINT DF_ReportCategory_ModifiedDate       DEFAULT GETDATE() 
  , ModifiedUser     VARCHAR (20)  NOT NULL     CONSTRAINT DF_ReportCategory_ModifiedUser       DEFAULT dbo.udf_GetSystemUser() 
  , LegacyValue      VARCHAR (50)  NULL ) ;

