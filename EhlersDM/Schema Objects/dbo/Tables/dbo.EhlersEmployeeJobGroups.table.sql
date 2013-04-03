CREATE TABLE dbo.EhlersEmployeeJobGroups (
    EhlersEmployeeJobGroupsID   INT             NOT NULL    IDENTITY
  , EhlersEmployeeID            INT             NOT NULL
  , EhlersJobGroupID            INT             NOT NULL
  , Active                      BIT             NOT NULL    CONSTRAINT DF_EhlersEmployeeJobGroups_Active DEFAULT ((1))
  , ModifiedDate                DATETIME        NOT NULL    CONSTRAINT DF_EhlersEmployeeJobGroups_ModifiedDate DEFAULT (getdate())
  , ModifiedUser                VARCHAR (20)    NOT NULL    CONSTRAINT DF_EhlersEmployeeJobGroups_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_EhlersEmployeeJobGroups PRIMARY KEY CLUSTERED ( EhlersEmployeeJobGroupsID ASC )
  , CONSTRAINT UX_EhlersEmployeeJobGroups UNIQUE NONCLUSTERED ( EhlersEmployeeID ASC, EhlersJobGroupID ASC )
  , CONSTRAINT FK_EhlersEmployeeJobGroups_EhlersEmployee
        FOREIGN KEY ( EhlersEmployeeID ) REFERENCES dbo.EhlersEmployee ( EhlersEmployeeID )
  , CONSTRAINT FK_EhlersEmployeeJobGroups_EhlersJobGroup
        FOREIGN KEY ( EhlersJobGroupID ) REFERENCES dbo.EhlersJobGroup ( EhlersJobGroupID )
) ;
