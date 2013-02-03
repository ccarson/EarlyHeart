CREATE TABLE dbo.ClientContacts (
    ClientContactsID    INT             NOT NULL    IDENTITY
  , ClientID            INT             NOT NULL
  , ContactID           INT             NOT NULL
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_ClientContacts_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_ClientContacts_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_ClientContacts PRIMARY KEY CLUSTERED ( ClientContactsID ASC )
  , CONSTRAINT FK_ClientContacts_Client
        FOREIGN KEY ( ClientID ) REFERENCES dbo.Client ( ClientID )
  , CONSTRAINT FK_ClientContacts_Contact
        FOREIGN KEY ( ContactID ) REFERENCES dbo.Contact ( ContactID )
) ;
GO

CREATE INDEX IX_ClientContacts_ClientID_ContactID ON dbo.ClientContacts ( ClientID ASC, ContactID ASC ) ;
GO

CREATE INDEX IX_ClientContacts_ClientID ON dbo.ClientContacts ( ClientID ASC ) ;
GO

CREATE INDEX IX_ClientContacts_ContactID ON dbo.ClientContacts ( ContactID ASC ) ;
