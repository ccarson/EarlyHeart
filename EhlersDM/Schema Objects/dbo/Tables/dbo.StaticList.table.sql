CREATE TABLE dbo.StaticList (
    StaticListID    INT           NOT NULL  IDENTITY
  , ListCategoryID  INT           NOT NULL
  , DisplayValue    VARCHAR (100) NOT NULL
  , DisplaySequence INT           NOT NULL    CONSTRAINT DF_StaticList_DisplaySequence DEFAULT 0
  , Description     VARCHAR (100) NOT NULL  CONSTRAINT DF_StaticList_Description    DEFAULT ('')
  , Active          BIT           NOT NULL    CONSTRAINT DF_StaticList_Active DEFAULT 1
  , OldKey          VARCHAR (20)  NULL
  , OldListValue    VARCHAR (10)  NULL      CONSTRAINT DF_StaticList_OldListValue   DEFAULT ('')
  , ModifiedDate    DATETIME      NOT NULL    CONSTRAINT DF_StaticList_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser    VARCHAR (20)  NOT NULL    CONSTRAINT DF_StaticList_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_StaticList PRIMARY KEY CLUSTERED ( StaticListID ASC )
  , CONSTRAINT FK_StaticList_ListCategory
        FOREIGN KEY ( ListCategoryID ) REFERENCES dbo.ListCategory ( ListCategoryID )
) ;
GO

CREATE INDEX IX_StaticList_ListCategoryID ON dbo.StaticList ( ListCategoryID ASC ) ;
