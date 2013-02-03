CREATE TABLE dbo.ClientAuditCafr (
    ClientAuditCafrID   INT             NOT NULL    IDENTITY
  , ClientID            INT             NOT NULL
  , FiscalYearEnd       DATE            NULL
  , AuditType           VARCHAR (100)   NOT NULL    CONSTRAINT DF_ClientAuditCAFR_AuditType DEFAULT ('')
  , EMMASubmitDate      DATE            NULL
  , Invoicing           VARCHAR (100)   NOT NULL    CONSTRAINT DF_ClientAuditCAFR_Invoice   DEFAULT ('')
  , IsBudget            BIT             NOT NULL    CONSTRAINT DF_ClientAuditCAFR_IsBudget  DEFAULT 0
  , BudgetFiscalYearEnd DATE            NULL
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_ClientAuditCafr_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_ClientAuditCafr_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_ClientAuditCafr PRIMARY KEY CLUSTERED ( ClientAuditCafrID ASC )
  , CONSTRAINT FK_ClientAuditCafr_Client
        FOREIGN KEY ( ClientID ) REFERENCES dbo.Client ( ClientID )
) ;
GO

CREATE INDEX IX_ClientAuditCafr_ClientID ON dbo.ClientAuditCafr( ClientID ASC ) ;
