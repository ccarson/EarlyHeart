CREATE TABLE dbo.PaymentTypeEqualSingle (
    PaymentTypeEqualSingleID INT             NOT NULL   IDENTITY
  , PurposeID                INT             NOT NULL
  , PaymentTypeID            INT             NOT NULL
  , Name                     VARCHAR (100)   NOT NULL
  , AnnualAmount             DECIMAL (15, 2) NOT NULL   CONSTRAINT DF_PaymentTypeEqualSingle_TotalAmount    DEFAULT 0
  , Terms                    INT             NOT NULL   CONSTRAINT DF_PaymentTypeEqualSingle_Terms          DEFAULT 0
  , FirstLevyYear            INT             NOT NULL   CONSTRAINT DF_PaymentTypeEqualSingle_FirstLevyYear  DEFAULT 0
  , ModifiedDate             DATETIME        NOT NULL   CONSTRAINT DF_PaymentTypeEqualSingle_ModifiedDate   DEFAULT GETDATE()
  , ModifiedUser             VARCHAR (20)    NOT NULL   CONSTRAINT DF_PaymentTypeEqualSingle_ModifiedUser   DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_PaymentTypeEqualSingle PRIMARY KEY CLUSTERED ( PaymentTypeEqualSingleID ASC )
  , CONSTRAINT FK_PaymentTypeEqualSingle_PaymentType FOREIGN KEY ( PaymentTypeID ) REFERENCES dbo.PaymentType ( PaymentTypeID )
  , CONSTRAINT FK_PaymentTypeEqualSingle_Purpose FOREIGN KEY ( PurposeID ) REFERENCES dbo.Purpose ( PurposeID )
) ;
GO

CREATE INDEX IX_PaymentTypeEqualSingle_PurposeID ON dbo.PaymentTypeEqualSingle ( PurposeID ASC ) ;
