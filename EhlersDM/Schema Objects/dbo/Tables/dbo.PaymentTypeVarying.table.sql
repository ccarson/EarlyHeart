CREATE TABLE dbo.PaymentTypeVarying (
    PaymentTypeVaryingID INT             NOT NULL  IDENTITY
  , PurposeID            INT             NOT NULL
  , PaymentTypeID        INT             NOT NULL
  , Name                 VARCHAR (100)   NOT NULL
  , ModifiedDate         DATE            NOT NULL    CONSTRAINT DF_PaymentTypeVarying_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser         VARCHAR (20)    NOT NULL    CONSTRAINT DF_PaymentTypeVarying_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_PaymentTypeVarying PRIMARY KEY CLUSTERED ( PaymentTypeVaryingID ASC )
  , CONSTRAINT UX_PaymentTypeVarying UNIQUE NONCLUSTERED ( Name ASC, PurposeID ASC )
  , CONSTRAINT FK_PaymentTypeVarying_PaymentType
        FOREIGN KEY ( PaymentTypeID ) REFERENCES dbo.PaymentType ( PaymentTypeID )
  , CONSTRAINT FK_PaymentTypeVarying_Purpose
        FOREIGN KEY ( PurposeID ) REFERENCES dbo.Purpose ( PurposeID )
) ;
GO

CREATE INDEX IX_PaymentTypeVarying_PurposeID ON dbo.PaymentTypeVarying ( PurposeID ASC ) ;
