CREATE TABLE dbo.SchoolEnrollment (
    SchoolEnrollmentID     INT          NOT NULL    IDENTITY
  , ClientID               INT          NOT NULL
  , StartYear              SMALLINT     NOT NULL
  , EndYear                SMALLINT     NOT NULL
  , KindergartenEnrollment INT          NOT NULL    CONSTRAINT DF_SchoolEnrollment_KindergartenEnrollment   DEFAULT 0
  , ElementaryEnrollment   INT          NOT NULL    CONSTRAINT DF_SchoolEnrollment_ElementaryEnrollment     DEFAULT 0
  , SecondaryEnrollment    INT          NOT NULL    CONSTRAINT DF_SchoolEnrollment_SecondaryEnrollment      DEFAULT 0
  , ModifiedDate           DATETIME     NOT NULL    CONSTRAINT DF_SchoolEnrollment_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser           VARCHAR (20) NOT NULL    CONSTRAINT DF_SchoolEnrollment_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_SchoolEnrollment PRIMARY KEY CLUSTERED ( SchoolEnrollmentID ASC )
  , CONSTRAINT FK_SchoolEnrollment_Client
        FOREIGN KEY ( ClientID ) REFERENCES dbo.Client ( ClientID )
) ;
GO

CREATE INDEX IX_SchoolEnrollment_ClientID ON dbo.SchoolEnrollment ( ClientID ASC ) ;
