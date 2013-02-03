CREATE TABLE dbo.Address (
    AddressID       INT             NOT NULL    IDENTITY
  , Address1        VARCHAR (50)    NOT NULL
  , Address2        VARCHAR (50)    NOT NULL    CONSTRAINT DF_Address_AddressLine2 DEFAULT ('')
  , Address3        VARCHAR (50)    NOT NULL    CONSTRAINT DF_Address_AddressLine3 DEFAULT ('')
  , City            VARCHAR (50)    NOT NULL
  , State           VARCHAR (2)     NOT NULL
  , Zip             VARCHAR (10)    NOT NULL
  , Verified        BIT             NOT NULL
  , ModifiedDate    DATETIME        NOT NULL    CONSTRAINT DF_Address_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser    VARCHAR (20)    NOT NULL    CONSTRAINT DF_Address_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_Address PRIMARY KEY CLUSTERED ( AddressID ASC )
) ;
