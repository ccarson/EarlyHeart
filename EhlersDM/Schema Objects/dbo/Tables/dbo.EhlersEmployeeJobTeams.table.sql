CREATE TABLE dbo.EhlersEmployeeJobTeams (
    EhlersEmployeeJobTeamsID    INT             NOT NULL    IDENTITY
  , EhlersEmployeeID            INT             NOT NULL
  , EhlersJobTeamID             INT             NOT NULL
  , Active                      BIT             NOT NULL    CONSTRAINT DF_EhlersEmployeeJobTeams_Active DEFAULT 1
  , ModifiedDate                DATETIME        NOT NULL    CONSTRAINT DF_EhlersEmployeeJobTeams_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser                VARCHAR (20)    NOT NULL    CONSTRAINT DF_EhlersEmployeeJobTeams_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_EhlersEmployeeJobTeams PRIMARY KEY CLUSTERED ( EhlersEmployeeJobTeamsID ASC )
  , CONSTRAINT UX_EhlersEmployeeJobTeams_Unique UNIQUE NONCLUSTERED ( EhlersEmployeeID ASC, EhlersJobTeamID ASC )
  , CONSTRAINT FK_EhlersEmployeeJobTeams_EhlersEmployee
        FOREIGN KEY ( EhlersEmployeeID ) REFERENCES dbo.EhlersEmployee ( EhlersEmployeeID )
  , CONSTRAINT FK_EhlersEmployeeJobTeams_EhlersJobTeam
        FOREIGN KEY ( EhlersJobTeamID ) REFERENCES dbo.EhlersJobTeam ( EhlersJobTeamID )
) ;
