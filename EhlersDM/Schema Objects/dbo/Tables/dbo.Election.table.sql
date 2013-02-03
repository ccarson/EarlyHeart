CREATE TABLE dbo.Election (
    ElectionID      INT             NOT NULL    IDENTITY
  , ClientID        INT             NOT NULL
  , ElectionTypeID  INT             NULL
  , ElectionDate    DATE            NOT NULL
  , ElectionAmount  DECIMAL (15, 2) NOT NULL    CONSTRAINT DF_Election_ElectionAmount   DEFAULT 0.00
  , YesVotes        INT             NOT NULL    CONSTRAINT DF_Election_YesVotes         DEFAULT 0
  , NoVotes         INT             NOT NULL    CONSTRAINT DF_Election_NoVotes          DEFAULT 0
  , Description     VARCHAR (100)   NOT NULL    CONSTRAINT DF_Election_Description      DEFAULT ('')
  , ModifiedDate    DATETIME        NOT NULL    CONSTRAINT DF_Election_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser    VARCHAR (20)    NOT NULL    CONSTRAINT DF_Election_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_Election PRIMARY KEY CLUSTERED ( ElectionID ASC )
  , CONSTRAINT FK_Election_Client
        FOREIGN KEY ( ClientID ) REFERENCES dbo.Client ( ClientID )
  , CONSTRAINT FK_Election_ElectionType
       FOREIGN KEY ( ElectionTypeID ) REFERENCES dbo.ElectionType ( ElectionTypeID )
) ;
GO

CREATE INDEX IX_Election_ClientID ON dbo.Election ( ClientID ASC ) ;
