CREATE TABLE dbo.ArbitrageService (
    ArbitrageServiceID          INT             NOT NULL    IDENTITY
  , IssueID                     INT             NOT NULL
  , ServiceDate                 DATE            NOT NULL
  , ArbitrageComputationTypeID  INT             NOT NULL
  , DataRequested               BIT             NOT NULL    CONSTRAINT DF_ArbitrageService_DataRequested    DEFAULT ((0))
  , DataReceived                BIT             NOT NULL    CONSTRAINT DF_ArbitrageService_DataReceived     DEFAULT ((0))
  , ArbitrageReport             BIT             NOT NULL    CONSTRAINT DF_ArbitrageService_ArbitrageReport  DEFAULT ((0))
  , ArbitrageFee                DECIMAL (15, 2) NOT NULL    CONSTRAINT DF_ArbitrageService_ArbitrageFee     DEFAULT ((0))
  , InvoiceDate                 DATE            NULL
  , ModifiedDate                DATETIME        NOT NULL    CONSTRAINT DF_ArbitrageService_ModifiedDate DEFAULT (getdate())
  , ModifiedUser                VARCHAR (20)    NOT NULL    CONSTRAINT DF_ArbitrageService_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_ArbitrageService PRIMARY KEY CLUSTERED ( ArbitrageServiceID ASC )
  , CONSTRAINT FK_ArbitrageService_ArbitrageComputationType
        FOREIGN KEY ( ArbitrageComputationTypeID ) REFERENCES dbo.ArbitrageComputationType ( ArbitrageComputationTypeID )
  , CONSTRAINT FK_ArbitrageService_Issue
        FOREIGN KEY ( IssueID ) REFERENCES dbo.Issue ( IssueID )
) ;
GO

CREATE INDEX IX_ArbitrageService_IssueID ON dbo.ArbitrageService ( IssueID ASC ) ;
