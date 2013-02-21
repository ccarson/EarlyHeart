CREATE TABLE dbo.FirmAddressesAudit (
    AuditID         INT             NOT NULL    CONSTRAINT PK_FirmAddressesAudit PRIMARY KEY CLUSTERED IDENTITY
  , FirmAddressesID INT             NOT NULL
  , FirmID          INT             NOT NULL
  , AddressID       INT             NOT NULL
  , AddressTypeID   INT             NOT NULL
  , ChangeType      CHAR (1)        NOT NULL
  , ModifiedDate    DATETIME        NOT NULL    CONSTRAINT DF_FirmAddressesAudit_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser    VARCHAR (20)    NOT NULL    CONSTRAINT DF_FirmAddressesAudit_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
) ;
GO

CREATE INDEX IX_FirmAddressesAudit_FirmAddressesID ON dbo.FirmAddressesAudit ( FirmAddressesID ASC ) ;
