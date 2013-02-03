CREATE TABLE dbo.FundsOnHand (
    FundsOnHandID INT             NOT NULL
  , ClientID      INT             NOT NULL
  , FundName      VARCHAR (100)   NOT NULL
  , FundBalance   DECIMAL (15, 2) NOT NULL
  , BalanceDate   DATE            NOT NULL
  , ModifiedDate  DATETIME        NOT NULL    CONSTRAINT DF_FundsOnHand_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser  VARCHAR (20)    NOT NULL    CONSTRAINT DF_FundsOnHand_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_FundsOnHand PRIMARY KEY CLUSTERED ( FundsOnHandID ASC )
  , CONSTRAINT FK_FundsOnHand_Client
        FOREIGN KEY ( ClientID ) REFERENCES dbo.Client ( ClientID )
) ;
GO

CREATE INDEX IX_FundsOnHand_ClientID ON dbo.FundsOnHand ( ClientID ASC ) ;
