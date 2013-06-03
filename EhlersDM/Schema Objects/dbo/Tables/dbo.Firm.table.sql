CREATE TABLE dbo.Firm (
    FirmID        INT           NOT NULL    CONSTRAINT PK_Firm PRIMARY KEY CLUSTERED    IDENTITY
  , FirmName      VARCHAR (150) NOT NULL
  , ShortName     VARCHAR (50)  NOT NULL    CONSTRAINT DF_Firm_ShortName      DEFAULT ('')
  , Active        BIT           NOT NULL    CONSTRAINT DF_Firm_Active DEFAULT ((1))
  , FirmPhone     VARCHAR (15)  NOT NULL    CONSTRAINT DF_Firm_FirmPhone      DEFAULT ('')
  , FirmTollFree  VARCHAR (15)  NOT NULL    CONSTRAINT DF_Firm_FirmTollFree   DEFAULT ('')
  , FirmFax       VARCHAR (15)  NOT NULL    CONSTRAINT DF_Firm_FirmFax        DEFAULT ('')
  , FirmEmail     VARCHAR (150) NOT NULL    CONSTRAINT DF_Firm_FirmEmail      DEFAULT ('')
  , FirmWebSite   VARCHAR (150) NOT NULL    CONSTRAINT DF_Firm_FirmWebSite    DEFAULT ('')
  , FirmABANumber VARCHAR (12)  NOT NULL    CONSTRAINT DF_Firm_FirmABANumber  DEFAULT ('')
  , DTCAgent      VARCHAR (8)   NOT NULL    CONSTRAINT DF_Firm_DTCAgentNumber DEFAULT ('')
  , FirmNotes     VARCHAR (MAX) NOT NULL    CONSTRAINT DF_Firm_FirmNotes      DEFAULT ('')
  , GoodFaith     VARCHAR (MAX) NOT NULL    CONSTRAINT DF_Firm_GoodFaith      DEFAULT ('')
  , ParentFirmID  INT           NULL
  , ModifiedDate  DATETIME      NOT NULL    CONSTRAINT DF_Firm_ModifiedDate DEFAULT (getdate())
  , ModifiedUser  VARCHAR (20)  NOT NULL    CONSTRAINT DF_Firm_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  
  , CONSTRAINT FK_Firm_ParentFirmID FOREIGN KEY ( ParentFirmID ) REFERENCES dbo.Firm ( FirmID )
) ;
GO

CREATE NONCLUSTERED INDEX IX_Firm_FirmID ON dbo.Firm ( FirmID ASC ) ;
GO

CREATE NONCLUSTERED INDEX IX_Firm_FirmName ON dbo.Firm ( FirmName ASC ) ;
GO
