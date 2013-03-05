CREATE TABLE dbo.ReportHistory (
    ReportHistoryID  INT           NOT NULL CONSTRAINT PK_ReportHistory PRIMARY KEY CLUSTERED   IDENTITY
  , ReportId         INT           NOT NULL
  , RunDate          DATETIME      NOT NULL
  , RunUser          VARCHAR (20)  NOT NULL
  , ReportParameters VARCHAR (MAX) NULL
  , CONSTRAINT FK_ReportHistory_Report
        FOREIGN KEY ( ReportID ) REFERENCES dbo.Report ( ReportID ) ) ;
