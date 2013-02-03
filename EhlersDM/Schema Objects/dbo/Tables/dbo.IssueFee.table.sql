CREATE TABLE dbo.IssueFee (
    IssueFeeID      INT             NOT NULL    IDENTITY
  , IssueID         INT             NOT NULL
  , FirmID          INT             NOT NULL
  , FeeTypeID       INT             NOT NULL
  , PaymentMethodID INT             NULL
  , EstimatedFee    DECIMAL (15, 2) NOT NULL    CONSTRAINT DF_IssueFee_EstimatedFee     DEFAULT 0
  , FinalFee        DECIMAL (15, 2) NOT NULL    CONSTRAINT DF_IssueFee_FinalFee         DEFAULT 0
  , EntireFee       DECIMAL (15, 2) NOT NULL    CONSTRAINT DF_IssueFee_TotalProratedFee DEFAULT 0
  , IsProrated      BIT             NOT NULL    CONSTRAINT DF_IssueFee_IsProrated       DEFAULT 0
  , VerifiedUser    VARCHAR (20)    NOT NULL
  , VerifiedDate    DATE            NULL
  , Note            VARCHAR (200)   NOT NULL    CONSTRAINT DF_IssueFee_Note             DEFAULT ('')
  , ModifiedDate    DATETIME        NOT NULL    CONSTRAINT DF_IssueFee_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser    VARCHAR (20)    NOT NULL    CONSTRAINT DF_IssueFee_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_IssueFee PRIMARY KEY CLUSTERED ( IssueFeeID ASC )
  , CONSTRAINT FK_IssueFee_FeeType
        FOREIGN KEY ( FeeTypeID ) REFERENCES dbo.FeeType ( FeeTypeID )
  , CONSTRAINT FK_IssueFee_Firm
        FOREIGN KEY ( FirmID ) REFERENCES dbo.Firm ( FirmID )
  , CONSTRAINT FK_IssueFee_Issue
        FOREIGN KEY ( IssueID ) REFERENCES dbo.Issue ( IssueID )
  , CONSTRAINT FK_IssueFee_PaymentMethod
        FOREIGN KEY ( PaymentMethodID ) REFERENCES dbo.PaymentMethod ( PaymentMethodID )
) ;
GO

CREATE INDEX IX_IssueFee_IssueID ON dbo.IssueFee ( IssueID ASC ) ;
GO

CREATE INDEX IX_IssueFee_FirmID ON dbo.IssueFee ( FirmID ASC ) ;
GO

