CREATE TABLE dbo.TopTaxpayer (
    TopTaxpayerID  INT             NOT NULL IDENTITY
  , ClientID       INT             NULL
  , TaxpayerName   VARCHAR (150)   NOT NULL CONSTRAINT DF_TopTaxpayer_TaxpayerName      DEFAULT ('')
  , PropertyType   VARCHAR (20)    NOT NULL CONSTRAINT DF_TopTaxpayer_PropertyType      DEFAULT ('')
  , AssessedValue  DECIMAL (15, 2) NOT NULL CONSTRAINT DF_TopTaxpayer_AssessedValue     DEFAULT 0.00
  , AssessmentYear SMALLINT        NOT NULL CONSTRAINT DF_TopTaxpayer_AssessmentYear    DEFAULT 0
  , ModifiedDate   DATETIME        NOT NULL    CONSTRAINT DF_TopTaxpayer_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser   VARCHAR (20)    NOT NULL    CONSTRAINT DF_TopTaxpayer_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
 , CONSTRAINT PK_TopTaxpayer PRIMARY KEY CLUSTERED ( TopTaxpayerID ASC )
 , CONSTRAINT FK_TopTaxpayer_Client FOREIGN KEY ( ClientID ) REFERENCES dbo.Client ( ClientID )
) ;
GO

CREATE INDEX IX_TopTaxpayer_ClientID ON dbo.TopTaxpayer ( ClientID ASC ) ;
