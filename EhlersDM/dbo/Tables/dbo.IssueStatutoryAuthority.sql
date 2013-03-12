CREATE TABLE [dbo].[IssueStatutoryAuthority] (
    [IssueStatutoryAuthorityID]             INT          IDENTITY (1, 1) NOT NULL,
    [IssueID]                               INT          NOT NULL,
    [StatutoryAuthorityJurisdictionTypesID] INT          NOT NULL,
    [ModifiedDate]                          DATE         CONSTRAINT [DF_IssueStatutoryAuthority_ModifiedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedUser]                          VARCHAR (20) CONSTRAINT [DF_IssueStatutoryAuthority_ModifiedUser] DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_IssueStatutoryAuthority] PRIMARY KEY CLUSTERED ([IssueStatutoryAuthorityID] ASC),
    CONSTRAINT [FK_IssueStatutoryAuthority_Issue] FOREIGN KEY ([IssueID]) REFERENCES [dbo].[Issue] ([IssueID]),
    CONSTRAINT [FK_IssueStatutoryAuthority_StatutoryAuthority] FOREIGN KEY ([StatutoryAuthorityJurisdictionTypesID]) REFERENCES [dbo].[StatutoryAuthorityJurisdictionTypes] ([StatutoryAuthorityJurisdictionTypesID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_IssueStatutoryAuthority_Unique]
    ON [dbo].[IssueStatutoryAuthority]([IssueID] ASC, [StatutoryAuthorityJurisdictionTypesID] ASC);

