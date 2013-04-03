CREATE TABLE dbo.IssueFirmsContacts (
    IssueFirmsContactsID    INT          NOT NULL   IDENTITY
  , IssueFirmsID            INT          NOT NULL   
  , ContactJobFunctionsID   INT          NOT NULL   
  , Ordinal                 INT          NOT NULL   CONSTRAINT DF_IssueFirmsContacts_Ordinal DEFAULT ((0))
  , ModifiedDate            DATETIME     NOT NULL   CONSTRAINT DF_IssueFirmsContacts_ModifiedDate DEFAULT (getdate())
  , ModifiedUser            VARCHAR (20) NOT NULL   CONSTRAINT DF_IssueFirmsContacts_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_IssueFirmsContacts PRIMARY KEY CLUSTERED ( IssueFirmsContactsID ASC )
  , CONSTRAINT FK_IssueFirmsContacts_ContactJobFunctions
        FOREIGN KEY ( ContactJobFunctionsID ) REFERENCES dbo.ContactJobFunctions ( ContactJobFunctionsID )
  , CONSTRAINT FK_IssueFirmsContacts_IssueFirms
        FOREIGN KEY ( IssueFirmsID ) REFERENCES dbo.IssueFirms ( IssueFirmsID ) ON DELETE CASCADE
) ;
GO

CREATE UNIQUE NONCLUSTERED INDEX UX_IssueFirmsContacts ON dbo.IssueFirmsContacts
    ( IssueFirmsID ASC, ContactJobFunctionsID ASC, Ordinal ASC ) ;
