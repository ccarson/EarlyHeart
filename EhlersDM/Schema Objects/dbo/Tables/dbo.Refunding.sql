CREATE TABLE dbo.Refunding (
    RefundingID         INT             NOT NULL    CONSTRAINT PK_Refunding PRIMARY KEY CLUSTERED   IDENTITY
  , RefundingPurposeID  INT             NULL
  , RefundedPurposeID   INT             NOT NULL
  , RefundTypeID        INT             NULL
  , TotalSavingsAmount  DECIMAL (15,2)  NOT NULL    CONSTRAINT DF_Refunding_TotalSavingsAmount  DEFAULT 0
  , NPVSavingsAmount    DECIMAL (15,2)  NOT NULL    CONSTRAINT DF_Refunding_NPVSavingsAmount    DEFAULT 0
  , NPVSavingsPercent   DECIMAL (5,3)   NOT NULL    CONSTRAINT DF_Refunding_NPVSavingsPercent   DEFAULT 0
  , CallDate            DATE            NULL
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_Refunding_ModifiedDate        DEFAULT GETDATE()
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_Refunding_ModifiedUser        DEFAULT dbo.udf_GetSystemUser()

  , CONSTRAINT FK_Refunding_RefundedPurpose 
        FOREIGN KEY ( RefundedPurposeID ) REFERENCES dbo.Purpose ( PurposeID )
  , CONSTRAINT FK_Refunding_RefundingPurpose 
        FOREIGN KEY ( RefundingPurposeID ) REFERENCES dbo.Purpose ( PurposeID )
  , CONSTRAINT FK_Refunding_RefundType 
        FOREIGN KEY ( RefundTypeID ) REFERENCES dbo.RefundType ( RefundTypeID )
);

