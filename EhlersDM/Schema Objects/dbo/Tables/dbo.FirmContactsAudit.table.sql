CREATE TABLE dbo.FirmContactsAudit (
    AuditID         INT             NOT NULL    CONSTRAINT PK_FirmContactsAudit PRIMARY KEY CLUSTERED IDENTITY
  , FirmContactsID  INT             NOT NULL
  , FirmID          INT             NOT NULL
  , ContactID       INT             NOT NULL
  , ChangeType      CHAR (1)        NOT NULL
  , ModifiedDate    DATETIME        NOT NULL    CONSTRAINT DF_FirmContactsAudit_ModifiedDate DEFAULT (getdate())
  , ModifiedUser    VARCHAR (20)    NOT NULL    CONSTRAINT DF_FirmContactsAudit_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
) ;
GO

CREATE INDEX IX_FirmContactsAudit_FirmContactsID ON dbo.FirmContactsAudit ( FirmContactsID ASC ) ;
