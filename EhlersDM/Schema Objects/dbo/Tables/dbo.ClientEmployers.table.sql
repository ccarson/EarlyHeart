CREATE TABLE dbo.ClientEmployers (
    ClientEmployersID   INT             NOT NULL    IDENTITY
  , ClientID            INT             NOT NULL
  , EmployerID          INT             NOT NULL
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_ClientEmployers_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_ClientEmployers_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_ClientEmployers PRIMARY KEY CLUSTERED ( ClientEmployersID ASC )
  , CONSTRAINT FK_ClientEmployers_Client
        FOREIGN KEY ( ClientID ) REFERENCES dbo.Client ( ClientID )
  , CONSTRAINT FK_ClientEmployers_Employer
        FOREIGN KEY ( EmployerID ) REFERENCES dbo.Employer ( EmployerID )
) ;
GO

CREATE INDEX IX_ClientEmployers_ClientID_EmployerID ON dbo.ClientEmployers ( ClientID ASC, EmployerID ASC ) ;
GO

CREATE INDEX IX_ClientEmployers_ClientID ON dbo.ClientEmployers ( ClientID ASC ) ;
GO

CREATE INDEX IX_ClientEmployers_EmployerID ON dbo.ClientEmployers ( EmployerID ASC ) ;
