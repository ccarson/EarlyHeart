CREATE TABLE dbo.ClientAddresses (
    ClientAddressesID   INT             NOT NULL    IDENTITY
  , ClientID            INT             NOT NULL
  , AddressID           INT             NOT NULL
  , AddressTypeID       INT             NOT NULL
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_ClientAddresses_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_ClientAddresses_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_ClientAddresses PRIMARY KEY CLUSTERED ( ClientAddressesID ASC )
  , CONSTRAINT UX_ClientAddresses UNIQUE NONCLUSTERED ( AddressTypeID ASC, AddressID ASC, ClientID ASC )
  , CONSTRAINT FK_ClientAddresses_Address
        FOREIGN KEY ( AddressID ) REFERENCES dbo.Address ( AddressID )
  , CONSTRAINT FK_ClientAddresses_AddressType
        FOREIGN KEY ( AddressTypeID ) REFERENCES dbo.AddressType ( AddressTypeID )
  , CONSTRAINT FK_ClientAddresses_Client
        FOREIGN KEY ( ClientID ) REFERENCES dbo.Client ( ClientID )
) ;
GO

CREATE INDEX IX_ClientAddresses_ClientID_AddressID ON dbo.ClientAddresses ( ClientID ASC, AddressID ASC ) ;
GO

CREATE INDEX IX_ClientAddresses_AddressID ON dbo.ClientAddresses ( AddressID ASC ) ;
GO

CREATE INDEX IX_ClientAddresses_ClientID ON dbo.ClientAddresses ( ClientID ASC ) ;
