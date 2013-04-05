CREATE TABLE dbo.PurposeUse (
    PurposeUseID    INT             NOT NULL    IDENTITY
  , PurposeID       INT             NOT NULL
  , UseName         VARCHAR (100)   NOT NULL
  , Amount          DECIMAL (15, 2) NOT NULL    CONSTRAINT DF_PurposeUse_Amount       DEFAULT ((0.00))  
  , DisplayOrder    INT             NOT NULL    CONSTRAINT DF_PurposeUse_DisplayOrder DEFAULT ((0))  
  , ModifiedDate    DATETIME        NOT NULL    CONSTRAINT DF_PurposeUse_ModifiedDate DEFAULT (getdate())
  , ModifiedUser    VARCHAR (20)    NOT NULL    CONSTRAINT DF_PurposeUse_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_PurposeUse PRIMARY KEY CLUSTERED ( PurposeUseID ASC )
  , CONSTRAINT FK_PurposeUse_Purpose
        FOREIGN KEY ( PurposeID ) REFERENCES dbo.Purpose ( PurposeID )
) ;
GO

CREATE INDEX IX_PurposeUse_PurposeID ON dbo.PurposeUse ( PurposeID ASC ) ;
