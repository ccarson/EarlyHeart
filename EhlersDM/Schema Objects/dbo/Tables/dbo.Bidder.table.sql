CREATE TABLE dbo.Bidder (
    BidderID      INT             NOT NULL  IDENTITY
  , IssueID       INT             NOT NULL
  , FirmID        INT             NOT NULL
  , BidSourceID   INT             NULL
  , BidPrice DECIMAL (15, 2) NOT NULL  CONSTRAINT DF_Bidder_BidPurchasePrice DEFAULT ((0.00))
  , TICPercent    DECIMAL (12, 8) NOT NULL  CONSTRAINT DF_Bidder_TICPercent       DEFAULT ((0))
  , NICPercent    DECIMAL (12, 8) NOT NULL  CONSTRAINT DF_Bidder_BidNIC           DEFAULT ((0))
  , NICAmount     DECIMAL (15, 2) NOT NULL  CONSTRAINT DF_Bidder_BidNICAmount     DEFAULT ((0.00))
  , BABTICPercent DECIMAL (12, 8) NOT NULL  CONSTRAINT DF_Bidder_BABTICPercent    DEFAULT ((0))
  , BABNICPercent DECIMAL (12, 8) NOT NULL  CONSTRAINT DF_Bidder_BABNICPercent    DEFAULT ((0))
  , BABNICAmount  DECIMAL (15, 2) NOT NULL  CONSTRAINT DF_Bidder_BABNICAmount     DEFAULT ((0))
  , HasWinningBID BIT             NOT NULL  CONSTRAINT DF_Bidder_WinningBidInd    DEFAULT ((0))
  , IsRecoveryAct BIT             NOT NULL  CONSTRAINT DF_Bidder_IsRecoveryAct    DEFAULT ((0))
  , ModifiedDate  DATETIME        NOT NULL    CONSTRAINT DF_Bidder_ModifiedDate DEFAULT (getdate())
  , ModifiedUser  VARCHAR (20)    NOT NULL    CONSTRAINT DF_Bidder_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_Bidder PRIMARY KEY CLUSTERED ( BidderID ASC )
  , CONSTRAINT FK_Bidder_BidSource
        FOREIGN KEY ( BidSourceID ) REFERENCES dbo.BidSource ( BidSourceID )
  , CONSTRAINT FK_Bidder_Firm
        FOREIGN KEY ( FirmID ) REFERENCES dbo.Firm ( FirmID )
  , CONSTRAINT FK_Bidder_Issue
        FOREIGN KEY ( IssueID ) REFERENCES dbo.Issue ( IssueID )
 ) ;
GO

CREATE INDEX IX_Bidder_FirmID ON dbo.Bidder ( FirmID ASC ) ;
GO

CREATE INDEX IX_Bidder_IssueID ON dbo.Bidder ( IssueID ASC ) ;
