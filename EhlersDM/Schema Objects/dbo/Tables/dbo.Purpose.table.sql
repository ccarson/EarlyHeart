CREATE TABLE [dbo].[Purpose] (
    [PurposeID]           INT           IDENTITY (1, 1) NOT NULL,
    [IssueID]             INT           NOT NULL,
    [PurposeName]         VARCHAR (150) CONSTRAINT [DF_Purpose_PurposeName] DEFAULT ('') NOT NULL,
    [FinanceTypeID]       INT           NULL,
    [UseProceedID]        INT           NULL,
    [SubIssue]            INT           CONSTRAINT [DF_Purpose_SubIssue] DEFAULT ((0)) NOT NULL,
    [PurposeOrder]        INT           CONSTRAINT [DF_Purpose_PurposeOrder] DEFAULT ((0)) NOT NULL,
    [FundingSourceTypeID] INT           NULL,
    [BackingPayment]      VARCHAR (100) CONSTRAINT [DF_Purpose_BackingPayment] DEFAULT ('') NOT NULL,
    [SubjectToDebtLimit]  BIT           CONSTRAINT [DF_Purpose_SubjectToDebtLimit] DEFAULT ((0)) NOT NULL,
    [ModifiedDate]        DATETIME      CONSTRAINT [DF_Purpose_ModifiedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedUser]        VARCHAR (20)  CONSTRAINT [DF_Purpose_ModifiedUser] DEFAULT ([dbo].[udf_GetSystemUser]()) NOT NULL,
    CONSTRAINT [PK_Purpose] PRIMARY KEY CLUSTERED ([PurposeID] ASC),
    CONSTRAINT [FK_Purpose_FinanceType] FOREIGN KEY ([FinanceTypeID]) REFERENCES [dbo].[FinanceType] ([FinanceTypeID]),
    CONSTRAINT [FK_Purpose_FundingSourceType] FOREIGN KEY ([FundingSourceTypeID]) REFERENCES [dbo].[FundingSourceType] ([FundingSourceTypeID]),
    CONSTRAINT [FK_Purpose_Issue] FOREIGN KEY ([IssueID]) REFERENCES [dbo].[Issue] ([IssueID]),
    CONSTRAINT [FK_Purpose_UseProceed] FOREIGN KEY ([UseProceedID]) REFERENCES [dbo].[UseProceed] ([UseProceedID])
);


GO

CREATE INDEX IX_Purpose_IssueID ON dbo.Purpose ( IssueID ASC ) ;
