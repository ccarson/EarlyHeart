CREATE TABLE dbo.ClientFinancial (
    ClientFinancialID       INT             NOT NULL    IDENTITY
  , ClientID                INT             NOT NULL    
  , Year                    INT             NOT NULL    
  , ClientAuditReportType   VARCHAR (100)   NOT NULL    CONSTRAINT DF_ClientFinancial_ClientAuditReportType DEFAULT ('')
  , IsBudget                BIT             NOT NULL    CONSTRAINT DF_ClientFinancial_IsBudget              DEFAULT ((0))
  , IsActuarialStudy        BIT             NOT NULL    CONSTRAINT DF_ClientFinancial_IsActuarialStudy      DEFAULT ((0))
  , ReportPreparedDate      DATE            NULL    
  , ModifiedDate            DATETIME        NOT NULL    CONSTRAINT DF_ClientFinancial_ModifiedDate          DEFAULT (getdate())
  , ModifiedUser            VARCHAR (20)    NOT NULL    CONSTRAINT DF_ClientFinancial_ModifiedUser          DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_ClientFinancial PRIMARY KEY CLUSTERED ( ClientFinancialID ASC )
  , CONSTRAINT FK_ClientFinancial_Client
        FOREIGN KEY ( ClientID ) REFERENCES dbo.Client ( ClientID )
) ;
GO

CREATE INDEX IX_ClientFinancial_ClientID ON dbo.ClientFinancial ( ClientID ASC ) ;
