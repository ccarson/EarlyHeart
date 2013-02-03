CREATE TABLE dbo.IssueFeeCounty (
    IssueFeeCountyID   INT             NOT NULL IDENTITY
  , IssueID            INT             NOT NULL
  , ClientCountiesID   INT             NOT NULL
  , ClientAuditorFeeID INT             NULL
  , EntireFee          DECIMAL (15, 2) NOT NULL CONSTRAINT DF_IssueFeeCounty_EnitreFee          DEFAULT 0
  , FinalFee           DECIMAL (15, 2) NOT NULL CONSTRAINT DF_IssueFeeCounty_FinalFee           DEFAULT 0
  , IsInvoiceWithCD    BIT             NOT NULL CONSTRAINT DF_IssueFeeCounty_IsInvoiceWithCD    DEFAULT 0
  , IsProrated         BIT             NOT NULL CONSTRAINT DF_IssueFeeCounty_IsProrated         DEFAULT 0
  , VerifyDate         DATE            NULL
  , VerifyUser         VARCHAR (20)    NOT NULL CONSTRAINT DF_IssueFeeCounty_VerifyUser         DEFAULT ('')
  , ModifiedDate       DATETIME        NOT NULL    CONSTRAINT DF_IssueFeeCounty_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser       VARCHAR (20)    NOT NULL    CONSTRAINT DF_IssueFeeCounty_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_IssueFeeCounty PRIMARY KEY CLUSTERED ( IssueFeeCountyID ASC )
  , CONSTRAINT FK_IssueFeeCounty_AuditorFeeType
        FOREIGN KEY ( ClientAuditorFeeID ) REFERENCES dbo.ClientAuditorFee ( ClientAuditorFeeID )
  , CONSTRAINT FK_IssueFeeCounty_ClientAuditorFee
        FOREIGN KEY ( ClientCountiesID ) REFERENCES dbo.ClientOverlap ( ClientOverlapID )
  , CONSTRAINT FK_IssueFeeCounty_Issue
        FOREIGN KEY ( IssueID ) REFERENCES dbo.Issue ( IssueID )
) ;
GO

CREATE INDEX IX_IssueFeeCounty_IssueID ON dbo.IssueFeeCounty ( IssueID ASC ) ;
