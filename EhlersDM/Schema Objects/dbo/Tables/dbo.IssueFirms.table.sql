CREATE TABLE dbo.IssueFirms (
    IssueFirmsID     INT          NOT NULL  CONSTRAINT PK_IssueFirms PRIMARY KEY CLUSTERED IDENTITY
  , IssueID          INT          NOT NULL
  , FirmCategoriesID INT          NOT NULL
  , Ordinal          INT          NOT NULL  CONSTRAINT DF_IssueFirms_Ordinal        DEFAULT ((1))
  , ModifiedDate     DATETIME     NOT NULL  CONSTRAINT DF_IssueFirms_ModifiedDate   DEFAULT (getdate())
  , ModifiedUser     VARCHAR (20) NOT NULL  CONSTRAINT DF_IssueFirms_ModifiedUser   DEFAULT ([dbo].[udf_GetSystemUser]())

  , CONSTRAINT FK_IssueFirms_FirmCategories
        FOREIGN KEY ( FirmCategoriesID ) REFERENCES dbo.FirmCategories ( FirmCategoriesID )
  , CONSTRAINT FK_IssueFirms_Issue
        FOREIGN KEY ( IssueID ) REFERENCES dbo.Issue ( IssueID )
);
GO

CREATE INDEX IX_IssueFirms_IssueID ON dbo.IssueFirms ( IssueID ASC ) ;
GO

CREATE UNIQUE NONCLUSTERED INDEX UX_IssueFirms
    ON dbo.IssueFirms( FirmCategoriesID ASC, IssueID ASC, Ordinal ASC ) ;
