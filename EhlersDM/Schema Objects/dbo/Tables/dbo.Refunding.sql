CREATE TABLE dbo.Refunding (
    RefundingID         INT             NOT NULL    CONSTRAINT PK_Refunding PRIMARY KEY CLUSTERED   IDENTITY
  , RefundingPurposeID  INT             NULL
  , RefundedPurposeID   INT             NOT NULL
  , RefundTypeId        INT             NULL
  , TotalSavings        DECIMAL (15,2)  NOT NULL    CONSTRAINT DF_Refunding_TotalSavings    DEFAULT 0
  , NPVSavings          DECIMAL (15,2)  NOT NULL    CONSTRAINT DF_Refunding_NPVSavings      DEFAULT 0
  , MnNPVBenefit        DECIMAL (5,3)   NOT NULL    CONSTRAINT DF_Refunding_MnNPVBenefit    DEFAULT 0
  , OtherNPVBenefit     DECIMAL (5,3)   NOT NULL    CONSTRAINT DF_Refunding_OtherNPVBenefit DEFAULT 0
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_Refunding_ModifiedDate    DEFAULT GETDATE()
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_Refunding_ModifiedUser    DEFAULT dbo.udf_GetSystemUser()

  , CONSTRAINT FK_Refunding_RefundedPurpose 
        FOREIGN KEY ( RefundedPurposeID ) REFERENCES dbo.Purpose ( PurposeID )
  , CONSTRAINT FK_Refunding_RefundingPurpose 
        FOREIGN KEY ( RefundingPurposeID ) REFERENCES dbo.Purpose ( PurposeID )
  , CONSTRAINT FK_Refunding_RefundType 
        FOREIGN KEY ( RefundTypeID ) REFERENCES dbo.RefundType ( RefundTypeID )
);

