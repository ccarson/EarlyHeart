CREATE TABLE dbo.PurposeSource (
    PurposeSourceID     INT             NOT NULL    IDENTITY
  , PurposeID           INT             NOT NULL
  , SourceName          VARCHAR (100)   NOT NULL    CONSTRAINT DF_PurposeSource_SourceName  DEFAULT ('')
  , Amount              DECIMAL (15, 2) NOT NULL    CONSTRAINT DF_PurposeSource_Amount      DEFAULT ((0.00))
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_PurposeSource_ModifiedDate DEFAULT (getdate())
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_PurposeSource_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_PurposeSource PRIMARY KEY CLUSTERED ( PurposeSourceID ASC )
  , CONSTRAINT FK_PurposeSource_Purpose
        FOREIGN KEY ( PurposeID ) REFERENCES dbo.Purpose ( PurposeID )
) ;
GO

CREATE INDEX IX_PurposeSource_PurposeID ON dbo.PurposeSource ( PurposeID ASC ) ;
