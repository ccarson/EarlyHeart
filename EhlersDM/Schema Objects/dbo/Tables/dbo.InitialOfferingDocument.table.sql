CREATE TABLE dbo.InitialOfferingDocument (
    InitialOfferingDocumentID INT           NOT NULL    IDENTITY
  , Value                     VARCHAR (100) NOT NULL
  , DisplaySequence           INT           NOT NULL    CONSTRAINT DF_InitialOfferingDocument_DisplaySequence DEFAULT 0
  , Active                    BIT           NOT NULL    CONSTRAINT DF_InitialOfferingDocument_Active DEFAULT 1
  , Description               VARCHAR (200) NULL
  , ModifiedDate              DATETIME      NOT NULL    CONSTRAINT DF_InitialOfferingDocument_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser              VARCHAR (20)  NOT NULL    CONSTRAINT DF_InitialOfferingDocument_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , LegacyValue               VARCHAR (50)  NULL
  , CONSTRAINT PK_InitialOfferingDocument PRIMARY KEY CLUSTERED ( InitialOfferingDocumentID ASC )
  , CONSTRAINT UX_InitialOfferingDocument_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
