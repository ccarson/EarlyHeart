CREATE TABLE dbo.ProjectServiceJobTeams (
    ProjectServiceJobTeamsID INT          NOT NULL  IDENTITY
  , ProjectServiceID         INT          NOT NULL
  , EhlersJobTeamID          INT          NOT NULL
  , Active                   BIT          NOT NULL  CONSTRAINT DF_ProjectServiceJobTeams_Active       DEFAULT 1
  , ModifiedDate             DATETIME     NOT NULL  CONSTRAINT DF_ProjectServiceJobTeams_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser             VARCHAR (20) NOT NULL  CONSTRAINT DF_ProjectServiceJobTeams_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_ProjectServiceJobTeams PRIMARY KEY CLUSTERED ( ProjectServiceJobTeamsID ASC )
  , CONSTRAINT UX_ProjectServiceJobTeams UNIQUE NONCLUSTERED (EhlersJobTeamID ASC, ProjectServiceID ASC )
  , CONSTRAINT FK_ProjectServiceJobTeams_EhlersJobTeam FOREIGN KEY ( EhlersJobTeamID ) REFERENCES dbo.EhlersJobTeam ( EhlersJobTeamID )
  , CONSTRAINT FK_ProjectServiceJobTeams_ProjectService FOREIGN KEY ( ProjectServiceID ) REFERENCES dbo.ProjectService ( ProjectServiceID )
) ;
