CREATE TABLE dbo.EmployerContactsAudit (
    AuditID            INT          NOT NULL  IDENTITY
  , EmployerContactsID INT          NOT NULL
  , EmployerID         INT          NOT NULL
  , ContactID          INT          NOT NULL
  , ChangeType         CHAR (1)     NOT NULL
  , ModifiedDate       DATETIME     NOT NULL    CONSTRAINT DF_EmployerContactsAudit_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser       VARCHAR (20) NOT NULL    CONSTRAINT DF_EmployerContactsAudit_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_EmployerContactsAudit PRIMARY KEY CLUSTERED ( AuditID ASC )
  , CONSTRAINT FK_EmployerContactsAudit_EmployerContacts
        FOREIGN KEY ( EmployerContactsID ) REFERENCES dbo.EmployerContacts ( EmployerContactsID )
) ;
GO

CREATE INDEX IX_EmployerContactsAudit_EmployerContactsID ON dbo.EmployerContactsAudit ( EmployerContactsID ASC ) ;
