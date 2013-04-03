CREATE TABLE dbo.ContactAddresses (
    ContactAddressesID  INT             NOT NULL    IDENTITY
  , ContactID           INT             NOT NULL
  , AddressID           INT             NOT NULL
  , AddressTypeID       INT             NOT NULL
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_ContactAddresses_ModifiedDate DEFAULT (getdate())
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_ContactAddresses_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_ContactAddresses PRIMARY KEY CLUSTERED ( ContactAddressesID ASC )
  , CONSTRAINT UX_ContactAddresses UNIQUE NONCLUSTERED ( AddressID ASC, ContactID ASC, AddressTypeID ASC )
  , CONSTRAINT FK_ContactAddresses_Address
        FOREIGN KEY ( AddressID ) REFERENCES dbo.Address ( AddressID )
  , CONSTRAINT FK_ContactAddresses_AddressType
        FOREIGN KEY ( AddressTypeID ) REFERENCES dbo.AddressType ( AddressTypeID )
  , CONSTRAINT FK_ContactAddresses_Contact
        FOREIGN KEY ( ContactID ) REFERENCES dbo.Contact ( ContactID )
) ;
GO

CREATE INDEX IX_ContactAddresses_ContactID_AddressID ON dbo.ContactAddresses ( ContactID ASC, AddressID ASC ) ;
GO

CREATE INDEX IX_ContactAddresses_AddressID ON dbo.ContactAddresses ( AddressID ASC ) ;
GO

CREATE INDEX IX_ContactAddresses_ContactID ON dbo.ContactAddresses ( ContactID ASC ) ;
