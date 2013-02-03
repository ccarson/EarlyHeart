CREATE TABLE Conversion.LegacyContacts (
    ContactID       INT          NOT NULL
  , LegacyTableName VARCHAR (50) NOT NULL
  , LegacyContactID INT          NOT NULL
  , CONSTRAINT PK_LegacyContacts PRIMARY KEY CLUSTERED ( ContactID ASC )
  , CONSTRAINT CK_LegacyTableName CHECK ( LegacyTableName = 'ClientContacts' OR LegacyTableName = 'FirmContacts' )
) ;
GO

CREATE UNIQUE NONCLUSTERED INDEX IX_LegacyContacts ON Conversion.LegacyContacts(LegacyTableName ASC, LegacyContactID ASC) ;
