CREATE TABLE dbo.PurposeMaturity (
    PurposeMaturityID INT             NOT NULL  CONSTRAINT PK_PurposeMaturity PRIMARY KEY CLUSTERED IDENTITY
  , PurposeID         INT             NOT NULL  
  , PaymentDate       DATE            NOT NULL  
  , PaymentAmount     DECIMAL (15, 2) NOT NULL  CONSTRAINT DF_PurposeMaturity_PaymentAmount DEFAULT ((0))
  , ModifiedDate      DATETIME        NOT NULL  CONSTRAINT DF_PurposeMaturity_ModifiedDate  DEFAULT (getdate())
  , ModifiedUser      VARCHAR (20)    NOT NULL  CONSTRAINT DF_PurposeMaturity_ModifiedUser  DEFAULT ([dbo].[udf_GetSystemUser]())

  , CONSTRAINT FK_PurposeMaturity_Purpose
        FOREIGN KEY ( PurposeID ) REFERENCES dbo.Purpose ( PurposeID )
) ;
GO

CREATE INDEX IX_PurposeMaturity_Purpose ON dbo.PurposeMaturity ( PurposeID ASC ) INCLUDE ( PaymentDate, PaymentAmount ) ;
