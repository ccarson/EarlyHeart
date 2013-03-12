CREATE TABLE [dbo].[StatutoryAuthority] (
    [StatutoryAuthorityID] INT           IDENTITY (1, 1) NOT NULL,
    [Value]                VARCHAR (100) NOT NULL,
    [DisplaySequence]      INT           CONSTRAINT [DF_StatutoryAuthority_DisplayOrder] DEFAULT ((0)) NOT NULL,
    [Active]               BIT           CONSTRAINT [DF_StatutoryAuthority_Active] DEFAULT ((1)) NOT NULL,
    [Description]          VARCHAR (200) NULL,
    [Statute]              VARCHAR (100) CONSTRAINT [DF_StatutoryAuthority_StatueNumber] DEFAULT ('') NOT NULL,
    [ModifiedDate]         DATETIME      CONSTRAINT [DF_StatutoryAuthority_ModifiedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedUser]         VARCHAR (20)  CONSTRAINT [DF_StatutoryAuthority_ModifiedUser] DEFAULT ([dbo].[udf_GetSystemUser]()) NOT NULL,
    [LegacyValue]          VARCHAR (50)  NULL,
    CONSTRAINT [PK_StatAuthorityType] PRIMARY KEY CLUSTERED ([StatutoryAuthorityID] ASC),
    CONSTRAINT [UX_StatAuthorityType_Unique] UNIQUE NONCLUSTERED ([Value] ASC, [Statute] ASC)
);

