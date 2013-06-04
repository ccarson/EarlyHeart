CREATE TABLE [dbo].[ContactMailings] (
    [ContactMailingsID] INT          IDENTITY (1, 1) NOT NULL,
    [ContactID]         INT          NOT NULL,
    [MailingTypeID]     INT          NOT NULL,
    [DeliveryMethodID]  INT          CONSTRAINT [DF_ContactMailings_DeliveryMethodID] DEFAULT ((0)) NOT NULL,
    [OptOut]            BIT          CONSTRAINT [DF_ContactMailings_OptOut] DEFAULT ((0)) NOT NULL,
    [OptOutDate]        DATETIME     NULL,
    [ModifiedDate]      DATETIME     CONSTRAINT [DF_ContactMailings_ModifiedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedUser]      VARCHAR (20) CONSTRAINT [DF_ContactMailings_ModifiedUser] DEFAULT ([dbo].[udf_GetSystemUser]()) NOT NULL,
    CONSTRAINT [PK_ContactMailings] PRIMARY KEY CLUSTERED ([ContactMailingsID] ASC),
    CONSTRAINT [FK_ContactMailings_Contact] FOREIGN KEY ([ContactID]) REFERENCES [dbo].[Contact] ([ContactID]),
    CONSTRAINT [FK_ContactMailings_DeliveryMethod] FOREIGN KEY ([DeliveryMethodID]) REFERENCES [dbo].[DeliveryMethod] ([DeliveryMethodID]),
    CONSTRAINT [FK_ContactMailings_MailingType] FOREIGN KEY ([MailingTypeID]) REFERENCES [dbo].[MailingType] ([MailingTypeID]),
    CONSTRAINT [UX_ContactMailings] UNIQUE NONCLUSTERED ([ContactID] ASC, [MailingTypeID] ASC)
);


GO

CREATE INDEX IX_ContactMailings_ContactID ON dbo.ContactMailings ( ContactID ASC ) ;
