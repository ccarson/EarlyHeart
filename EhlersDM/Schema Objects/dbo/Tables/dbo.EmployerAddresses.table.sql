CREATE TABLE dbo.EmployerAddresses (
    EmployerAddressesID INT          NOT NULL  IDENTITY
  , EmployerID          INT          NOT NULL
  , AddressID           INT          NOT NULL
  , AddressTypeID       INT          NOT NULL
  , ModifiedDate        DATETIME     NOT NULL    CONSTRAINT DF_EmployerAddresses_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser        VARCHAR (20) NOT NULL    CONSTRAINT DF_EmployerAddresses_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_EmployerAddresses PRIMARY KEY CLUSTERED ( EmployerAddressesID ASC )
  , CONSTRAINT UX_EmployerAddresses UNIQUE NONCLUSTERED ( AddressID ASC, EmployerID ASC, AddressTypeID ASC )
  , CONSTRAINT FK_EmployerAddresses_Address
        FOREIGN KEY ( AddressID ) REFERENCES dbo.Address ( AddressID )
  , CONSTRAINT FK_EmployerAddresses_AddressType
        FOREIGN KEY ( AddressTypeID ) REFERENCES dbo.AddressType ( AddressTypeID )
  , CONSTRAINT FK_EmployerAddresses_Employer
        FOREIGN KEY ( EmployerID ) REFERENCES dbo.Employer ( EmployerID )
) ;
GO

CREATE INDEX IX_EmployerAddresses_AddressID ON dbo.EmployerAddresses ( AddressID ASC ) ;
GO

CREATE INDEX IX_EmployerAddresses_EmployerID ON dbo.EmployerAddresses ( EmployerID ASC ) ;
