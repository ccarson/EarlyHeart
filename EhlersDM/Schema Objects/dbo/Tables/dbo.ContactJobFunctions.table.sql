CREATE TABLE dbo.ContactJobFunctions (
    ContactJobFunctionsID   INT             NOT NULL    IDENTITY
  , ContactID               INT             NOT NULL
  , JobFunctionID           INT             NOT NULL
  , Active                  BIT             NOT NULL    CONSTRAINT DF_ContactJobFunctions_Active DEFAULT ((1))
  , ModifiedDate            DATETIME        NOT NULL    CONSTRAINT DF_ContactJobFunctions_ModifiedDate DEFAULT (getdate())
  , ModifiedUser            VARCHAR (20)    NOT NULL    CONSTRAINT DF_ContactJobFunctions_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_ContactJobFunctions PRIMARY KEY NONCLUSTERED ( ContactJobFunctionsID ASC )
  , CONSTRAINT UX_ContactJobFunctions UNIQUE CLUSTERED ( ContactID ASC, JobFunctionID ASC )
  , CONSTRAINT FK_ContactJobFunctions_Contact
        FOREIGN KEY ( ContactID ) REFERENCES dbo.Contact ( ContactID )
  , CONSTRAINT FK_ContactJobFunctions_JobFunction
        FOREIGN KEY ( JobFunctionID ) REFERENCES dbo.JobFunction ( JobFunctionID )
) ;
GO


CREATE INDEX IX_ContactJobFunctions_ContactID ON dbo.ContactJobFunctions ( ContactID ASC ) ;
GO

CREATE INDEX IX_ContactJobFunctions_JobFunctionID ON dbo.ContactJobFunctions ( JobFunctionID ASC ) ;
