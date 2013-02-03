CREATE TABLE dbo.ARRABond (
    ARRABondID              INT             NOT NULL    IDENTITY
  , ARRATypeID              INT             NULL
  , IssueID                 INT             NOT NULL
  , CreditRecipient         VARCHAR (50)    NOT NULL    CONSTRAINT DF_ARRABond_CreditRecipient      DEFAULT ('')
  , ReimbursementPercent    INT             NOT NULL    CONSTRAINT DF_ARRABond_ReimbursementPercent DEFAULT 0
  , ModifiedDate            DATETIME        NOT NULL    CONSTRAINT DF_ARRABond_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser            VARCHAR (20)    NOT NULL    CONSTRAINT DF_ARRABond_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_ARRABond PRIMARY KEY CLUSTERED ( ARRABondID ASC )
  , CONSTRAINT UX_ARRABond_IssueID UNIQUE NONCLUSTERED ( IssueID ASC )
  , CONSTRAINT FK_ARRABond_ARRAType 
        FOREIGN KEY ( ARRATypeID ) REFERENCES dbo.ARRAType ( ARRATypeID )
  , CONSTRAINT FK_ARRABond_Issue 
        FOREIGN KEY ( IssueID ) REFERENCES dbo.Issue ( IssueID )
) ;
GO

CREATE INDEX IX_ARRABond_IssueID ON dbo.ARRABond ( IssueID ASC ) ;
