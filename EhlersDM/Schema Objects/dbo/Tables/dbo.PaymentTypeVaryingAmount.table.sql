CREATE TABLE dbo.PaymentTypeVaryingAmount (
    PaymentTypeVaryingAmountID INT             NOT NULL IDENTITY
  , PaymentTypeVaryingID       INT             NOT NULL
  , Amount                     DECIMAL (15, 2) NOT NULL CONSTRAINT DF_PaymentTypeVaryingAmount_Amount   DEFAULT 0
  , LevyYear                   INT             NOT NULL CONSTRAINT DF_PaymentTypeVaryingAmount_LevyYear DEFAULT 0
  , ModifiedDate               DATE            NOT NULL    CONSTRAINT DF_PaymentTypeVaryingAmount_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser               VARCHAR (20)    NOT NULL    CONSTRAINT DF_PaymentTypeVaryingAmount_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_PaymentTypeVaryingAmount PRIMARY KEY  ( PaymentTypeVaryingAmountID ASC )
  , CONSTRAINT UX_PaymentTypeVaryingAmount UNIQUE NONCLUSTERED ( PaymentTypeVaryingID ASC, LevyYear ASC )
  , CONSTRAINT FK_PaymentTypeVaryingAmount_PaymentTypeVarying
        FOREIGN KEY ( PaymentTypeVaryingID ) REFERENCES dbo.PaymentTypeVarying ( PaymentTypeVaryingID )
) ;
