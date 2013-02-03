CREATE TABLE dbo.FirmNameHistory (
    FirmsHistoryID  INT             NOT NULL    IDENTITY
  , FirmID          INT             NOT NULL
  , FirmName        VARCHAR (150)   NOT NULL
  , ModifiedDate    DATETIME        NOT NULL    CONSTRAINT DF_FirmNameHistory_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser    VARCHAR (20)    NOT NULL    CONSTRAINT DF_FirmNameHistory_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_FirmsHistory PRIMARY KEY CLUSTERED ( FirmsHistoryID ASC )
  , CONSTRAINT FK_FirmsHistory_Firm
        FOREIGN KEY ( FirmID ) REFERENCES dbo.Firm ( FirmID )
) ;
GO

CREATE INDEX IX_FirmNameHistory_FirmID ON dbo.FirmNameHistory ( FirmID ASC ) ;
