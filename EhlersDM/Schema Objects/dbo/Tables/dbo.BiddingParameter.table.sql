CREATE TABLE dbo.BiddingParameter (
    BiddingParameterID      INT             NOT NULL    IDENTITY
  , IssueID                 INT             NOT NULL
  , MinimumBidPercent       DECIMAL (6, 2)  NOT NULL    CONSTRAINT DF_BiddingParameter_MinimumBid              DEFAULT ((0.00))
  , MaximumBidPercent       DECIMAL (6, 2)  NOT NULL    CONSTRAINT DF_BiddingParameter_MaximumBid              DEFAULT ((0.00))
  , AllowDescendingRate     BIT             NOT NULL    CONSTRAINT DF_BiddingParameter_AllowDescendingRate     DEFAULT ((0))
  , AllowTerm               BIT             NOT NULL    CONSTRAINT DF_BiddingParameter_AllowTerm               DEFAULT ((1))
  , InterestRestriction     BIT             NOT NULL    CONSTRAINT DF_BiddingParameter_InterestRestriction     DEFAULT ((0))
  , AllowMaturityAdjustment BIT             NOT NULL    CONSTRAINT DF_BiddingParameter_AllowMaturityAdjustment DEFAULT ((0))
  , AllowParAdjustment      BIT             NOT NULL    CONSTRAINT DF_BiddingParameter_AllowParAdjustment      DEFAULT ((0))
  , AllowPercentIncrement   BIT             NOT NULL    CONSTRAINT DF_BiddingParameter_AllowPercentIncrement   DEFAULT ((1))
  , DescMaxPct              DECIMAL (6, 2)  NOT NULL    CONSTRAINT DF_BiddingParameter_DescMaxPct              DEFAULT ((0.00))
  , DescRateDate            DATE            NULL
  , MaximumAdjustmentAmount DECIMAL (15, 2) NOT NULL    CONSTRAINT DF_BiddingParameter_MaximumAlterationAmount DEFAULT ((0.00))
  , AwardBasis              VARCHAR (50)    NOT NULL    CONSTRAINT DF_BiddingParameter_AwardBasis              DEFAULT ('')
  , InternetBiddingTypeID   INT             NULL
  , ModifiedDate            DATETIME        NOT NULL    CONSTRAINT DF_BiddingParameter_ModifiedDate DEFAULT (getdate())
  , ModifiedUser            VARCHAR (20)    NOT NULL    CONSTRAINT DF_BiddingParameter_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_BiddingParameter PRIMARY KEY CLUSTERED ( BiddingParameterID ASC )
  , CONSTRAINT UX_BiddingParameter_IssueID UNIQUE NONCLUSTERED ( IssueID ASC )
  , CONSTRAINT FK_BiddingParameter_InternetBidding
        FOREIGN KEY ( InternetBiddingTypeID ) REFERENCES dbo.InternetBiddingType ( InternetBiddingTypeID )
  , CONSTRAINT FK_BiddingParameter_Issue
        FOREIGN KEY ( IssueID ) REFERENCES dbo.Issue ( IssueID )
) ;
GO

CREATE INDEX IX_BiddingParameter_IssueID ON dbo.BiddingParameter ( IssueID ASC ) ;
