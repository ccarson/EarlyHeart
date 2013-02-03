CREATE TABLE dbo.Purpose (
    PurposeID           INT           NOT NULL  IDENTITY
  , IssueID             INT           NOT NULL
  , PurposeName         VARCHAR (150) NOT NULL  CONSTRAINT DF_Purpose_PurposeName       DEFAULT ('')
  , FinanceTypeID       INT           NULL
  , UseProceedID        INT           NULL
  , SubIssue            INT           NOT NULL  CONSTRAINT DF_Purpose_SubIssue          DEFAULT 0
  , PurposeOrder        INT           NOT NULL  CONSTRAINT DF_Purpose_PurposeOrder      DEFAULT 0
  , FundingSourceTypeID INT           NULL
  , BackingPayment      VARCHAR (100) NOT NULL  CONSTRAINT DF_Purpose_BackingPayment    DEFAULT ('')
  , ModifiedDate        DATETIME      NOT NULL    CONSTRAINT DF_Purpose_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser        VARCHAR (20)  NOT NULL    CONSTRAINT DF_Purpose_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_Purpose PRIMARY KEY CLUSTERED ( PurposeID ASC )
  , CONSTRAINT FK_Purpose_FinanceType
        FOREIGN KEY ( FinanceTypeID ) REFERENCES dbo.FinanceType ( FinanceTypeID )
  , CONSTRAINT FK_Purpose_FundingSourceType
        FOREIGN KEY ( FundingSourceTypeID ) REFERENCES dbo.FundingSourceType ( FundingSourceTypeID )
  , CONSTRAINT FK_Purpose_Issue
        FOREIGN KEY ( IssueID ) REFERENCES dbo.Issue ( IssueID )
  , CONSTRAINT FK_Purpose_UseProceed
        FOREIGN KEY ( UseProceedID ) REFERENCES dbo.UseProceed ( UseProceedID )
) ;
GO

CREATE INDEX IX_Purpose_IssueID ON dbo.Purpose ( IssueID ASC ) ;
