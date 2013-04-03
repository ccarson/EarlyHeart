CREATE TABLE dbo.FirmAddresses (
    FirmAddressesID INT          NOT NULL  IDENTITY
  , FirmID          INT          NOT NULL
  , AddressID       INT          NOT NULL
  , AddressTypeID   INT          NOT NULL
  , ModifiedDate    DATETIME     NOT NULL    CONSTRAINT DF_FirmAddresses_ModifiedDate DEFAULT (getdate())
  , ModifiedUser    VARCHAR (20) NOT NULL    CONSTRAINT DF_FirmAddresses_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_FirmAddresses PRIMARY KEY CLUSTERED ( FirmAddressesID ASC )
  , CONSTRAINT UX_FirmAddresses UNIQUE NONCLUSTERED ( AddressID ASC, FirmID ASC, AddressTypeID ASC )
  , CONSTRAINT FK_FirmAddresses_Address
        FOREIGN KEY ( AddressID ) REFERENCES dbo.Address ( AddressID )
  , CONSTRAINT FK_FirmAddresses_AddressType
        FOREIGN KEY ( AddressTypeID ) REFERENCES dbo.AddressType ( AddressTypeID )
  , CONSTRAINT FK_FirmAddresses_Firm
        FOREIGN KEY ( FirmID ) REFERENCES dbo.Firm ( FirmID )
) ;
GO

CREATE INDEX IX_FirmAddresses1 ON dbo.FirmAddresses ( FirmID ASC, AddressID ASC ) ;
GO

CREATE INDEX IX_FirmAddresses2 ON dbo.FirmAddresses ( AddressTypeID ASC, AddressID ASC ) INCLUDE ( FirmID ) ;
