CREATE TABLE dbo.PurposeMaturityRefunding (
    PurposeMaturityRefundingID INT             NOT NULL  IDENTITY
  , PurposeMaturityID          INT             NOT NULL
  , Amount                     DECIMAL (15, 2) NOT NULL
  , ModifiedDate               DATETIME        NOT NULL    CONSTRAINT DF_PurposeMaturityRefunding_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser               VARCHAR (20)    NOT NULL    CONSTRAINT DF_PurposeMaturityRefunding_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_PurposeMaturityRefunding_PurposeMaturityID PRIMARY KEY CLUSTERED ( PurposeMaturityRefundingID ASC )
  , CONSTRAINT FK_PurposeMaturityRefunding_PurposeMaturity
        FOREIGN KEY ( PurposeMaturityID ) REFERENCES dbo.PurposeMaturity ( PurposeMaturityID )
) ;
GO

CREATE INDEX IX_PurposeRefunding_PurposeMaturity ON dbo.PurposeMaturityRefunding ( PurposeMaturityID ASC ) ;
