CREATE TABLE dbo.EhlersEmployee (
    EhlersEmployeeID    INT             NOT NULL    IDENTITY
  , FirstName           VARCHAR (50)    NOT NULL
  , LastName            VARCHAR (50)    NOT NULL
  , MiddleInitial       VARCHAR (50)    NOT NULL    CONSTRAINT DF_EhlersEmployee_MiddleInitial  DEFAULT ('')
  , Initials            VARCHAR (50)    NOT NULL    CONSTRAINT DF_EhlersEmployee_Initials       DEFAULT ('')
  , Active              BIT             NOT NULL    CONSTRAINT DF_EhlersEmployee_Active DEFAULT ((1))
  , EhlersOfficeID      INT             NULL
  , Phone               VARCHAR (15)    NOT NULL    CONSTRAINT DF_EhlersEmployee_Phone          DEFAULT ('')
  , CellPhone           VARCHAR (15)    NOT NULL    CONSTRAINT DF_EhlersEmployee_CellPhone      DEFAULT ('')
  , Fax                 VARCHAR (15)    NULL
  , Email               VARCHAR (150)   NOT NULL    CONSTRAINT DF_EhlersEmployee_Email          DEFAULT ('')
  , JobTitle            VARCHAR (200)   NOT NULL    CONSTRAINT DF_EhlersEmployee_JobTitle       DEFAULT ('')
  , OfficerTitle        VARCHAR (100)   NOT NULL    CONSTRAINT DF_EhlersEmployee_OfficerTitle   DEFAULT ('')
  , BillRate            DECIMAL (15, 2) NOT NULL    CONSTRAINT DF_EhlersEmployee_BillRate       DEFAULT ((0.00))
  , BaseRate            DECIMAL (15, 2) NOT NULL    CONSTRAINT DF_EhlersEmployee_BaseRate       DEFAULT ((0.00))
  , Biography           VARCHAR (MAX)   NOT NULL    CONSTRAINT DF_EhlersEmployee_Biography      DEFAULT ('')
  , Education           VARCHAR (MAX)   NOT NULL    CONSTRAINT DF_EhlersEmployee_Education      DEFAULT ('')
  , HireDate            DATE            NOT NULL
  , Waiver              BIT             NOT NULL    CONSTRAINT DF_EhlersEmployee_Waiver         DEFAULT ((1))
  , PictureWaiver       BIT             NOT NULL    CONSTRAINT DF_EhlersEmployee_PictureWaiver  DEFAULT ((1))
  , CIPFACertified      BIT             NOT NULL    CONSTRAINT DF_EhlersEmployee_CIPFACertified DEFAULT ((1))
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_EhlersEmployee_ModifiedDate DEFAULT (getdate())
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_EhlersEmployee_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_EhlersEmployee PRIMARY KEY CLUSTERED ( EhlersEmployeeID ASC )
  , CONSTRAINT FK_EhlersEmployee_EhlersOffice
        FOREIGN KEY ( EhlersOfficeID ) REFERENCES dbo.EhlersOffice ( EhlersOfficeID )
) ;
GO

CREATE INDEX IX_EhlersEmployee_1 ON dbo.EhlersEmployee ( FirstName ASC, LastName ASC ) ;
