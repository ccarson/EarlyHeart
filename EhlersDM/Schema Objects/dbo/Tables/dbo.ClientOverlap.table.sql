CREATE TABLE dbo.ClientOverlap (
    ClientOverlapID INT             NOT NULL    IDENTITY
  , ClientID        INT             NOT NULL
  , OverlapClientID INT             NOT NULL
  , OverlapTypeID   INT             NOT NULL
  , Ordinal         INT             NOT NULL
  , ModifiedDate    DATETIME        NOT NULL    CONSTRAINT DF_ClientOverlap_ModifiedDate DEFAULT (getdate())
  , ModifiedUser    VARCHAR (20)    NOT NULL    CONSTRAINT DF_ClientOverlap_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_ClientOverlap PRIMARY KEY CLUSTERED ( ClientOverlapID ASC )
  , CONSTRAINT UX_ClientOverlap UNIQUE NONCLUSTERED ( ClientID ASC, OverlapClientID ASC, Ordinal ASC, OverlapTypeID ASC )
  , CONSTRAINT FK_ClientOverlap_ClientID
        FOREIGN KEY ( ClientID ) REFERENCES dbo.Client ( ClientID )
  , CONSTRAINT FK_ClientOverlap_OverlapClientID
        FOREIGN KEY ( OverlapClientID ) REFERENCES dbo.Client ( ClientID )
  , CONSTRAINT FK_ClientOverlap_OverlapType
        FOREIGN KEY ( OverlapTypeID ) REFERENCES dbo.OverlapType ( OverlapTypeID )
) ;
GO

CREATE INDEX IX_ClientOverlap_ClientID ON dbo.ClientOverlap ( ClientID ASC ) ;
GO

CREATE INDEX IX_ClientOverlap_OverlapClientID ON dbo.ClientOverlap ( OverlapClientID ASC ) ;
