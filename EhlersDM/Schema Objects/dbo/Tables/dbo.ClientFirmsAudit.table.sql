CREATE TABLE dbo.ClientFirmsAudit (
    AuditID             INT             NOT NULL    IDENTITY
  , ClientFirmsID       INT             NOT NULL
  , ClientID            INT             NOT NULL
  , FirmCategoriesID    INT             NOT NULL
  , ChangeType          CHAR (1)        NOT NULL
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_ClientFirmsAudit_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_ClientFirmsAudit_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_ClientFirmsAudit PRIMARY KEY CLUSTERED ( AuditID ASC )
) ;
GO

CREATE INDEX IX_ClientFirmsAudit_ClientFirmsID ON dbo.ClientFirmsAudit ( ClientFirmsID ASC ) ;
