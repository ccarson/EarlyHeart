CREATE TABLE [dbo].[StatutoryAuthorityJurisdictionTypes] (
    [StatutoryAuthorityJurisdictionTypesID] INT          IDENTITY (1, 1) NOT NULL,
    [StatutoryAuthorityID]                  INT          NOT NULL,
    [JurisdictionTypeID]                    INT          NULL,
    [State]                                 VARCHAR (2)  CONSTRAINT [DF_StatutoryAuthorityJurisdictionTypes_State] DEFAULT ('') NOT NULL,
    [Active]                                BIT          CONSTRAINT [DF_StatutoryAuthorityJurisdictionTypes_Active] DEFAULT ((1)) NOT NULL,
    [ModifiedDate]                          DATE         CONSTRAINT [DF_StatutoryAuthorityJurisdictionTypes_ModifiedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedUser]                          VARCHAR (20) CONSTRAINT [DF_StatutoryAuthorityJurisdictionTypes_ModifiedUser] DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_StatutoryAuthorityJurisdictionTypes] PRIMARY KEY CLUSTERED ([StatutoryAuthorityJurisdictionTypesID] ASC),
    CONSTRAINT [FK_StatutoryAuthorityJurisdictionTypes_SJurisdictionType] FOREIGN KEY ([JurisdictionTypeID]) REFERENCES [dbo].[JurisdictionType] ([JurisdictionTypeID]),
    CONSTRAINT [FK_StatutoryAuthorityJurisdictionTypes_StatutoryAuthority] FOREIGN KEY ([StatutoryAuthorityID]) REFERENCES [dbo].[StatutoryAuthority] ([StatutoryAuthorityID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_StatutoryAuthorityJurisdictionTypes_Unique]
    ON [dbo].[StatutoryAuthorityJurisdictionTypes]([JurisdictionTypeID] ASC, [StatutoryAuthorityID] ASC, [State] ASC);

