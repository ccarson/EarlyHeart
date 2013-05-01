CREATE TABLE [dbo].[IssueFee] (
    [IssueFeeID]       INT             IDENTITY (1, 1) NOT NULL,
    [IssueID]          INT             NOT NULL,
    [FirmCategoriesID] INT             NULL,
    [IssueFirmsID]     INT             NULL,
    [FeeTypeID]        INT             NOT NULL,
    [PaymentMethodID]  INT             NULL,
    [EstimatedFee]     DECIMAL (15, 2) CONSTRAINT [DF_IssueFee_EstimatedFee] DEFAULT ((0)) NOT NULL,
    [FinalFee]         DECIMAL (15, 2) CONSTRAINT [DF_IssueFee_FinalFee] DEFAULT ((0)) NOT NULL,
    [EntireFee]        DECIMAL (15, 2) CONSTRAINT [DF_IssueFee_TotalProratedFee] DEFAULT ((0)) NOT NULL,
    [IsProrated]       BIT             CONSTRAINT [DF_IssueFee_IsProrated] DEFAULT ((0)) NOT NULL,
    [VerifiedUser]     VARCHAR (20)    NOT NULL,
    [VerifiedDate]     DATE            NULL,
    [Note]             VARCHAR (200)   CONSTRAINT [DF_IssueFee_Note] DEFAULT ('') NOT NULL,
    [FeeText]          VARCHAR (50)    CONSTRAINT [DF_IssueFee_FeeText] DEFAULT ('') NOT NULL,
    [Ordinal]          INT             CONSTRAINT [DF_IssueFee_Ordinal] DEFAULT ((1)) NOT NULL,
    [ModifiedDate]     DATETIME        CONSTRAINT [DF_IssueFee_ModifiedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedUser]     VARCHAR (20)    CONSTRAINT [DF_IssueFee_ModifiedUser] DEFAULT ([dbo].[udf_GetSystemUser]()) NOT NULL,
    CONSTRAINT [PK_IssueFee] PRIMARY KEY CLUSTERED ([IssueFeeID] ASC),
    CONSTRAINT [FK_IssueFee_FeeType] FOREIGN KEY ([FeeTypeID]) REFERENCES [dbo].[FeeType] ([FeeTypeID]),
    CONSTRAINT [FK_IssueFee_FirmCategories] FOREIGN KEY ([FirmCategoriesID]) REFERENCES [dbo].[FirmCategories] ([FirmCategoriesID]),
    CONSTRAINT [FK_IssueFee_Issue] FOREIGN KEY ([IssueID]) REFERENCES [dbo].[Issue] ([IssueID]),
    CONSTRAINT [FK_IssueFee_IssueFirm] FOREIGN KEY ([IssueFirmsID]) REFERENCES [dbo].[IssueFirms] ([IssueFirmsID]) ON DELETE CASCADE,
    CONSTRAINT [FK_IssueFee_PaymentMethod] FOREIGN KEY ([PaymentMethodID]) REFERENCES [dbo].[PaymentMethod] ([PaymentMethodID]),
    CONSTRAINT [UX_IssueFee_Unique] UNIQUE NONCLUSTERED ([IssueID] ASC, [FeeTypeID] ASC, [Ordinal] ASC)
);


GO

CREATE INDEX IX_IssueFee_IssueID ON dbo.IssueFee ( IssueID ASC ) ;
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description'
                             , @value = N'this is for fees where the firm is picked on the contacts screen - should be null when FirmCategoriesId has value'
                             , @level0type = N'SCHEMA'
                             , @level0name = N'dbo'
                             , @level1type = N'TABLE'
                             , @level1name = N'IssueFee'
                             , @level2type = N'COLUMN'
                             , @level2name = N'IssueFirmsID' ;
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description'
                             , @value = N'this is for fees that have the firm picked on the fee screen - should be null when IssueFirmsId has value'
                             , @level0type = N'SCHEMA'
                             , @level0name = N'dbo'
                             , @level1type = N'TABLE'
                             , @level1name = N'IssueFee'
                             , @level2type = N'COLUMN'
                             , @level2name = N'FirmCategoriesID' ;

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'field added late in development for Misc fields as they are text input. Details fields should be moved to a new table to support multiple inputs for each fee type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IssueFee', @level2type = N'COLUMN', @level2name = N'FeeText';

