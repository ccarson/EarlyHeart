CREATE TABLE dbo.SchoolBuilding (
    SchoolBuildingID        INT           NOT NULL  --IDENTITY ??
  , ClientID                INT           NOT NULL
  , BuildingName            VARCHAR (100) NOT NULL
  , BuildingYearConstructed SMALLINT      NULL
  , BuildingYearRemodeled   SMALLINT      NULL
  , BuildingCapacity        INT           NOT NULL  CONSTRAINT DF_SchoolBuilding_BuildingCapacity    DEFAULT 0
  , BuildingEnrollment      INT           NOT NULL  CONSTRAINT DF_SchoolBuilding_BuildingEnrollment  DEFAULT 0
  , ModifiedDate            DATETIME      NOT NULL    CONSTRAINT DF_SchoolBuilding_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser            VARCHAR (20)  NOT NULL    CONSTRAINT DF_SchoolBuilding_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_SchoolBuilding PRIMARY KEY CLUSTERED ( SchoolBuildingID ASC )
  , CONSTRAINT FK_SchoolBuilding_Client
        FOREIGN KEY ( ClientID ) REFERENCES dbo.Client ( ClientID )
) ;
GO

CREATE INDEX IX_SchoolBuilding_ClientID ON dbo.SchoolBuilding ( ClientID ASC ) ;
