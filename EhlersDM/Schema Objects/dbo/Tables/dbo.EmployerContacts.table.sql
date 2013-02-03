CREATE TABLE dbo.EmployerContacts (
    EmployerContactsID INT          NOT NULL  IDENTITY
  , EmployerID         INT          NOT NULL
  , ContactID          INT          NOT NULL
  , ModifiedDate       DATETIME     NOT NULL    CONSTRAINT DF_EmployerContacts_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser       VARCHAR (20) NOT NULL    CONSTRAINT DF_EmployerContacts_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_EmployerContacts PRIMARY KEY CLUSTERED ( EmployerContactsID ASC )
  , CONSTRAINT FK_EmployerContacts_Contact 
        FOREIGN KEY ( ContactID ) REFERENCES dbo.Contact ( ContactID )
  , CONSTRAINT FK_EmployerContacts_Employer 
        FOREIGN KEY ( EmployerID ) REFERENCES dbo.Employer ( EmployerID )
) ;
GO

CREATE INDEX IX_EmployerContacts_ContactID ON dbo.EmployerContacts ( ContactID ASC ) ;
GO

CREATE INDEX IX_EmployerContacts_EmployerID ON dbo.EmployerContacts ( EmployerID ASC ) ; 
GO

CREATE INDEX IX_EmployerContacts_EmployerID_ContactID ON dbo.EmployerContacts ( EmployerID ASC, ContactID ASC ) ;
