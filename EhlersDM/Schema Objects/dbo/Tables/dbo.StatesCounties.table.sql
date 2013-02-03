CREATE TABLE dbo.StatesCounties (
    StatesCountiesID INT          NOT NULL  IDENTITY
  , CountyID         INT          NOT NULL
  , StatesID         INT          NOT NULL
  , OldKeyID         VARCHAR (20) NULL
  , CONSTRAINT PK_StatesCounties PRIMARY KEY CLUSTERED ( StatesCountiesID ASC )
  , CONSTRAINT UX_StatesCounties UNIQUE NONCLUSTERED ( CountyID ASC, StatesID ASC )
  , CONSTRAINT FK_StatesCounties_County
        FOREIGN KEY ( CountyID ) REFERENCES dbo.County ( CountyID )
  , CONSTRAINT FK_StatesCounties_States
        FOREIGN KEY ( StatesID ) REFERENCES dbo.States ( StatesID )
) ;
