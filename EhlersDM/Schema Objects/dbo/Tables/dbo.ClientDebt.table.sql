CREATE TABLE dbo.ClientDebt (
    ClientDebtID        INT             NOT NULL    IDENTITY
  , ClientID            INT             NOT NULL
  , ClientDebtLimit     DECIMAL (15, 2) NOT NULL    CONSTRAINT DF_ClientDebt_ClientDebtLimit        DEFAULT 0.00
  , AmountDebtRemaining DECIMAL (15, 2) NOT NULL    CONSTRAINT DF_ClientDebt_AmountDebtRemaining    DEFAULT 0.00
  , TotalGODebt         DECIMAL (15, 2) NOT NULL    CONSTRAINT DF_ClientDebt_TotalGODebt            DEFAULT 0.00
  , InsuranceCoverage   BIT             NOT NULL    CONSTRAINT DF_ClientDebt_InsuranceCoverageInd   DEFAULT 1
  , PaymentDefault      BIT             NOT NULL    CONSTRAINT DF_ClientDebt_PaymentDefaultInd      DEFAULT 0
  , ClientNotes         VARCHAR (500)   NOT NULL    CONSTRAINT DF_ClientDebt_ClientNotes            DEFAULT ('')
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_ClientDebt_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_ClientDebt_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_ClientDebt PRIMARY KEY CLUSTERED ( ClientDebtID ASC )
  , CONSTRAINT FK_ClientDebt_Client
        FOREIGN KEY ( ClientID ) REFERENCES dbo.Client ( ClientID )
) ;
GO

CREATE INDEX IX_ClientDebt_ClientID ON dbo.ClientDebt ( ClientID ASC ) ;
