CREATE TABLE dbo.DocumentParagraph (
    DocumentParagraphID INT           NOT NULL  IDENTITY
  , Category            VARCHAR (50)  NOT NULL
  , Subcategory         VARCHAR (50)  NULL
  , Description         VARCHAR (50)  NOT NULL
  , FilePath            VARCHAR (150) NOT NULL
  , CONSTRAINT PK_DocumentParagraph PRIMARY KEY CLUSTERED ( DocumentParagraphID ASC )
) ;