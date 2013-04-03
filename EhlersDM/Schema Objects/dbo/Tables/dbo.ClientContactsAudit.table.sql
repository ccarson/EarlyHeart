CREATE TABLE dbo.ClientContactsAudit (
    AuditID             INT             NOT NULL    IDENTITY
  , ClientContactsID    INT             NOT NULL
  , ClientID            INT             NOT NULL
  , ContactID           INT             NOT NULL
  , ChangeType          CHAR (1)        NOT NULL
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_ClientContactsAudit_ModifiedDate DEFAULT (getdate())
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_ClientContactsAudit_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_ClientContactsAudit PRIMARY KEY CLUSTERED ( AuditID ASC )
) ;
GO

CREATE INDEX IX_ClientContactsAudit_ClientContactsID ON dbo.ClientContactsAudit ( ClientContactsID ASC ) ;
