CREATE TABLE dbo.IssuePostBond (
    IssuePostBondID INT             NOT NULL    IDENTITY
  , IssueID         INT             NOT NULL
  , AccruedInterest DECIMAL (15, 2) NOT NULL    CONSTRAINT DF_IssuePostBond_AccruedInterest DEFAULT 0
  , BondYear        DECIMAL (15, 2) NOT NULL    CONSTRAINT DF_IssuePostBond_BondYear        DEFAULT 0
  , ArbitrageYield  DECIMAL (11, 8) NOT NULL    CONSTRAINT DF_IssuePostBond_ArbitrageYield  DEFAULT 0
  , AICPercent      DECIMAL (11, 8) NOT NULL    CONSTRAINT DF_IssuePostBond_AIC             DEFAULT 0
  , TICPercent      DECIMAL (11, 8) NOT NULL    CONSTRAINT DF_IssuePostBond_TIC             DEFAULT 0
  , NICPercent      DECIMAL (11, 8) NOT NULL    CONSTRAINT DF_IssuePostBond_NICPercentage   DEFAULT 0
  , NICAmount       DECIMAL (15, 2) NOT NULL    CONSTRAINT DF_IssuePostBond_NIC             DEFAULT 0
  , BABTICPercent   DECIMAL (11, 8) NOT NULL    CONSTRAINT DF_IssuePostBond_BABTIC          DEFAULT 0
  , BABNICPercent   DECIMAL (11, 8) NOT NULL    CONSTRAINT DF_IssuePostBond_BABNIC          DEFAULT 0
  , BABNICAmount    DECIMAL (15, 2) NOT NULL    CONSTRAINT DF_IssuePostBond_BABNICAmount    DEFAULT 0
  , AverageCoupon   DECIMAL (11, 8) NOT NULL    CONSTRAINT DF_IssuePostBond_AverageCoupon   DEFAULT 0
  , AverageLife     DECIMAL (8, 4)  NOT NULL    CONSTRAINT DF_IssuePostBond_AverageLife     DEFAULT 0
  , ModifiedDate    DATETIME        NOT NULL    CONSTRAINT DF_IssuePostBond_ModifiedDate    DEFAULT GETDATE()
  , ModifiedUser    VARCHAR (20)    NOT NULL    CONSTRAINT DF_IssuePostBond_ModifiedUser    DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_IssuePostBond PRIMARY KEY CLUSTERED ( IssuePostBondID )
  , CONSTRAINT UX_IssuePostBond_IssueID UNIQUE NONCLUSTERED ( IssueID )
  , CONSTRAINT FK_IssuePostBond_Issue
        FOREIGN KEY ( IssueID ) REFERENCES dbo.Issue ( IssueID )
) ;
GO

CREATE INDEX IX_IssuePostBond_IssueID ON dbo.IssuePostBond ( IssueID ) ;
