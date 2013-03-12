CREATE TABLE [dbo].[IssueFirms] (
    [IssueFirmsID]     INT          IDENTITY (1, 1) NOT NULL,
    [IssueID]          INT          NOT NULL,
    [FirmCategoriesID] INT          NOT NULL,
    [Ordinal]          INT          CONSTRAINT [DF_IssueFirms_Ordinal] DEFAULT ((1)) NOT NULL,
    [ModifiedDate]     DATETIME     CONSTRAINT [DF_IssueFirms_ModifiedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedUser]     VARCHAR (20) CONSTRAINT [DF_IssueFirms_ModifiedUser] DEFAULT ([dbo].[udf_GetSystemUser]()) NOT NULL,
    CONSTRAINT [PK_IssueFirms] PRIMARY KEY CLUSTERED ([IssueFirmsID] ASC),
    CONSTRAINT [FK_IssueFirms_FirmCategories] FOREIGN KEY ([FirmCategoriesID]) REFERENCES [dbo].[FirmCategories] ([FirmCategoriesID]),
    CONSTRAINT [FK_IssueFirms_Issue] FOREIGN KEY ([IssueID]) REFERENCES [dbo].[Issue] ([IssueID])
);






GO

CREATE INDEX IX_IssueFirms_IssueID ON dbo.IssueFirms ( IssueID ASC ) ;
GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_IssueFirms]
    ON [dbo].[IssueFirms]([FirmCategoriesID] ASC, [IssueID] ASC, [Ordinal] ASC);


