CREATE TABLE dbo.FirmContacts (
    FirmContactsID  INT             NOT NULL    IDENTITY
  , FirmID          INT             NOT NULL
  , ContactID       INT             NOT NULL
  , ModifiedDate    DATETIME        NOT NULL    CONSTRAINT DF_FirmContacts_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser    VARCHAR (20)    NOT NULL    CONSTRAINT DF_FirmContacts_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_FirmContacts PRIMARY KEY CLUSTERED ( FirmContactsID ASC )
  , CONSTRAINT UX_FirmContacts UNIQUE NONCLUSTERED ( FirmID ASC, ContactID ASC )
  , CONSTRAINT FK_FirmContacts_Contact
        FOREIGN KEY ( ContactID ) REFERENCES dbo.Contact ( ContactID )
  , CONSTRAINT FK_FirmContacts_Firm
        FOREIGN KEY ( FirmID ) REFERENCES dbo.Firm ( FirmID )
) ;
GO

CREATE INDEX IX_FirmContacts_ContactID ON dbo.FirmContacts ( ContactID ASC ) ;
GO

CREATE INDEX IX_FirmContacts_FirmID ON dbo.FirmContacts ( FirmID ASC ) ;
