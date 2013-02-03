CREATE TABLE dbo.ClientDocument (
    ClientDocumentID        INT             NOT NULL    IDENTITY
  , ClientID                INT             NOT NULL
  , ClientDocumentNameID    INT             NOT NULL    CONSTRAINT DF_ClientDocument_ClientDocumentNameID DEFAULT 0
  , DocumentName            VARCHAR (100)   NOT NULL    CONSTRAINT DF_ClientDocument_DocumentName         DEFAULT ('')
  , ClientDocumentTypeID    INT             NOT NULL    CONSTRAINT DF_ClientDocument_ClientDocumentTypeID DEFAULT 0
  , DocumentDate            DATE            NULL
  , IsOnFile                BIT             NOT NULL    CONSTRAINT DF_ClientDocument_IsOnFile             DEFAULT 0
  , ModifiedDate            DATE            NOT NULL    CONSTRAINT DF_ClientDocument_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser            VARCHAR (20)    NOT NULL    CONSTRAINT DF_ClientDocument_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_ClientDocument PRIMARY KEY CLUSTERED ( ClientDocumentID ASC )
  , CONSTRAINT FK_ClientDocument_Client FOREIGN KEY ( ClientID ) REFERENCES dbo.Client ( ClientID ) ) ;
GO

CREATE INDEX IX_ClientDocument_Client ON dbo.ClientDocument ( ClientID ASC ) ;
