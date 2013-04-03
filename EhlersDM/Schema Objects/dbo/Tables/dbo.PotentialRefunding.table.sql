CREATE TABLE [dbo].[PotentialRefunding] (
    [PotentialRefundingID]   INT             IDENTITY (1, 1) NOT NULL,
    [IssueID]                INT             NOT NULL,
    [PotentialRefundTypeID]  INT             NOT NULL,
    [RunDate]                DATE            NULL,
    [NPVSavingsPercent]      DECIMAL (5, 2)  CONSTRAINT [DF_PotentialRefunding_NPVSavingsPercent] DEFAULT ((0.00)) NOT NULL,
    [NPVSavingsAmount]       DECIMAL (15, 2) CONSTRAINT [DF_PotentialRefunding_NPVSavingsAmount] DEFAULT ((0.00)) NOT NULL,
    [FutureSavings]          DECIMAL (15, 2) CONSTRAINT [DF_PotentialRefunding_FutureSavings] DEFAULT ((0)) NOT NULL,
    [DiscountPercent]        DECIMAL (5, 2)  CONSTRAINT [DF_PotentialRefunding_DiscountPercentage] DEFAULT ((0)) NOT NULL,
    [DiscountAmount]         DECIMAL (15, 2) CONSTRAINT [DF_PotentialRefunding_DiscountAmount] DEFAULT ((0)) NOT NULL,
    [CostOfIssuance]         DECIMAL (15, 2) CONSTRAINT [DF_PotentialRefunding_CostOfIssuance] DEFAULT ((0.00)) NOT NULL,
    [NegativeArbitrage]      DECIMAL (15, 2) CONSTRAINT [DF_PotentialRefunding_NegativeArbitrage] DEFAULT ((0.00)) NOT NULL,
    [IsTargetList]           BIT             CONSTRAINT [DF_PotentialRefunding_IsTargetList] DEFAULT ((0)) NOT NULL,
    [IncludeInRefundProcess] BIT             CONSTRAINT [DF_PotentialRefunding_IncludeInRefundProcess] DEFAULT ((0)) NOT NULL,
    [IncludeInLetter]        BIT             CONSTRAINT [DF_PotentialRefunding_IncludeInLetter] DEFAULT ((0)) NOT NULL,
    [Note]                   VARCHAR (MAX)   CONSTRAINT [DF_PotentialRefunding_Note] DEFAULT ('') NOT NULL,
    [ModifiedDate]           DATETIME        CONSTRAINT [DF_PotentialRefunding_ModifiedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedUser]           VARCHAR (20)    CONSTRAINT [DF_PotentialRefunding_ModifiedUser] DEFAULT ([dbo].[udf_GetSystemUser]()) NOT NULL,
    CONSTRAINT [PK_PotentialRefunding] PRIMARY KEY CLUSTERED ([PotentialRefundingID] ASC),
    CONSTRAINT [FK_PotentialRefunding_Issue] FOREIGN KEY ([IssueID]) REFERENCES [dbo].[Issue] ([IssueID]),
    CONSTRAINT [FK_PotentialRefunding_PotentialRefundingType] FOREIGN KEY ([PotentialRefundTypeID]) REFERENCES [dbo].[PotentialRefundType] ([PotentialRefundTypeID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PotentialRefunding_issue]
    ON [dbo].[PotentialRefunding]([IssueID] ASC);

