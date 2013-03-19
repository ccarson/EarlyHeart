﻿CREATE TABLE dbo.IssueStatutoryAuthority (
    IssueStatutoryAuthorityID               INT             NOT NULL    CONSTRAINT PK_IssueStatutoryAuthority PRIMARY KEY CLUSTERED IDENTITY
  , IssueID                                 INT             NOT NULL    
  , StatutoryAuthorityJurisdictionTypesID   INT             NOT NULL    
  , Active                                  BIT             NOT NULL    CONSTRAINT DF_IssueStatutoryAuthority_Active        DEFAULT 1
  , ModifiedDate                            DATETIME        NOT NULL    CONSTRAINT DF_IssueStatutoryAuthority_ModifiedDate  DEFAULT GETDATE()
  , ModifiedUser                            VARCHAR (20)    NOT NULL    CONSTRAINT DF_IssueStatutoryAuthority_ModifiedUser  DEFAULT ''

  , CONSTRAINT UX_IssueStatutoryAuthority UNIQUE NONCLUSTERED ( IssueID ASC, StatutoryAuthorityJurisdictionTypesID ASC )
  , CONSTRAINT FK_IssueStatutoryAuthority_Issue 
        FOREIGN KEY ( IssueID ) 
        REFERENCES  dbo.Issue ( IssueID )
  , CONSTRAINT FK_IssueStatutoryAuthority_StatAuthJurisTypes
        FOREIGN KEY ( StatutoryAuthorityJurisdictionTypesID ) 
        REFERENCES  dbo.StatutoryAuthorityJurisdictionTypes ( StatutoryAuthorityJurisdictionTypesID )
);
