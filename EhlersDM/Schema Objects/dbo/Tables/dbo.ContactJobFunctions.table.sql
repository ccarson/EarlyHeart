CREATE TABLE [dbo].[ContactJobFunctions] (
    [ContactJobFunctionsID] INT          IDENTITY (1, 1) NOT NULL,
    [ContactID]             INT          NOT NULL,
    [JobFunctionID]         INT          NOT NULL,
    [Active]                BIT          CONSTRAINT [DF_ContactJobFunctions_Active] DEFAULT ((1)) NOT NULL,
    [ModifiedDate]          DATETIME     CONSTRAINT [DF_ContactJobFunctions_ModifiedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedUser]          VARCHAR (20) CONSTRAINT [DF_ContactJobFunctions_ModifiedUser] DEFAULT ([dbo].[udf_GetSystemUser]()) NOT NULL,
    CONSTRAINT [PK_ContactJobFunctions] PRIMARY KEY NONCLUSTERED ([ContactJobFunctionsID] ASC),
    CONSTRAINT [FK_ContactJobFunctions_Contact] FOREIGN KEY ([ContactID]) REFERENCES [dbo].[Contact] ([ContactID]),
    CONSTRAINT [FK_ContactJobFunctions_JobFunction] FOREIGN KEY ([JobFunctionID]) REFERENCES [dbo].[JobFunction] ([JobFunctionID]),
    CONSTRAINT [UX_ContactJobFunctions] UNIQUE CLUSTERED ([ContactID] ASC, [JobFunctionID] ASC)
);


GO


CREATE INDEX IX_ContactJobFunctions_ContactID ON dbo.ContactJobFunctions ( ContactID ASC ) ;
GO

CREATE INDEX IX_ContactJobFunctions_JobFunctionID ON dbo.ContactJobFunctions ( JobFunctionID ASC ) ;
