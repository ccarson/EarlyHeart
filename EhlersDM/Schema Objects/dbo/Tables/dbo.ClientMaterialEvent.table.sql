CREATE TABLE dbo.ClientMaterialEvent (
    ClientMaterialEventID   INT             NOT NULL    IDENTITY
  , ClientID                INT             NOT NULL
  , MaterialEventTypeID     INT             NULL
  , EMMASubmitDate          DATE            NULL
  , Invoicing               VARCHAR (100)   NULL
  , OtherText               VARCHAR (50)    NULL
  
  , ModifiedDate            DATETIME        NOT NULL    CONSTRAINT DF_ClientMaterialEvent_ModifiedDate DEFAULT (getdate())
  , ModifiedUser            VARCHAR (20)    NOT NULL    CONSTRAINT DF_ClientMaterialEvent_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_ClientMaterialEvent PRIMARY KEY CLUSTERED ( ClientMaterialEventID ASC )
  , CONSTRAINT FK_ClientMaterialEvent_Client
        FOREIGN KEY ( ClientID ) REFERENCES dbo.Client ( ClientID )
  , CONSTRAINT FK_ClientMaterialEvent_MaterialEventType
        FOREIGN KEY ( MaterialEventTypeID ) REFERENCES dbo.MaterialEventType ( MaterialEventTypeID )
) ;
GO

CREATE INDEX IX_ClientMaterialEvent_ClientID ON dbo.ClientMaterialEvent ( ClientID ASC ) ;
