CREATE TABLE Documents.DocumentContent (
    DocumentContentID          INT           NOT NULL   IDENTITY
  , DocumentSectionID          INT           NOT NULL
  , DocumentContentDescription VARCHAR (200) NOT NULL
  , OrderWithinSection         SMALLINT      NOT NULL
  , Condition                  VARCHAR (MAX) NULL
  , Content                    VARCHAR (MAX) NOT NULL 
  , CONSTRAINT PK_DocumentContent PRIMARY KEY CLUSTERED ( DocumentContentID ASC )
) ; 
