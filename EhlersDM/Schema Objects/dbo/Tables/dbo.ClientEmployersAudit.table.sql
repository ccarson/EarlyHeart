CREATE TABLE dbo.ClientEmployersAudit (
    AuditID             INT             NOT NULL    CONSTRAINT PK_ClientEmployersAudit PRIMARY KEY CLUSTERED IDENTITY
  , ClientEmployersID   INT             NOT NULL
  , ClientID            INT             NOT NULL
  , EmployerID          INT             NOT NULL
  , ChangeType          CHAR (1)        NOT NULL
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_ClientEmployersAudit_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_ClientEmployersAudit_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
) ;
GO

CREATE INDEX IX_ClientEmployersAudit_ClientEmployersID ON dbo.ClientEmployersAudit ( ClientEmployersID ASC ) ;
