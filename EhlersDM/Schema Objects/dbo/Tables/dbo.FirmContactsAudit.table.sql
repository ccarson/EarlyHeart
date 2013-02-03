CREATE TABLE dbo.FirmContactsAudit (
    AuditID         INT             NOT NULL    IDENTITY
  , FirmContactsID  INT             NOT NULL
  , FirmID          INT             NOT NULL
  , ContactID       INT             NOT NULL
  , ChangeType      CHAR (1)        NOT NULL
  , ModifiedDate    DATETIME        NOT NULL    CONSTRAINT DF_FirmContactsAudit_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser    VARCHAR (20)    NOT NULL    CONSTRAINT DF_FirmContactsAudit_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_FirmContactsAudit PRIMARY KEY CLUSTERED ( AuditID ASC )
) ;
GO

CREATE INDEX IX_FirmContactsAudit_FirmContactsID ON dbo.FirmContactsAudit ( FirmContactsID ASC ) ;
