CREATE TABLE dbo.Contact (
    ContactID           INT             NOT NULL    IDENTITY
  , NamePrefix          VARCHAR (5)     NOT NULL    CONSTRAINT DF_Contact_NamePrefix DEFAULT ('')
  , FirstName           VARCHAR (50)    NOT NULL
  , LastName            VARCHAR (50)    NOT NULL
  , Title               VARCHAR (100)   NOT NULL    CONSTRAINT DF_Contact_Title            DEFAULT ('')
  , Department          VARCHAR (100)   NOT NULL    CONSTRAINT DF_Contact_Department       DEFAULT ('')
  , MailStop            VARCHAR (30)    NOT NULL    CONSTRAINT DF_Contact_ContactMailStop  DEFAULT ('')
  , OfficeTermEndDate   DATE            NULL
  , Phone               VARCHAR (15)    NOT NULL    CONSTRAINT DF_Contact_ContactPhone     DEFAULT ('')
  , Extension           VARCHAR (6)     NOT NULL    CONSTRAINT DF_Contact_ContactExtension DEFAULT ('')
  , Fax                 VARCHAR (15)    NOT NULL    CONSTRAINT DF_Contact_ContactFax       DEFAULT ('')
  , CellPhone           VARCHAR (15)    NOT NULL    CONSTRAINT DF_Contact_ContactCellPhone DEFAULT ('')
  , Email               VARCHAR (150)   NOT NULL    CONSTRAINT DF_Contact_ContactEmail     DEFAULT ('')
  , Notes               VARCHAR (200)   NOT NULL    CONSTRAINT DF_Contact_ContactNotes     DEFAULT ('')
  , Active              BIT             NOT NULL    CONSTRAINT DF_Contact_Active DEFAULT 1
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_Contact_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_Contact_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_Contact PRIMARY KEY CLUSTERED ( ContactID ASC )
) ;
GO

CREATE INDEX IX_Contact_FirstName_LastName ON dbo.Contact ( FirstName ASC, LastName ASC ) ;
GO

CREATE UNIQUE INDEX UX_Contact_Checksum ON dbo.Contact (
    ContactID ASC, NamePrefix ASC, FirstName ASC, LastName ASC
        , Title ASC, Department ASC, Phone ASC, Extension ASC, Fax ASC
        , CellPhone ASC, Email ASC, Notes ASC ) ;

