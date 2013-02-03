CREATE TABLE dbo.EmployerAddressesAudit (
    AuditID             INT             NOT NULL    IDENTITY
  , EmployerAddressesID INT             NOT NULL
  , EmployerID          INT             NOT NULL
  , AddressID           INT             NOT NULL
  , AddressTypeID       INT             NOT NULL
  , ChangeType          CHAR (1)        NOT NULL
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_EmployerAddressesAudit_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_EmployerAddressesAudit_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_EmployerAddressesAudit PRIMARY KEY CLUSTERED ( AuditID ASC )
  , CONSTRAINT FK_EmployerAddressesAudit_EmployerAddresses
        FOREIGN KEY ( EmployerAddressesID ) REFERENCES dbo.EmployerAddresses ( EmployerAddressesID )
) ;
GO

CREATE INDEX IX_EmployerAddressesAudit_EmployerAddressesID ON dbo.EmployerAddressesAudit ( EmployerAddressesID ASC ) ;
