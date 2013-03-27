CREATE TABLE [dbo].[Refunding] (
    [RefundingID]        INT             IDENTITY (1, 1) NOT NULL,
    [RefundingPurposeId] INT             NULL,
    [RefundedPurposeId]  INT             NOT NULL,
    [RefundTypeId]       INT             NULL,
    [TotalSavings]       DECIMAL (15, 2) CONSTRAINT [DF_Refunding_TotalSavings] DEFAULT ((0)) NOT NULL,
    [NPVSavings]         DECIMAL (15, 2) CONSTRAINT [DF_Refunding_NPVSavings] DEFAULT ((0)) NOT NULL,
    [MnNPVBenefit]       DECIMAL (5, 3)  CONSTRAINT [DF_Refunding_MNPVSavingPercent] DEFAULT ((0)) NOT NULL,
    [OtherNPVBenefit]    DECIMAL (5, 3)  CONSTRAINT [DF_Refunding_OtherNPVSavingPercent] DEFAULT ((0)) NOT NULL,
    [CallDate]           DATE            NULL,
    [CallPricePercent]   DECIMAL (5, 2)  CONSTRAINT [DF_Refunding_CallPricePercent] DEFAULT ((0)) NOT NULL,
    [ModifiedDate]       DATE            CONSTRAINT [DF_Refunding_ModifiedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedUser]       VARCHAR (20)    CONSTRAINT [DF_Refunding_ModifiedUser] DEFAULT ([dbo].[udf_GetSystemUser]()) NOT NULL,
    CONSTRAINT [PK_Refunding] PRIMARY KEY CLUSTERED ([RefundingID] ASC),
    CONSTRAINT [FK_Refunding_RefundedPurpose] FOREIGN KEY ([RefundedPurposeId]) REFERENCES [dbo].[Purpose] ([PurposeID]),
    CONSTRAINT [FK_Refunding_RefundingPurpose] FOREIGN KEY ([RefundedPurposeId]) REFERENCES [dbo].[Purpose] ([PurposeID]),
    CONSTRAINT [FK_Refunding_RefundType] FOREIGN KEY ([RefundTypeId]) REFERENCES [dbo].[RefundType] ([RefundTypeID])
);



