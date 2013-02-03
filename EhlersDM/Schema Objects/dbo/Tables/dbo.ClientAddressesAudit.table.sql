CREATE TABLE dbo.ClientAddressesAudit (
    AuditID             INT             NOT NULL    IDENTITY
  , ClientAddressesID   INT             NOT NULL
  , ClientID            INT             NOT NULL
  , AddressID           INT             NOT NULL
  , AddressTypeID       INT             NOT NULL
  , ChangeType          CHAR (1)        NOT NULL
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_ClientAddressesAudit_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_ClientAddressesAudit_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_ClientAddressesAudit PRIMARY KEY CLUSTERED ( AuditID ASC )
  , CONSTRAINT FK_ClientAddressesAudit_ClientAddresses
        FOREIGN KEY ( ClientAddressesID ) REFERENCES dbo.ClientAddresses ( ClientAddressesID )
) ;
GO

CREATE INDEX IX_ClientAddressesAudit_ClientAddressesID ON ClientAddressesAudit ( ClientAddressesID ASC ) ;
