CREATE TABLE dbo.ClientDemographic (
    ClientDemographicsID        INT             NOT NULL    IDENTITY
  , ClientID                    INT             NOT NULL
  , DemographicsYear            SMALLINT        NOT NULL
  , CensusPopulation            INT             NOT NULL    CONSTRAINT DF_ClientDemographic_CensusPopulation       DEFAULT ((0))
  , StateDemoPopulation         INT             NOT NULL    CONSTRAINT DF_ClientDemographic_StateDemoPopulation    DEFAULT ((0))
  , CurrentEstPopulation        INT             NOT NULL    CONSTRAINT DF_ClientDemographic_CurrentEstPopulation   DEFAULT ((0))
  , AverageIncome               DECIMAL (15, 2) NOT NULL    CONSTRAINT DF_ClientDemographic_AverageIncome          DEFAULT ((0.00))
  , NumberEmployed              INT             NOT NULL    CONSTRAINT DF_ClientDemographic_NumberEmployed         DEFAULT ((0))
  , UnemploymentPercent         REAL            NOT NULL    CONSTRAINT DF_ClientDemographic_UnemploymentPct        DEFAULT ((0))
  , TerritorySquareMiles        DECIMAL (16, 4) NOT NULL    CONSTRAINT DF_ClientDemographic_TerritorySqMiles       DEFAULT ((0.00))
  , TerritoryLandAcres          DECIMAL (16, 4) NOT NULL    CONSTRAINT DF_ClientDemographic_TerritoryLandAcres     DEFAULT ((0.00))
  , FullTimeEmployeeCount       INT             NOT NULL    CONSTRAINT DF_ClientDemographic_FullTimeEmployeeCount  DEFAULT ((0))
  , PartTimeEmployeeCount       INT             NOT NULL    CONSTRAINT DF_ClientDemographic_PartTimeEmployeeCount  DEFAULT ((0))
  , SeasonalEmployeeCount       INT             NOT NULL    CONSTRAINT DF_ClientDemographic_SeasonalEmployeeCnt    DEFAULT ((0))
  , NonLicensedEmployeeCount    INT             NOT NULL    CONSTRAINT DF_ClientDemographic_NonLicensedEmployeeCnt DEFAULT ((0))
  , LicensedEmployeeCount       INT             NOT NULL    CONSTRAINT DF_ClientDemographic_LicensedEmployeeCnt    DEFAULT ((0))
  , TeacherCount                INT             NOT NULL    CONSTRAINT DF_ClientDemographic_TeacherCount           DEFAULT ((0))
  , ModifiedDate                DATETIME        NOT NULL    CONSTRAINT DF_ClientDemographic_ModifiedDate DEFAULT (getdate())
  , ModifiedUser                VARCHAR (20)    NOT NULL    CONSTRAINT DF_ClientDemographic_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_ClientDemographic PRIMARY KEY CLUSTERED ( ClientDemographicsID ASC )
  , CONSTRAINT FK_ClientDemographic_Client
        FOREIGN KEY ( ClientID ) REFERENCES dbo.Client ( ClientID )
) ;
GO

CREATE INDEX IX_ClientDemographic_ClientID ON dbo.ClientDemographic ( ClientID ASC ) ;
