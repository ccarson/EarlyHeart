CREATE TABLE dbo.DocumentType (
    DocumentTypeID  INT             NOT NULL    IDENTITY
  , Value           VARCHAR (100)   NOT NULL
  , DisplaySequence INT             NOT NULL    CONSTRAINT DF_DocumentType_DisplaySequence DEFAULT ((0))
  , Active          BIT             NOT NULL    CONSTRAINT DF_DocumentType_Active DEFAULT ((1))
  , Description     VARCHAR (200)   NULL
  , ModifiedDate    DATETIME        NOT NULL    CONSTRAINT DF_DocumentType_ModifiedDate DEFAULT (getdate())
  , ModifiedUser    VARCHAR (20)    NOT NULL    CONSTRAINT DF_DocumentType_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , LegacyValue     VARCHAR (50)    NULL
  , CONSTRAINT PK_DocumentType PRIMARY KEY CLUSTERED ( DocumentTypeID ASC )
  , CONSTRAINT UX_DocumentType_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
