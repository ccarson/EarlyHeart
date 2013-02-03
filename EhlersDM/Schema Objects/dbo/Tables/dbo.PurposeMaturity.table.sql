CREATE TABLE dbo.PurposeMaturity (
    PurposeMaturityID INT             NOT NULL  IDENTITY
  , PurposeID         INT             NOT NULL
  , PaymentDate       DATE            NOT NULL
  , PaymentAmount     DECIMAL (15, 2) NOT NULL  CONSTRAINT DF_PurposeMaturity_PaymentAmount DEFAULT 0
  , ModifiedDate      DATETIME        NOT NULL    CONSTRAINT DF_PurposeMaturity_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser      VARCHAR (20)    NOT NULL    CONSTRAINT DF_PurposeMaturity_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_PurposeMaturity PRIMARY KEY CLUSTERED ( PurposeMaturityID ASC )
  , CONSTRAINT FK_PurposeMaturity_Purpose
        FOREIGN KEY ( PurposeID ) REFERENCES dbo.Purpose ( PurposeID )
) ;
GO

CREATE INDEX IX_PurposeMaturity_Purpose ON dbo.PurposeMaturity ( PurposeID ASC ) ;
