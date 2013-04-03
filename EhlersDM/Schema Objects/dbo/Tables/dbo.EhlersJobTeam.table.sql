CREATE TABLE dbo.EhlersJobTeam (
    EhlersJobTeamID     INT             NOT NULL    IDENTITY
  , Value               VARCHAR (100)   NOT NULL
  , DisplaySequence     INT             NOT NULL    CONSTRAINT DF_EhlersJobTeam_DisplaySequence DEFAULT ((0))
  , Active              BIT             NOT NULL    CONSTRAINT DF_EhlersJobTeam_Active DEFAULT ((1))
  , Description         VARCHAR (200)   NULL
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_EhlersJobTeam_ModifiedDate DEFAULT (getdate())
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_EhlersJobTeam_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , LegacyValue         VARCHAR (50)    NULL
  , CONSTRAINT PK_EhlersJobTeam PRIMARY KEY CLUSTERED ( EhlersJobTeamID ASC )
  , CONSTRAINT UX_EhlersJobTeam_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
