CREATE TABLE dbo.PotentialRefunding (
    PotentialRefundingID   INT             NOT NULL CONSTRAINT PK_PotentialRefunding PRIMARY KEY CLUSTERED  IDENTITY
  , IssueID                INT             NOT NULL
  , PotentialRefundTypeID  INT             NOT NULL
  , RunDate                DATE            NULL
  , NPVSavingsPercent      DECIMAL (5, 2)  NOT NULL CONSTRAINT DF_PotentialRefunding_NPVSavingsPercent      DEFAULT 0.00
  , NPVSavingsAmount       DECIMAL (15, 2) NOT NULL CONSTRAINT DF_PotentialRefunding_NPVSavingsAmount       DEFAULT 0.00
  , FutureSavings          DECIMAL (15, 2) NOT NULL CONSTRAINT DF_PotentialRefunding_FutureSavings          DEFAULT 0
  , DiscountPercent        DECIMAL (5, 2)  NOT NULL CONSTRAINT DF_PotentialRefunding_DiscountPercentage     DEFAULT 0
  , DiscountAmount         DECIMAL (15, 2) NOT NULL CONSTRAINT DF_PotentialRefunding_DiscountAmount         DEFAULT 0
  , CostOfIssuance         DECIMAL (15, 2) NOT NULL CONSTRAINT DF_PotentialRefunding_CostOfIssuance         DEFAULT 0.00
  , NegativeArbitrage      DECIMAL (15, 2) NOT NULL CONSTRAINT DF_PotentialRefunding_NegativeArbitrage      DEFAULT 0.00
  , IsTargetList           BIT             NOT NULL CONSTRAINT DF_PotentialRefunding_IsTargetList           DEFAULT 0
  , IncludeInRefundProcess BIT             NOT NULL CONSTRAINT DF_PotentialRefunding_IncludeInRefundProcess DEFAULT 0
  , IncludeInLetter        BIT             NOT NULL CONSTRAINT DF_PotentialRefunding_IncludeInLetter        DEFAULT 0
  , Note                   VARCHAR (MAX)   NOT NULL CONSTRAINT DF_PotentialRefunding_Note                   DEFAULT ''
  , ModifiedDate           DATETIME        NOT NULL CONSTRAINT DF_PotentialRefunding_ModifiedDate           DEFAULT GETDATE()
  , ModifiedUser           VARCHAR (20)    NOT NULL CONSTRAINT DF_PotentialRefunding_ModifiedUser           DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT UX_PotentialRefunding UNIQUE NONCLUSTERED ( IssueID ASC, PotentialRefundTypeID ASC )
  , CONSTRAINT FK_PotentialRefunding_Issue
        FOREIGN KEY ( IssueID ) REFERENCES dbo.Issue ( IssueID )
  , CONSTRAINT FK_PotentialRefunding_PotentialRefundType
        FOREIGN KEY ( PotentialRefundTypeID ) REFERENCES dbo.PotentialRefundType ( PotentialRefundTypeID )
) ;
GO

CREATE INDEX IX_PotentialRefunding_IssueID ON dbo.PotentialRefunding ( IssueID ASC ) ;
