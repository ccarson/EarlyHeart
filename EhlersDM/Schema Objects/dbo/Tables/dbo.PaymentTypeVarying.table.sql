CREATE TABLE dbo.PaymentTypeVarying (
    PaymentTypeVaryingID INT            NOT NULL    CONSTRAINT PK_PaymentTypeVarying PRIMARY KEY CLUSTERED  IDENTITY
  , PurposeID            INT            NOT NULL
  , PaymentTypeID        INT            NOT NULL
  , Name                 VARCHAR (100)  NOT NULL
  , ModifiedDate         DATETIME       NOT NULL    CONSTRAINT DF_PaymentTypeVarying_ModifiedDate DEFAULT (getdate())
  , ModifiedUser         VARCHAR (20)   NOT NULL    CONSTRAINT DF_PaymentTypeVarying_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT UX_PaymentTypeVarying UNIQUE NONCLUSTERED ( Name ASC, PurposeID ASC )
  , CONSTRAINT FK_PaymentTypeVarying_PaymentType
        FOREIGN KEY ( PaymentTypeID ) REFERENCES dbo.PaymentType ( PaymentTypeID )
  , CONSTRAINT FK_PaymentTypeVarying_Purpose
        FOREIGN KEY ( PurposeID ) REFERENCES dbo.Purpose ( PurposeID )
) ;
GO

CREATE INDEX IX_PaymentTypeVarying_PurposeID ON dbo.PaymentTypeVarying ( PurposeID ASC ) ;
