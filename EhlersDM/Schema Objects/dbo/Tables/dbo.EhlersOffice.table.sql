CREATE TABLE dbo.EhlersOffice (
    EhlersOfficeID  INT             NOT NULL    IDENTITY
  , AddressID       INT             NOT NULL
  , Phone           VARCHAR (15)    NOT NULL    CONSTRAINT DF_EhlersOffice_Phone    DEFAULT ('')
  , TollFree        VARCHAR (15)    NOT NULL    CONSTRAINT DF_EhlersOffice_TollFree DEFAULT ('')
  , Fax             VARCHAR (15)    NOT NULL    CONSTRAINT DF_EhlersOffice_Fax      DEFAULT ('')
  , WebSite         VARCHAR (150)   NOT NULL    CONSTRAINT DF_EhlersOffice_Website  DEFAULT ('')
  , ReportFooter    VARBINARY (MAX) NULL
  , ModifiedDate    DATETIME        NOT NULL    CONSTRAINT DF_EhlersOffice_ModifiedDate DEFAULT (getdate())
  , ModifiedUser    VARCHAR (20)    NOT NULL    CONSTRAINT DF_EhlersOffice_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_EhlersOffice PRIMARY KEY CLUSTERED ( EhlersOfficeID ASC )
  , CONSTRAINT FK_EhlersOffice_Address
        FOREIGN KEY ( AddressID ) REFERENCES dbo.Address ( AddressID )
) ;
