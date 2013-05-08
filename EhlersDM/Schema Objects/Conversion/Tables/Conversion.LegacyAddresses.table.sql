CREATE TABLE Conversion.LegacyAddresses (
    AddressID       INT          NOT NULL
  , LegacyTableName VARCHAR (50) NOT NULL
  , LegacyID        INT          NOT NULL
  , CONSTRAINT PK_LegacyAddresses PRIMARY KEY CLUSTERED ( AddressID ASC )
  , CONSTRAINT CK_LegacyAddressTableName CHECK ( LegacyTableName = 'Clients' OR LegacyTableName = 'Firms' OR LegacyTableName = 'ClientContacts' OR  LegacyTableName = 'FirmContacts' )
  , CONSTRAINT FK_LegacyAddresses_Address FOREIGN KEY ( AddressID ) REFERENCES dbo.Address( AddressID )
) ;
GO

CREATE UNIQUE NONCLUSTERED INDEX IX_LegacyAddresses ON Conversion.LegacyAddresses( LegacyTableName ASC, AddressID ASC ) ;
