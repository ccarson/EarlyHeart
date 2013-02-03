CREATE TABLE dbo.ListCategory (
    ListCategoryID INT           NOT NULL   IDENTITY
  , CategoryName   VARCHAR (50)  NOT NULL
  , Information    VARCHAR (MAX) NOT NULL   CONSTRAINT DF_ListCategory_Information DEFAULT ('')
  , CONSTRAINT PK_ListCategory PRIMARY KEY CLUSTERED ( ListCategoryID ASC )
  , CONSTRAINT UX_ListCategory_CategoryName UNIQUE NONCLUSTERED ( CategoryName ASC )
) ;
