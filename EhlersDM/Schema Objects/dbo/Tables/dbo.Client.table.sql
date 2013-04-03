CREATE TABLE dbo.Client (
    ClientID                INT             NOT NULL    IDENTITY
  , ClientLinkID            INT             NULL
  , ClientName              VARCHAR (100)   NOT NULL
  , ClientPrefixID          INT             NULL
  , SchoolDistrictNumber    VARCHAR (6)     NOT NULL    CONSTRAINT DF_Client_SchoolDistrictNumber       DEFAULT ('')
  , InformalName            VARCHAR (100)   NOT NULL    CONSTRAINT DF_Client_ShortName                  DEFAULT ('')
  , ClientStatusID          INT             NULL
  , StatusChangeDate        DATE            NULL
  , Phone                   VARCHAR (15)    NOT NULL    CONSTRAINT DF_Client_ClientPhone                DEFAULT ('')
  , TollFreePhone           VARCHAR (15)    NOT NULL    CONSTRAINT DF_Client_ClientTollFreePhone        DEFAULT ('')
  , Fax                     VARCHAR (15)    NOT NULL    CONSTRAINT DF_Client_ClientFax                  DEFAULT ('')
  , Email                   VARCHAR (150)   NOT NULL    CONSTRAINT DF_Client_ClientEmail                DEFAULT ('')
  , TaxID                   CHAR (10)       NOT NULL    CONSTRAINT DF_Client_ClientTaxID                DEFAULT ('')
  , FiscalYearEnd           CHAR (5)        NOT NULL    CONSTRAINT DF_Client_ClientFiscalYearEnd        DEFAULT ('')
  , JurisdictionTypeID      INT             NULL
  , JurisdictionTypeOS      VARCHAR (100)   NOT NULL    CONSTRAINT DF_Client_JurisdictionTypeOS         DEFAULT ('')
  , GoverningBoardID        INT             NULL
  , WebSite                 VARCHAR (150)   NOT NULL    CONSTRAINT DF_Client_ClientWebSite              DEFAULT ('')
  , Newspaper               VARCHAR (150)   NOT NULL    CONSTRAINT DF_Client_ClientNewspaper            DEFAULT ('')
  , Logo                    VARCHAR (300)   NOT NULL    CONSTRAINT DF_Client_Logo                       DEFAULT ('')
  , GovBoardMeetingSchedule VARCHAR (50)    NOT NULL    CONSTRAINT DF_Client_GovBoardMeetSched          DEFAULT ('')
  , GovBoardMeetingTime     TIME (7)        NULL
  , GovBoardMeetingLocation VARCHAR (50)    NOT NULL    CONSTRAINT DF_Client_GovBoardMeetLoc            DEFAULT ('')
  , QuickBookName           VARCHAR (50)    NOT NULL    CONSTRAINT DF_Client_QuickBookName              DEFAULT ('')
  , EhlersJobTeamID         INT             NULL        CONSTRAINT DF_Client_EhlersJobTeamID            DEFAULT ((0))
  , MSAID                   INT             NULL
  , RedemptionAgentNumber   VARCHAR (16)    NOT NULL    CONSTRAINT DF_Client_DTCAgentNumber             DEFAULT ('')
  , DateIncorporated        VARCHAR (20)    NOT NULL    CONSTRAINT DF_Client_IncorporatedDate           DEFAULT ('')
  , FormOfGovernmentID      INT             NULL
  , Population              INT             NOT NULL    CONSTRAINT DF_Client_Population                 DEFAULT ((0))
  , PopulationDate          DATE            NULL
  , NumberOfEmployees       INT             NOT NULL    CONSTRAINT DF_Client_NumberOfEmployees          DEFAULT ((0))
  , NumberOfEmployeesDate   DATE            NULL
  , Census2000              INT             NOT NULL    CONSTRAINT DF_Client_Census2000                 DEFAULT ((0))
  , Census2010              INT             NOT NULL    CONSTRAINT DF_Client_Census2010                 DEFAULT ((0))
  , MayorVote               VARCHAR (100)   NOT NULL    CONSTRAINT DF_Client_MayorTieBreak              DEFAULT ('')
  , QualifyForDSE           BIT             NOT NULL    CONSTRAINT DF_Client_ClientDebtServiceEqual     DEFAULT ((0))
  , JurisdictionSquareMiles NUMERIC (8, 2)  NOT NULL    CONSTRAINT DF_Client_JurisdictionSquareMiles    DEFAULT ((0.0))
  , HomeRuleCharter         BIT             NOT NULL    CONSTRAINT DF_Client_HomeRuleCharter            DEFAULT ((0))
  , HomeRuleAmend           BIT             NOT NULL    CONSTRAINT DF_Client_HomeRuleAmend              DEFAULT ((0))
  , HomeRuleAmendDate       DATE            NULL
  , Notes                   VARCHAR (MAX)   NOT NULL    CONSTRAINT DF_Client_Notes                      DEFAULT ('')
  , DisclosureContractType  VARCHAR (100)   NOT NULL    CONSTRAINT DF_Client_DisclosureContractType     DEFAULT ('')
  , ContractBillingType     VARCHAR (100)   NOT NULL    CONSTRAINT DF_Client_ContractBillingType        DEFAULT ('')
  , CapitalLoanDistrict     BIT             NOT NULL    CONSTRAINT DF_Client_CapitalLoanDistrict        DEFAULT ((0))
  , ModifiedDate            DATETIME        NOT NULL    CONSTRAINT DF_Client_ModifiedDate DEFAULT (getdate())
  , ModifiedUser            VARCHAR (20)    NOT NULL    CONSTRAINT DF_Client_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_Client PRIMARY KEY CLUSTERED ( ClientID ASC )
  , CONSTRAINT FK_Client_ClientPrefix
        FOREIGN KEY ( ClientPrefixID ) REFERENCES dbo.ClientPrefix ( ClientPrefixID )
  , CONSTRAINT FK_Client_ClientStatus
        FOREIGN KEY ( ClientStatusID ) REFERENCES dbo.ClientStatus ( ClientStatusID )
  , CONSTRAINT FK_Client_EhlersJobTeam
        FOREIGN KEY ( EhlersJobTeamID ) REFERENCES dbo.EhlersJobTeam ( EhlersJobTeamID )
  , CONSTRAINT FK_Client_FormOfGovernment
        FOREIGN KEY ( FormOfGovernmentID ) REFERENCES dbo.FormOfGovernment ( FormOfGovernmentID )
  , CONSTRAINT FK_Client_GoverningBoard
        FOREIGN KEY ( GoverningBoardID ) REFERENCES dbo.GoverningBoard ( GoverningBoardID )
  , CONSTRAINT FK_Client_JurisdictionType
        FOREIGN KEY ( JurisdictionTypeID ) REFERENCES dbo.JurisdictionType ( JurisdictionTypeID )
) ;
GO

CREATE INDEX IX_Client_ClientName ON dbo.Client ( ClientName ASC ) ;
