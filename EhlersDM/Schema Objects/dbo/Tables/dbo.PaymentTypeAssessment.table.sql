CREATE TABLE dbo.PaymentTypeAssessment (
    PaymentTypeAssessmentID INT             NOT NULL    IDENTITY
  , PurposeID               INT             NOT NULL
  , PaymentTypeID           INT             NOT NULL
  , Name                    VARCHAR (100)   NOT NULL
  , TotalAmount             DECIMAL (15, 2) NOT NULL    CONSTRAINT DF_PaymentTypeAssessment_TotalAmount       DEFAULT ((0))
  , PrePaidAmount           DECIMAL (15, 2) NOT NULL    CONSTRAINT DF_PaymentTypeAssessment_PrePaidAmount     DEFAULT ((0))
  , TotalAssessed           DECIMAL (15, 2) NOT NULL    CONSTRAINT DF_PaymentTypeAssessment_TotalAssessed     DEFAULT ((0))
  , Rate                    DECIMAL (7, 4)  NOT NULL    CONSTRAINT DF_PaymentTypeAssessment_Rate              DEFAULT ((0))
  , Terms                   INT             NOT NULL    CONSTRAINT DF_PaymentTypeAssessment_Terms             DEFAULT ((0))
  , CalculationMethod       VARCHAR (100)   NOT NULL    CONSTRAINT DF_PaymentTypeAssessment_CalculationMethod DEFAULT ('')
  , FirstLevyYear           INT             NOT NULL    CONSTRAINT DF_PaymentTypeAssessment_FirstLevyYear     DEFAULT ((0))
  , ModifiedDate            DATETIME        NOT NULL    CONSTRAINT DF_PaymentTypeAssessment_ModifiedDate      DEFAULT (getdate())
  , ModifiedUser            VARCHAR (20)    NOT NULL    CONSTRAINT DF_PaymentTypeAssessment_ModifiedUser      DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_PaymentTypeAssessment PRIMARY KEY CLUSTERED ( PaymentTypeAssessmentID ASC )
  , CONSTRAINT FK_PaymentTypeAssessment_PaymentType FOREIGN KEY ( PaymentTypeID ) REFERENCES dbo.PaymentType ( PaymentTypeID )
  , CONSTRAINT FK_PaymentTypeAssessment_Purpose FOREIGN KEY ( PurposeID ) REFERENCES dbo.Purpose ( PurposeID )
) ;
GO

CREATE INDEX IX_PaymentTypeAssessment_PurposeID ON dbo.PaymentTypeAssessment ( PurposeID ASC ) ;
