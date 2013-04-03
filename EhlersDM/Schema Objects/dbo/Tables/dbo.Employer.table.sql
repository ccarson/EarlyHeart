CREATE TABLE dbo.Employer (
    EmployerID          INT             NOT NULL    IDENTITY
  , EmployerDescription VARCHAR (200)   NOT NULL    CONSTRAINT DF_Employer_EmployerDescription  DEFAULT ('')
  , EmployerType        VARCHAR (20)    NOT NULL
  , EmployeeCount       INT             NOT NULL    CONSTRAINT DF_Employer_EmployeeCount        DEFAULT ((0))
  , EmployeeCountDate   DATE            NULL
  , EmployerStatus      CHAR (1)        NOT NULL
  , LastRequestDate     DATE            NULL
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_Employer_ModifiedDate DEFAULT (getdate())
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_Employer_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_Employer PRIMARY KEY CLUSTERED ( EmployerID ASC )
) ;
GO

CREATE INDEX IX_Employer_EmployerType ON dbo.Employer ( EmployerType ASC ) ;
