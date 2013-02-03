CREATE TABLE dbo.ClientEmployersAudit (
    AuditID             INT             NOT NULL    IDENTITY
  , ClientEmployersID   INT             NOT NULL
  , ClientID            INT             NOT NULL
  , EmployerID          INT             NOT NULL
  , ChangeType          CHAR (1)        NOT NULL
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_ClientEmployersAudit_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_ClientEmployersAudit_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_ClientEmployersAudit PRIMARY KEY CLUSTERED ( AuditID ASC )
  , CONSTRAINT FK_ClientEmployersAudit_ClientEmployers
        FOREIGN KEY ( ClientEmployersID ) REFERENCES dbo.ClientEmployers ( ClientEmployersID )
) ;
GO

CREATE INDEX IX_ClientEmployersAudit_ClientEmployersID ON dbo.ClientEmployersAudit ( ClientEmployersID ASC ) ;
