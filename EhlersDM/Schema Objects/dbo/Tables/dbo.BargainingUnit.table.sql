CREATE TABLE dbo.BargainingUnit (
    BargainingUnitID   INT           NOT NULL
  , ClientID           INT           NOT NULL
  , BargainingUnitName VARCHAR (150) NOT NULL
  , ContractEndDate    DATE          NOT NULL
  , ContractStatusID   INT           NULL
  , Litigation         BIT           NOT NULL   CONSTRAINT DF_BargainingUnit_LitigationInd DEFAULT 0
  , ModifiedDate       DATETIME      NOT NULL    CONSTRAINT DF_BargainingUnit_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser       VARCHAR (20)  NOT NULL    CONSTRAINT DF_BargainingUnit_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_BargainingUnit PRIMARY KEY CLUSTERED ( BargainingUnitID ASC )
  , CONSTRAINT FK_BargainingUnit_Client
        FOREIGN KEY ( ClientID ) REFERENCES dbo.Client ( ClientID )
) ;
GO

CREATE INDEX IX_BargainingUnit_ClientID ON dbo.BargainingUnit ( ClientID ASC ) ;
