CREATE TABLE dbo.IssueMaturity (
    IssueMaturityID             INT             NOT NULL    IDENTITY
  , IssueID                     INT             NOT NULL
  , InsuranceFirmCategoriesID   INT             NULL
  , LegacyInsuranceCode         VARCHAR (10)    NOT NULL    CONSTRAINT DF_IssueMaturity_LegacyInsuranceFirm DEFAULT ('')
  , PaymentDate                 DATE            NOT NULL
  , Cusip3                      VARCHAR (3)     NOT NULL    CONSTRAINT DF_IssueMaturity_Cusip3              DEFAULT ('')
  , RefundedCusip               VARCHAR (3)     NOT NULL    CONSTRAINT DF_IssueMaturity_RefundedCusip       DEFAULT ('')
  , UnrefundedCusip             VARCHAR (3)     NOT NULL    CONSTRAINT DF_IssueMaturity_UnrefundedCusip     DEFAULT ('')
  , InterestRate                DECIMAL (7, 4)  NOT NULL    CONSTRAINT DF_IssueMaturity_InterestRate        DEFAULT 0
  , Term                        SMALLINT        NOT NULL    CONSTRAINT DF_IssueMaturity_BondTerm            DEFAULT 0
  , PriceToCall                 BIT             NOT NULL    CONSTRAINT DF_IssueMaturity_PriceToCall         DEFAULT 0
  , ReofferingYield             DECIMAL (7, 4)  NOT NULL    CONSTRAINT DF_IssueMaturity_ReofferingYield     DEFAULT 0
  , NotReoffered                BIT             NOT NULL    CONSTRAINT DF_IssueMaturity_NotReoffered        DEFAULT 0
  , ModifiedDate                DATETIME        NOT NULL    CONSTRAINT DF_IssueMaturity_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser                VARCHAR (20)    NOT NULL    CONSTRAINT DF_IssueMaturity_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_IssueMaturity PRIMARY KEY CLUSTERED ( IssueMaturityID ASC )
  , CONSTRAINT FK_IssueMaturity_FirmCategories
        FOREIGN KEY ( InsuranceFirmCategoriesID ) REFERENCES dbo.FirmCategories ( FirmCategoriesID )
  , CONSTRAINT FK_IssueMaturity_Issue
        FOREIGN KEY ( IssueID ) REFERENCES dbo.Issue ( IssueID )
) ;
GO

CREATE INDEX IX_IssueMaturity_IssueID ON dbo.IssueMaturity ( IssueID ASC ) ;
