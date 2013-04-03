CREATE TABLE dbo.ClientDocumentName (
    ClientDocumentNameID    INT             NOT NULL    IDENTITY
  , Value                   VARCHAR (100)   NOT NULL
  , DisplaySequence         INT             NOT NULL    CONSTRAINT DF_ClientDocumentName_DisplaySequence DEFAULT ((0))
  , Active                  BIT             NOT NULL    CONSTRAINT DF_ClientDocumentName_Active DEFAULT ((1))
  , Description             VARCHAR (200)   NULL
  , ClientDocumentTypeID    INT             NOT NULL
  , ModifiedDate            DATETIME        NOT NULL    CONSTRAINT DF_ClientDocumentName_ModifiedDate DEFAULT (getdate())
  , ModifiedUser            VARCHAR (20)    NOT NULL    CONSTRAINT DF_ClientDocumentName_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , LegacyValue             VARCHAR (50)    NULL
  , CONSTRAINT PK_ClientDocumentName PRIMARY KEY CLUSTERED ( ClientDocumentNameID ASC )
  , CONSTRAINT UX_ClientDocumentName_Value UNIQUE NONCLUSTERED ( Value ASC )
  , CONSTRAINT FK_ClientDocumentName_ClientDocumentType
        FOREIGN KEY ( ClientDocumentTypeID ) REFERENCES dbo.ClientDocumentType ( ClientDocumentTypeID )
) ;
