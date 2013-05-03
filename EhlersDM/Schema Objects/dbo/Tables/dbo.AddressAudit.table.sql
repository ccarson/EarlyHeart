CREATE TABLE dbo.AddressAudit (
    AddressAuditID  INT             NOT NULL    CONSTRAINT PK_AddressAudit PRIMARY KEY CLUSTERED    IDENTITY
  , AddressID       INT             NOT NULL
  , Address1        VARCHAR (50)    NOT NULL
  , Address2        VARCHAR (50)    NOT NULL
  , Address3        VARCHAR (50)    NOT NULL
  , City            VARCHAR (50)    NOT NULL
  , State           VARCHAR (2)     NOT NULL
  , Zip             VARCHAR (10)    NOT NULL
  , Verified        BIT             NOT NULL
  , ChangeType      CHAR (1)        NOT NULL
  , ModifiedDate    DATETIME        NOT NULL    CONSTRAINT DF_AddressAudit_ModifiedDate DEFAULT ( GETDATE() )
  , ModifiedUser    VARCHAR (20)    NOT NULL    CONSTRAINT DF_AddressAudit_ModifiedUser DEFAULT ( dbo.udf_GetSystemUser() )
) ;
GO

CREATE INDEX IX_AddressAudit_AddressID ON dbo.AddressAudit ( AddressID ASC ) ;
