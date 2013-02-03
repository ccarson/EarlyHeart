CREATE TABLE dbo.ClientDocumentType (
    ClientDocumentTypeID    INT             NOT NULL    IDENTITY
  , Value                   VARCHAR (100)   NOT NULL
  , DisplaySequence         INT             NOT NULL    CONSTRAINT DF_ClientDocumentType_DisplaySequence DEFAULT 0
  , Active                  BIT             NOT NULL    CONSTRAINT DF_ClientDocumentType_Active DEFAULT 1
  , Description             VARCHAR (200)   NULL
  , MaxDocuments            INT             NOT NULL    CONSTRAINT DF_ClientDocumentType_MaxDocuments       DEFAULT 1
  , ModifiedDate            DATETIME        NOT NULL    CONSTRAINT DF_ClientDocumentType_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser            VARCHAR (20)    NOT NULL    CONSTRAINT DF_ClientDocumentType_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , LegacyValue             VARCHAR (50)    NULL
  , CONSTRAINT PK_ClientDocumentType PRIMARY KEY CLUSTERED ( ClientDocumentTypeID ASC )
  , CONSTRAINT UX_ClientDocumentType_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
