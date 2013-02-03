CREATE TABLE dbo.ContactAddressesAudit (
    AuditID            INT          NOT NULL  IDENTITY
  , ContactAddressesID INT          NOT NULL
  , ContactID          INT          NOT NULL
  , AddressID          INT          NOT NULL
  , AddressTypeID      INT          NOT NULL
  , ChangeType         CHAR (1)     NOT NULL
  , ModifiedDate       DATETIME     NOT NULL    CONSTRAINT DF_ContactAddressesAudit_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser       VARCHAR (20) NOT NULL    CONSTRAINT DF_ContactAddressesAudit_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_ContactAddressesAudit PRIMARY KEY CLUSTERED ( AuditID ASC )
  , CONSTRAINT FK_ContactAddressesAudit_ContactAddresses
        FOREIGN KEY ( ContactAddressesID ) REFERENCES dbo.ContactAddresses ( ContactAddressesID )
) ;
GO

CREATE INDEX IX_ContactAddressesAudit_ContactAddressesID ON dbo.ContactAddressesAudit ( ContactAddressesID ASC ) ;
