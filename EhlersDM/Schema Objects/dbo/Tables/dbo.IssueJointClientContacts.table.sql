CREATE TABLE dbo.IssueJointClientContacts (
    IssueJointClientContactsID  INT             NOT NULL    IDENTITY
  , IssueJointClientID          INT             NOT NULL
  , ClientContactsID            INT             NOT NULL
  , Ordinal                     INT             NOT NULL    CONSTRAINT DF_IssueJointClientContacts_Ordinal DEFAULT ((0))
  , ModifiedDate                DATETIME        NOT NULL    CONSTRAINT DF_IssueJointClientContacts_ModifiedDate DEFAULT (getdate())
  , ModifiedUser                VARCHAR (20)    NOT NULL    CONSTRAINT DF_IssueJointClientContacts_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_IssueJointClientContacts PRIMARY KEY CLUSTERED ( IssueJointClientContactsID ASC )
  , CONSTRAINT FK_IssueJointClientContacts_ClientContacts
        FOREIGN KEY ( ClientContactsID ) REFERENCES dbo.ClientContacts ( ClientContactsID )
  , CONSTRAINT FK_IssueJointClientContacts_IssueJointClient
        FOREIGN KEY ( IssueJointClientID ) REFERENCES dbo.IssueJointClient ( IssueJointClientID )
) ;
