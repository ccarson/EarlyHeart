CREATE TABLE dbo.EmployerLocation (
    EmployerLocationID  INT             NOT NULL    IDENTITY
  , EmployerID          INT             NOT NULL
  , LocationType        VARCHAR (50)    NOT NULL
  , StateCode           CHAR (2)        NOT NULL    CONSTRAINT DF_EmployerLocation_StateCode DEFAULT '  '
  , CountyID            INT             NULL
  , CityName            INT             NULL
  , SchoolDistrict      INT             NULL
  , MSAID               INT             NULL
  , ZipCode             VARCHAR (10)    NOT NULL    CONSTRAINT DF_EmployerLocation_ZipCode DEFAULT ('')
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_EmployerLocation_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_EmployerLocation_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_EmployerLocation PRIMARY KEY CLUSTERED ( EmployerLocationID ASC )
  , CONSTRAINT FK_EmployerLocation_Employer
        FOREIGN KEY ( EmployerID ) REFERENCES dbo.Employer ( EmployerID )
) ;
GO

CREATE INDEX IX_EmployerLocation_EmployerID ON dbo.EmployerLocation ( EmployerID ASC ) ;
