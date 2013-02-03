CREATE TABLE Documents.Documents (
    DocumentID   INT           NOT NULL IDENTITY
  , DocumentName VARCHAR (200) NOT NULL 
  , CONSTRAINT PK_Documents PRIMARY KEY CLUSTERED ( DocumentID ASC ) 
) ;
