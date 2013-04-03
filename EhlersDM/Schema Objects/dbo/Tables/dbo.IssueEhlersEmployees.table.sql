CREATE TABLE dbo.IssueEhlersEmployees (
    IssueEhlersEmployeesID    INT          NOT NULL IDENTITY
  , IssueID                   INT          NOT NULL
  , EhlersEmployeeJobGroupsID INT          NOT NULL
  , Ordinal                   INT          NOT NULL CONSTRAINT DF_IssueEhlersEmployees_ContactRoleID        DEFAULT ((0))
  , IsSaleDayAvailable        BIT          NOT NULL CONSTRAINT DF_IssueEhlersEmployees_IsSaleDayAvailable   DEFAULT ((0))
  , IsSaleDayAttending        BIT          NOT NULL CONSTRAINT DF_IssueEhlersEmployees_IsSaleDayAttending   DEFAULT ((0))
  , ModifiedDate              DATETIME     NOT NULL    CONSTRAINT DF_IssueEhlersEmployees_ModifiedDate DEFAULT (getdate())
  , ModifiedUser              VARCHAR (20) NOT NULL    CONSTRAINT DF_IssueEhlersEmployees_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_IssueEhlersEmployees PRIMARY KEY CLUSTERED ( IssueEhlersEmployeesID ASC )
  , CONSTRAINT FK_IssueEhlersEmployee_EhlersEmployeeJobGroups
        FOREIGN KEY ( EhlersEmployeeJobGroupsID ) REFERENCES dbo.EhlersEmployeeJobGroups ( EhlersEmployeeJobGroupsID )
  , CONSTRAINT FK_IssueEhlersEmployee_Issue
        FOREIGN KEY ( IssueID ) REFERENCES dbo.Issue ( IssueID )
) ;
GO

CREATE INDEX IX_IssueEhlersEmployees_IssueID ON dbo.IssueEhlersEmployees ( IssueID ASC ) ;
GO

CREATE UNIQUE NONCLUSTERED INDEX UX_IssueEhlersEmployees ON dbo.IssueEhlersEmployees
        ( IssueID ASC, EhlersEmployeeJobGroupsID ASC, Ordinal ASC ) INCLUDE ( IsSaleDayAvailable, IsSaleDayAttending ) ;
