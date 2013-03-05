CREATE TABLE [dbo].[Refunding] (
    [RefundingID]        INT          IDENTITY (1, 1) NOT NULL,
    [RefundingPurposeId] INT          NULL,
    [RefundedPurposeId]  INT          NOT NULL,
    [RefundTypeId]       INT          NULL,
    [ModifiedDate]       DATE         CONSTRAINT [DF_Refunding_ModifiedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedUser]       VARCHAR (20) CONSTRAINT [DF_Refunding_ModifiedUser] DEFAULT ([dbo].[udf_GetSystemUser]()) NOT NULL,
    CONSTRAINT [PK_Refunding] PRIMARY KEY CLUSTERED ([RefundingID] ASC),
    CONSTRAINT [FK_Refunding_RefundedPurpose] FOREIGN KEY ([RefundedPurposeId]) REFERENCES [dbo].[Purpose] ([PurposeID]),
    CONSTRAINT [FK_Refunding_RefundingPurpose] FOREIGN KEY ([RefundedPurposeId]) REFERENCES [dbo].[Purpose] ([PurposeID]),
    CONSTRAINT [FK_Refunding_RefundType] FOREIGN KEY ([RefundTypeId]) REFERENCES [dbo].[RefundType] ([RefundTypeID])
);

