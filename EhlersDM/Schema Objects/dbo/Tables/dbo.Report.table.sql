CREATE TABLE dbo.Report (
    ReportID         INT           NOT NULL     CONSTRAINT PK_Report PRIMARY KEY CLUSTERED  IDENTITY
  , ReportCategoryID INT           NOT NULL
  , Name             VARCHAR (100) NOT NULL
  , DocumentName     VARCHAR (50)  NOT NULL
  , InputSet         INT           NOT NULL     CONSTRAINT DF_Report_InputSet           DEFAULT ((1))
  , DisplaySequence  INT           NOT NULL     CONSTRAINT DF_Report_DisplaySequence    DEFAULT ((0))
  , Active           BIT           NOT NULL     CONSTRAINT DF_Report_Active             DEFAULT ((1))
  , ModifiedDate     DATETIME      NOT NULL     CONSTRAINT DF_Report_ModifiedDate       DEFAULT (getdate())
  , ModifiedUser     VARCHAR (20)  NOT NULL     CONSTRAINT DF_Report_ModifiedUser       DEFAULT ([dbo].[udf_GetSystemUser]())

  , CONSTRAINT FK_Report_ReportCategory
        FOREIGN KEY ( ReportCategoryID ) REFERENCES dbo.ReportCategory ( ReportCategoryID ) ) ;
