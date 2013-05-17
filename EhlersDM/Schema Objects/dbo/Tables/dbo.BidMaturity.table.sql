CREATE TABLE [dbo].[BidMaturity] (
    [BidMaturityID]         INT             IDENTITY (1, 1) NOT NULL,
    [BidderID]              INT             NOT NULL,
    [PaymentDate]           DATE            CONSTRAINT [DF_BidMaturity_MaturityDate] DEFAULT ('') NOT NULL,
    [PaymentAmount]         DECIMAL (15, 2) CONSTRAINT [DF_BidMaturity_Maturity] DEFAULT ((0)) NOT NULL,
    [OriginalPaymentAmount] DECIMAL (15, 2) CONSTRAINT [DF_BidMaturity_OrginalMaturity] DEFAULT ((0)) NOT NULL,
    [InterestRate]          DECIMAL (6, 3)  CONSTRAINT [DF_BidMaturity_Coupon] DEFAULT ((0)) NOT NULL,
    [TermBond]              SMALLINT        CONSTRAINT [DF_BidMaturity_TermBond] DEFAULT ((0)) NOT NULL,
    [ModifiedDate]          DATETIME        CONSTRAINT [DF_BidMaturity_ModifiedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedUser]          VARCHAR (20)    CONSTRAINT [DF_BidMaturity_ModifiedUser] DEFAULT ([dbo].[udf_GetSystemUser]()) NOT NULL,
    CONSTRAINT [PK_BidMaturity] PRIMARY KEY CLUSTERED ([BidMaturityID] ASC),
    CONSTRAINT [FK_BidMaturity_Bidder] FOREIGN KEY ([BidderID]) REFERENCES [dbo].[Bidder] ([BidderID])
);


GO

CREATE INDEX IX_BidMaturity_BidderID ON dbo.BidMaturity ( BidderID ASC ) ;
GO

CREATE NONCLUSTERED INDEX [IX_BidMaturity_Compare]
    ON [dbo].[BidMaturity]([BidderID] ASC, [PaymentDate] ASC, [PaymentAmount] ASC, [OriginalPaymentAmount] ASC, [InterestRate] ASC, [TermBond] ASC);


