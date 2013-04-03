CREATE TABLE dbo.ClientReport (
    ClientReportID          INT             NOT NULL    IDENTITY
  , ClientID                INT             NOT NULL
  , DisclosureReportTypeID  INT             NULL
  , EMMASubmitDate          DATE            NULL
  , Invoicing               VARCHAR (100)   NULL
  , ModifiedDate            DATETIME        NOT NULL    CONSTRAINT DF_ClientReport_ModifiedDate DEFAULT (getdate())
  , ModifiedUser            VARCHAR (20)    NOT NULL    CONSTRAINT DF_ClientReport_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_ClientReport PRIMARY KEY CLUSTERED ( ClientReportID ASC )
  , CONSTRAINT FK_ClientReport_Client
        FOREIGN KEY ( ClientID ) REFERENCES dbo.Client ( ClientID )
  , CONSTRAINT FK_ClientReport_DisclosureReportType
        FOREIGN KEY ( DisclosureReportTypeID ) REFERENCES dbo.DisclosureReportType ( DisclosureReportTypeID )
) ;
GO

CREATE INDEX IX_ClientReport_ClientID ON dbo.ClientReport ( ClientID ASC ) ;
