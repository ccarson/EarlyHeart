CREATE TABLE Documents.DocumentSections (
    DocumentSectionID      INT            NOT NULL  IDENTITY
  , DocumentID             INT            NOT NULL
  , DocumentSectionName    VARCHAR (50)   NOT NULL
  , DocumentSectionCode    VARCHAR (50)   NOT NULL
  , SectionStoredProcedure VARCHAR (2000) NULL
  , DocumentPath           VARCHAR (2000) NULL 
  , CONSTRAINT PK_DocumentSections PRIMARY KEY CLUSTERED ( DocumentSectionID ASC )
  , CONSTRAINT FK_DocumentSections_Documents
        FOREIGN KEY ( DocumentID ) REFERENCES Documents.Documents ( DocumentID )
) ; 
