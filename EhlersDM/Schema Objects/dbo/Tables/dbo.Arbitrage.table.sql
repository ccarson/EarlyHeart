CREATE TABLE dbo.Arbitrage (
    ArbitrageID             INT             NOT NULL    IDENTITY
  , IssueID                 INT             NOT NULL
  , ServiceAgreement        BIT             NOT NULL    CONSTRAINT DF_Arbitrage_ServiceAgreement    DEFAULT 0
  , ArbitrageStatusID       INT             NULL
  , ArbitrageRecordTypeID   INT             NULL
  , ArbitrageRecordStatusID INT             NULL
  , ArbitrageCategoryID     INT             NULL
  , ArbitrageExceptionID    INT             NULL
  , ExceptionNotMet         VARCHAR (50)    NOT NULL    CONSTRAINT DF_Arbitrage_ExceptionNotMet     DEFAULT 'Pay Rebate'
  , SentDate                DATE            NULL
  , ReceivedDate            DATE            NULL
  , Note                    VARCHAR (MAX)   NOT NULL    CONSTRAINT DF_Arbitrage_Note                DEFAULT ('')
  , ModifiedDate            DATETIME        NOT NULL    CONSTRAINT DF_Arbitrage_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser            VARCHAR (20)    NOT NULL    CONSTRAINT DF_Arbitrage_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_Arbitrage PRIMARY KEY CLUSTERED ( ArbitrageID ASC )
  , CONSTRAINT UX_Arbitrage_IssueID UNIQUE NONCLUSTERED ( IssueID ASC )
  , CONSTRAINT FK_Arbitrage_ArbitrageCategory
        FOREIGN KEY ( ArbitrageCategoryID ) REFERENCES dbo.ArbitrageCategory ( ArbitrageCategoryID )
  , CONSTRAINT FK_Arbitrage_ArbitrageException
        FOREIGN KEY ( ArbitrageExceptionID ) REFERENCES dbo.ArbitrageException ( ArbitrageExceptionID )
  , CONSTRAINT FK_Arbitrage_ArbitrageRecordStatus
        FOREIGN KEY ( ArbitrageRecordStatusID ) REFERENCES dbo.ArbitrageRecordStatus ( ArbitrageRecordStatusID )
  , CONSTRAINT FK_Arbitrage_ArbitrageRecordType
        FOREIGN KEY ( ArbitrageRecordTypeID ) REFERENCES dbo.ArbitrageRecordType ( ArbitrageRecordTypeID )
  , CONSTRAINT FK_Arbitrage_ArbitrageStatus
        FOREIGN KEY ( ArbitrageStatusID ) REFERENCES dbo.ArbitrageStatus ( ArbitrageStatusID )
  , CONSTRAINT FK_Arbitrage_Issue
        FOREIGN KEY ( IssueID ) REFERENCES dbo.Issue ( IssueID )
) ;
GO

CREATE INDEX IX_Arbitrage_IssueID ON dbo.Arbitrage ( IssueID ASC ) ;
