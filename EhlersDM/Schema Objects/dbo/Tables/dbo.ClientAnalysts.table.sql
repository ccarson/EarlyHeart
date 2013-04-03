CREATE TABLE dbo.ClientAnalysts (
    ClientAnalystsID            INT             NOT NULL    IDENTITY
  , ClientID                    INT             NOT NULL
  , EhlersEmployeeJobGroupsID   INT             NOT NULL
  , Ordinal                     INT             NOT NULL    CONSTRAINT DF_ClientAnalysts_Ordinal DEFAULT ((0))
  , ModifiedDate                DATETIME        NOT NULL    CONSTRAINT DF_ClientAnalysts_ModifiedDate DEFAULT (getdate())
  , ModifiedUser                VARCHAR (20)    NOT NULL    CONSTRAINT DF_ClientAnalysts_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_ClientAnalysts PRIMARY KEY CLUSTERED ( ClientAnalystsID ASC )
  , CONSTRAINT FK_ClientAnalysts_Client
        FOREIGN KEY ( ClientID ) REFERENCES dbo.Client ( ClientID )
  , CONSTRAINT FK_ClientAnalysts_EhlersEmployeeJobGroups
        FOREIGN KEY ( EhlersEmployeeJobGroupsID ) REFERENCES dbo.EhlersEmployeeJobGroups ( EhlersEmployeeJobGroupsID )
) ;
GO

CREATE INDEX IX_ClientAnalysts_ClientID_EmployeeID ON dbo.ClientAnalysts ( ClientID ASC, EhlersEmployeeJobGroupsID ASC ) ;
GO

CREATE INDEX IX_ClientAnalysts_ClientID ON dbo.ClientAnalysts ( ClientID ASC ) ;
GO

CREATE INDEX IX_ClientAnalysts_EhlersEmployeeJobGroupsID ON dbo.ClientAnalysts ( EhlersEmployeeJobGroupsID ASC ) ;
