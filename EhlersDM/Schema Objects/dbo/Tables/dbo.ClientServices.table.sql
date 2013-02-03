CREATE TABLE dbo.ClientServices (
    ClientServicesID    INT             NOT NULL    IDENTITY
  , ClientID            INT             NOT NULL
  , ClientServiceID     INT             NOT NULL
  , Active              BIT             NOT NULL    CONSTRAINT DF_ClientServices_Active DEFAULT 1
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_ClientServices_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_ClientServices_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_ClientServices PRIMARY KEY CLUSTERED ( ClientServicesID ASC )
  , CONSTRAINT UX_ClientServices UNIQUE NONCLUSTERED ( ClientID ASC, ClientServiceID ASC )
  , CONSTRAINT FK_ClientServices_Client
        FOREIGN KEY ( ClientID ) REFERENCES dbo.Client ( ClientID )
  , CONSTRAINT FK_ClientServices_ClientService
        FOREIGN KEY ( ClientServiceID ) REFERENCES dbo.ClientService ( ClientServiceID )
) ;
GO

CREATE INDEX IX_ClientServices_ClientID ON dbo.ClientServices ( ClientID ASC ) ;
