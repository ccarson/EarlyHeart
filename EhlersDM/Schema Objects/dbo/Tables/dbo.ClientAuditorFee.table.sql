CREATE TABLE dbo.ClientAuditorFee (
    ClientAuditorFeeID  INT             NOT NULL    IDENTITY
  , ClientID            INT             NOT NULL
  , AuditorFeeTypeID    INT             NOT NULL
  , Amount              DECIMAL (15, 2) NOT NULL    CONSTRAINT DF_ClientAuditorFee_Amount DEFAULT 0
  , ModifiedDate        DATE            NOT NULL    CONSTRAINT DF_ClientAuditorFee_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_ClientAuditorFee_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_ClientAuditorFee PRIMARY KEY CLUSTERED ( ClientAuditorFeeID ASC )
  , CONSTRAINT FK_ClientAuditorFee_Client
        FOREIGN KEY ( ClientID ) REFERENCES dbo.Client ( ClientID )
  , CONSTRAINT FK_ClientAuditorFee_FeeTypeAuditor
        FOREIGN KEY ( AuditorFeeTypeID ) REFERENCES dbo.AuditorFeeType ( AuditorFeeTypeID )
) ;
GO

CREATE INDEX IX_ClientAuditorFee_ClientID ON dbo.ClientAuditorFee ( ClientID ASC ) ;
