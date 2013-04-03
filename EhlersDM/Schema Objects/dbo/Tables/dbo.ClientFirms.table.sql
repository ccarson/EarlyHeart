CREATE TABLE dbo.ClientFirms (
    ClientFirmsID    INT          NOT NULL IDENTITY
  , ClientID         INT          NOT NULL
  , FirmCategoriesID INT          NOT NULL
  , ModifiedDate     DATETIME     NOT NULL    CONSTRAINT DF_ClientFirms_ModifiedDate DEFAULT (getdate())
  , ModifiedUser     VARCHAR (20) NOT NULL    CONSTRAINT DF_ClientFirms_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_ClientFirms PRIMARY KEY CLUSTERED ( ClientFirmsID ASC )
  , CONSTRAINT FK_ClientFirms_Client
        FOREIGN KEY ( ClientID ) REFERENCES dbo.Client ( ClientID )
  , CONSTRAINT FK_ClientFirms_FirmCategories
        FOREIGN KEY ( FirmCategoriesID ) REFERENCES dbo.FirmCategories ( FirmCategoriesID )
) ;
GO

CREATE INDEX IX_ClientFirms_ClientID_FirmCategoriesID ON dbo.ClientFirms ( ClientID ASC, FirmCategoriesID ASC ) ;
GO

CREATE INDEX IX_ClientFirms_ClientID ON dbo.ClientFirms ( ClientID ASC ) ;
GO

CREATE INDEX IX_ClientFirms_FirmCategoriesID ON dbo.ClientFirms ( FirmCategoriesID ASC ) ;
