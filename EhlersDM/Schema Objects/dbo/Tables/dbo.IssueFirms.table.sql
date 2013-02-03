CREATE TABLE dbo.IssueFirms (
    IssueFirmsID     INT          NOT NULL  IDENTITY
  , IssueID          INT          NOT NULL
  , FirmCategoriesID INT          NOT NULL
  , ModifiedDate     DATETIME     NOT NULL    CONSTRAINT DF_IssueFirms_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser     VARCHAR (20) NOT NULL    CONSTRAINT DF_IssueFirms_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_IssueFirms PRIMARY KEY CLUSTERED ( IssueFirmsID ASC )
  , CONSTRAINT FK_IssueFirms_FirmCategories
        FOREIGN KEY ( FirmCategoriesID ) REFERENCES dbo.FirmCategories ( FirmCategoriesID )
  , CONSTRAINT FK_IssueFirms_Issue
        FOREIGN KEY ( IssueID ) REFERENCES dbo.Issue ( IssueID )
) ;
GO

CREATE INDEX IX_IssueFirms_IssueID ON dbo.IssueFirms ( IssueID ASC ) ;
GO

CREATE UNIQUE NONCLUSTERED INDEX UX_IssueFirms ON dbo.IssueFirms ( FirmCategoriesID ASC, IssueID ASC ) ;
