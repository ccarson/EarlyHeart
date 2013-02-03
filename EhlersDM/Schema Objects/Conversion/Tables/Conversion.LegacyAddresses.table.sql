CREATE TABLE Conversion.LegacyAddresses (
    AddressID       INT          NOT NULL
  , LegacyTableName VARCHAR (50) NOT NULL
  , LegacyID        INT          NOT NULL
  , CONSTRAINT PK_LegacyAddresses PRIMARY KEY CLUSTERED ( AddressID ASC )
  , CONSTRAINT CK_LegacyAddressTableName CHECK ( LegacyTableName = 'Clients' OR LegacyTableName = 'Firms' OR LegacyTableName = 'ClientContacts' OR  LegacyTableName = 'FirmContacts' )
) ;
GO

CREATE UNIQUE NONCLUSTERED INDEX IX_LegacyAddresses ON Conversion.LegacyAddresses( LegacyTableName ASC, AddressID ASC ) ;
