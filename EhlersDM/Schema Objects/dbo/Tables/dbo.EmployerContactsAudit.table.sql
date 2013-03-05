CREATE TABLE dbo.EmployerContactsAudit (
    AuditID            INT          NOT NULL    CONSTRAINT PK_EmployerContactsAudit PRIMARY KEY CLUSTERED IDENTITY
  , EmployerContactsID INT          NOT NULL
  , EmployerID         INT          NOT NULL
  , ContactID          INT          NOT NULL
  , ChangeType         CHAR (1)     NOT NULL
  , ModifiedDate       DATETIME     NOT NULL    CONSTRAINT DF_EmployerContactsAudit_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser       VARCHAR (20) NOT NULL    CONSTRAINT DF_EmployerContactsAudit_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
) ;
GO

CREATE INDEX IX_EmployerContactsAudit_EmployerContactsID ON dbo.EmployerContactsAudit ( EmployerContactsID ASC ) ;
