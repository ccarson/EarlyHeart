CREATE TABLE [dbo].[IssueMaturity] (
    [IssueMaturityID]           INT             IDENTITY (1, 1) NOT NULL,
    [IssueID]                   INT             NOT NULL,
    [InsuranceFirmCategoriesID] INT             NULL,
    [LegacyInsuranceCode]       VARCHAR (10)    CONSTRAINT [DF_IssueMaturity_LegacyInsuranceFirm] DEFAULT ('') NOT NULL,
    [PaymentDate]               DATE            NOT NULL,
    [Cusip3]                    VARCHAR (3)     CONSTRAINT [DF_IssueMaturity_Cusip3] DEFAULT ('') NOT NULL,
    [RefundedCusip]             VARCHAR (3)     CONSTRAINT [DF_IssueMaturity_RefundedCusip] DEFAULT ('') NOT NULL,
    [UnrefundedCusip]           VARCHAR (3)     CONSTRAINT [DF_IssueMaturity_UnrefundedCusip] DEFAULT ('') NOT NULL,
    [InterestRate]              DECIMAL (7, 4)  CONSTRAINT [DF_IssueMaturity_InterestRate] DEFAULT ((0)) NOT NULL,
    [Term]                      SMALLINT        CONSTRAINT [DF_IssueMaturity_BondTerm] DEFAULT ((0)) NOT NULL,
    [PriceToCall]               BIT             CONSTRAINT [DF_IssueMaturity_PriceToCall] DEFAULT ((0)) NOT NULL,
    [ReofferingYield]           DECIMAL (7, 4)  CONSTRAINT [DF_IssueMaturity_ReofferingYield] DEFAULT ((0)) NOT NULL,
    [NotReoffered]              BIT             CONSTRAINT [DF_IssueMaturity_NotReoffered] DEFAULT ((0)) NOT NULL,
    [PricePercent]              DECIMAL (12, 3) CONSTRAINT [DF_IssueMaturity_PricePercent] DEFAULT ((0)) NOT NULL,
    [PriceDollar]               DECIMAL (15, 2) CONSTRAINT [DF_IssueMaturity_DollarPrice] DEFAULT ((0)) NOT NULL,
    [ModifiedDate]              DATETIME        CONSTRAINT [DF_IssueMaturity_ModifiedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedUser]              VARCHAR (20)    CONSTRAINT [DF_IssueMaturity_ModifiedUser] DEFAULT ([dbo].[udf_GetSystemUser]()) NOT NULL,
    CONSTRAINT [PK_IssueMaturity] PRIMARY KEY CLUSTERED ([IssueMaturityID] ASC),
    CONSTRAINT [FK_IssueMaturity_FirmCategories] FOREIGN KEY ([InsuranceFirmCategoriesID]) REFERENCES [dbo].[FirmCategories] ([FirmCategoriesID]),
    CONSTRAINT [FK_IssueMaturity_Issue] FOREIGN KEY ([IssueID]) REFERENCES [dbo].[Issue] ([IssueID])
);


GO

CREATE INDEX IX_IssueMaturity_IssueID ON dbo.IssueMaturity ( IssueID ASC ) ;
