CREATE TABLE Documents.MergeFields (
    MergeFieldID      INT           NOT NULL    IDENTITY
  , DocumentSectionID INT           NOT NULL
  , FieldName         VARCHAR (50)  NOT NULL
  , FieldCode         VARCHAR (50)  NOT NULL
  , FieldDescription  VARCHAR (250) NULL
  , CONSTRAINT PK_MergeFields PRIMARY KEY CLUSTERED ( MergeFieldID ASC )
  , CONSTRAINT FK_MergeFields_DocumentSections 
        FOREIGN KEY ( DocumentSectionID ) REFERENCES Documents.DocumentSections ( DocumentSectionID ) 
) ;
