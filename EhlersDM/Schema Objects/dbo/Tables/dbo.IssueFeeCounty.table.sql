CREATE TABLE dbo.IssueFeeCounty (
    IssueFeeCountyID INT             NOT NULL   CONSTRAINT PK_IssueFeeCounty PRIMARY KEY CLUSTERED   IDENTITY
  , IssueID          INT             NOT NULL
  , CountyClientID   INT             NOT NULL
  , Ordinal          INT             NOT NULL
  , AuditorFeeTypeID INT             NULL
  , EntireFee        DECIMAL (15, 2) NOT NULL   CONSTRAINT DF_IssueFeeCounty_EntireFee       DEFAULT 0
  , FinalFee         DECIMAL (15, 2) NOT NULL   CONSTRAINT DF_IssueFeeCounty_FinalFee        DEFAULT 0
  , IsInvoiceWithCD  BIT             NOT NULL   CONSTRAINT DF_IssueFeeCounty_IsInvoiceWithCD DEFAULT 0
  , IsProrated       BIT             NOT NULL   CONSTRAINT DF_IssueFeeCounty_IsProrated      DEFAULT 0
  , VerifiedDate     DATE            NULL
  , VerifiedUser     VARCHAR (20)    NOT NULL   CONSTRAINT DF_IssueFeeCounty_VerifyUser      DEFAULT ''
  , ModifiedDate     DATETIME        NOT NULL   CONSTRAINT DF_IssueFeeCounty_ModifiedDate    DEFAULT GETDATE()
  , ModifiedUser     VARCHAR (20)    NOT NULL   CONSTRAINT DF_IssueFeeCounty_ModifiedUser    DEFAULT dbo.udf_GetSystemUser()

  , CONSTRAINT FK_IssueFeeCounty_AuditorFeeType
        FOREIGN KEY ( AuditorFeeTypeID ) REFERENCES dbo.ClientAuditorFee ( ClientAuditorFeeID )
  , CONSTRAINT FK_IssueFeeCounty_Client
        FOREIGN KEY ( CountyClientID ) REFERENCES dbo.Client ( ClientID )
  , CONSTRAINT FK_IssueFeeCounty_ClientAuditorFee
        FOREIGN KEY ( CountyClientID ) REFERENCES dbo.ClientOverlap ( ClientOverlapID )
  , CONSTRAINT FK_IssueFeeCounty_Issue
        FOREIGN KEY ( IssueID ) REFERENCES dbo.Issue ( IssueID ) ) ;
GO

CREATE INDEX IX_IssueFeeCounty_IssueID ON dbo.IssueFeeCounty ( IssueID ASC ) ;
