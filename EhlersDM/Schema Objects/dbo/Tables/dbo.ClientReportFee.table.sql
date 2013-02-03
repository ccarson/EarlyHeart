CREATE TABLE dbo.ClientReportFee (
    ClientReportFeeID   INT             NOT NULL    IDENTITY
  , ClientReportID      INT             NOT NULL
  , FeeTypeID           INT             NOT NULL
  , Amount              DECIMAL (15, 2) NOT NULL    CONSTRAINT DF_ClientReportFee_Amount DEFAULT 0
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_ClientReportFee_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_ClientReportFee_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_ClientReportFee PRIMARY KEY CLUSTERED ( ClientReportFeeID ASC )
  , CONSTRAINT FK_ClientReportFee_Client
        FOREIGN KEY ( ClientReportID ) REFERENCES dbo.ClientReport ( ClientReportID )
  , CONSTRAINT FK_ClientReportFee_FeeType
        FOREIGN KEY ( FeeTypeID ) REFERENCES dbo.FeeType ( FeeTypeID )
) ;
GO

CREATE INDEX IX_ClientReportFee_ClientReportID ON dbo.ClientReportFee ( ClientReportID ASC ) ;
GO

CREATE INDEX IX_ClientReportFee_FeeTypeID ON dbo.ClientReportFee ( FeeTypeID ASC ) ;
