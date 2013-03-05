CREATE TABLE [dbo].[IssuePostBond] (
    [IssuePostBondID]         INT             IDENTITY (1, 1) NOT NULL,
    [IssueID]                 INT             NOT NULL,
    [AccruedInterest]         DECIMAL (15, 2) CONSTRAINT [DF_IssuePostBond_AccruedInterest] DEFAULT ((0)) NOT NULL,
    [BondYear]                DECIMAL (15, 2) CONSTRAINT [DF_IssuePostBond_BondYear] DEFAULT ((0)) NOT NULL,
    [ArbitrageYield]          DECIMAL (11, 8) CONSTRAINT [DF_IssuePostBond_ArbitrageYield] DEFAULT ((0)) NOT NULL,
    [AICPercent]              DECIMAL (11, 8) CONSTRAINT [DF_IssuePostBond_AIC] DEFAULT ((0)) NOT NULL,
    [TICPercent]              DECIMAL (11, 8) CONSTRAINT [DF_IssuePostBond_TIC] DEFAULT ((0)) NOT NULL,
    [NICPercent]              DECIMAL (11, 8) CONSTRAINT [DF_IssuePostBond_NICPercentage] DEFAULT ((0)) NOT NULL,
    [NICAmount]               DECIMAL (15, 2) CONSTRAINT [DF_IssuePostBond_NIC] DEFAULT ((0)) NOT NULL,
    [BABTICPercent]           DECIMAL (11, 8) CONSTRAINT [DF_IssuePostBond_BABTIC] DEFAULT ((0)) NOT NULL,
    [BABNICPercent]           DECIMAL (11, 8) CONSTRAINT [DF_IssuePostBond_BABNIC] DEFAULT ((0)) NOT NULL,
    [BABNICAmount]            DECIMAL (15, 2) CONSTRAINT [DF_IssuePostBond_BABNICAmount] DEFAULT ((0)) NOT NULL,
    [AverageCoupon]           DECIMAL (11, 8) CONSTRAINT [DF_IssuePostBond_AverageCoupon] DEFAULT ((0)) NOT NULL,
    [AverageLife]             DECIMAL (8, 4)  CONSTRAINT [DF_IssuePostBond_AverageLife] DEFAULT ((0)) NOT NULL,
    [WeightedAverageMaturity] DECIMAL (12, 3) CONSTRAINT [DF_IssuePostBond_WeightedAverageMaturity] DEFAULT ((0)) NOT NULL,
    [ModifiedDate]            DATETIME        CONSTRAINT [DF_IssuePostBond_ModifiedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedUser]            VARCHAR (20)    CONSTRAINT [DF_IssuePostBond_ModifiedUser] DEFAULT ([dbo].[udf_GetSystemUser]()) NOT NULL,
    CONSTRAINT [PK_IssuePostBond] PRIMARY KEY CLUSTERED ([IssuePostBondID] ASC),
    CONSTRAINT [FK_IssuePostBond_Issue] FOREIGN KEY ([IssueID]) REFERENCES [dbo].[Issue] ([IssueID]),
    CONSTRAINT [UX_IssuePostBond_IssueID] UNIQUE NONCLUSTERED ([IssueID] ASC)
);


GO

CREATE INDEX IX_IssuePostBond_IssueID ON dbo.IssuePostBond ( IssueID ) ;
