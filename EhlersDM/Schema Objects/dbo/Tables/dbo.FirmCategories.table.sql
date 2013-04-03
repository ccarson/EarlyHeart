CREATE TABLE dbo.FirmCategories (
    FirmCategoriesID    INT             NOT NULL    IDENTITY
  , FirmID              INT             NOT NULL
  , FirmCategoryID      INT             NOT NULL
  , Active              BIT             NOT NULL    CONSTRAINT DF_FirmCategories_Active DEFAULT ((1))
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_FirmCategories_ModifiedDate DEFAULT (getdate())
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_FirmCategories_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_FirmCategories PRIMARY KEY CLUSTERED ( FirmCategoriesID ASC )
  , CONSTRAINT UX_FirmCategories UNIQUE NONCLUSTERED ( FirmCategoryID ASC, FirmID ASC )
  , CONSTRAINT FK_FirmCategories_Firm
        FOREIGN KEY ( FirmID ) REFERENCES dbo.Firm ( FirmID )
  , CONSTRAINT FK_FirmCategories_FirmCategory
        FOREIGN KEY ( FirmCategoryID ) REFERENCES dbo.FirmCategory ( FirmCategoryID )
) ;
GO

CREATE INDEX IX_FirmCategories_FirmID ON dbo.FirmCategories ( FirmID ASC ) ;
GO

CREATE INDEX IX_FirmCategories_FirmCategoryID ON dbo.FirmCategories ( FirmCategoryID ASC ) ;

