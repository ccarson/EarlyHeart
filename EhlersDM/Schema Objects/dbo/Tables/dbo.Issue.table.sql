CREATE TABLE dbo.Issue (
    IssueID                         INT             NOT NULL    CONSTRAINT PK_Issue PRIMARY KEY CLUSTERED       IDENTITY
  , ClientID                        INT             NOT NULL
  , IssueName                       VARCHAR (150)   NOT NULL
  , IssueAmount                     DECIMAL (15, 2) NOT NULL
  , IssueShortNameID                INT             NULL
  , IssueShortNameOS                VARCHAR (100)   NOT NULL    CONSTRAINT DF_Issue_IssueShortNameOS             DEFAULT ('')
  , DatedDate                       DATE            NULL
  , IssueStatusID                   INT             NULL
  , IssueTypeID                     INT             NULL        CONSTRAINT DF_Issue_IssueTypeListID              DEFAULT ((0))
  , MethodOfSaleID                  INT             NULL
  , SecurityTypeID                  INT             NULL
  , BondFormTypeID                  INT             NULL
  , InitialOfferingDocumentID       INT             NULL
  , TaxStatus                       VARCHAR (20)    NOT NULL    CONSTRAINT DF_Issue_TaxStatus                    DEFAULT ('')
  , PrivateActBond                  BIT             NOT NULL    CONSTRAINT DF_Issue_PrivateActBond               DEFAULT ((0))
  , Bond501C3                       BIT             NOT NULL    CONSTRAINT DF_Issue_Bond501C3                    DEFAULT ((0))
  , Cusip6                          VARCHAR (6)     NULL        CONSTRAINT DF_Issue_Cusip6                       DEFAULT ('')
  , BankQualified                   BIT             NOT NULL    CONSTRAINT DF_Issue_BankQualified                DEFAULT ((1))
  , Callable                        BIT             NOT NULL    CONSTRAINT DF_Issue_Callable                     DEFAULT ((1))
  , CallFrequencyID                 INT             NULL
  , SaleDate                        DATE            NULL
  , SaleTime                        TIME (7)        NULL
  , SettlementDate                  DATE            NULL
  , OSPrintDate                     DATE            NULL
  , AnticipationCertificate         VARCHAR (50)    NOT NULL    CONSTRAINT DF_Issue_AnticipationCertificate      DEFAULT ('')
  , InterestPaymentFreqID           INT             NULL        CONSTRAINT DF_Issue_InterestPaymentFreqID        DEFAULT ((5))
  , InterestCalcMethodID            INT             NULL        CONSTRAINT DF_Issue_InterestCalcMethodID         DEFAULT ((1))
  , InterestTypeID                  INT             NULL        CONSTRAINT DF_Issue_InterestTypeID               DEFAULT ((1))
  , FirstInterestDate               DATE            NULL
  , DebtServiceYear                 VARCHAR (50)    NOT NULL    CONSTRAINT DF_Issue_DebtServiceYear              DEFAULT ('')
  , PurchasePrice                   DECIMAL (15, 2) NOT NULL    CONSTRAINT DF_Issue_PurchasePrice                DEFAULT ((0.00))
  , ArbitrageYield                  DECIMAL (11, 8) NOT NULL    CONSTRAINT DF_Issue_ArbitrageYield               DEFAULT ((0.00))
  , QualifiedForDebtServiceEqual    BIT             NOT NULL    CONSTRAINT DF_Issue_QualifiedForDebtServiceEqual DEFAULT ((0))
  , GoodFaithPercent                INT             NOT NULL    CONSTRAINT DF_Issue_GoodFaithPercent             DEFAULT ((0))
  , QCDate                          DATETIME        NULL
  , ShortDescription                VARCHAR (200)   NOT NULL    CONSTRAINT DF_Issue_ShortDescription             DEFAULT ('')
  , LongDescription                 VARCHAR (MAX)   NOT NULL    CONSTRAINT DF_Issue_LongDescription              DEFAULT ('')
  , IsTargetList                    BIT             NOT NULL    CONSTRAINT DF_Issue_IsTargetList                 DEFAULT ((0))
  , RefundedByNote                  VARCHAR (MAX)   NOT NULL    CONSTRAINT DF_Issue_RefundedByNote               DEFAULT ('')
  , RefundsNote                     VARCHAR (MAX)   NOT NULL    CONSTRAINT DF_Issue_RefundsNote                  DEFAULT ('')
  , DisclosureTypeID                INT             NULL        CONSTRAINT DF_Issue_DisclosureTypeID             DEFAULT ((0))
  , IsEIPInvest                     BIT             NOT NULL    CONSTRAINT DF_Issue_IsEIPInvest                  DEFAULT ((0))
  , IsTwoPercentLimit               BIT             NOT NULL    CONSTRAINT DF_Issue_IsTwoPercentLimit            DEFAULT ((0))
  , TwoPercentLimitBasedOn          VARCHAR (100)   NOT NULL    CONSTRAINT DF_Issue_TwoPercentLimitBasedOn       DEFAULT ('')
  , CreditEnhanceFee                DECIMAL (15, 2) NOT NULL    CONSTRAINT DF_Issue_CreditEnhanceFee             DEFAULT ((0))
  , PostIssuanceFee                 DECIMAL (15, 2) NOT NULL    CONSTRAINT DF_Issue_PostIssuanceFee              DEFAULT ((0))
  , LineItemTotalEstEhlersFee       DECIMAL (18)    NOT NULL    CONSTRAINT DF_Issue_LineItemEstimatedEhlersFee   DEFAULT ((0))
  , TotalFeePaymentMethodID         INT             NULL
  , TotalFeeVerifyDate              DATE            NULL
  , TotalFeeVerifyUser              VARCHAR (20)    NOT NULL    CONSTRAINT DF_Issue_TotalFeeVerifyUser           DEFAULT ('')
  , TotalEstimatedEhlersFee         DECIMAL (15, 2) NOT NULL    CONSTRAINT DF_Issue_TotalEstimatedEhlersFee      DEFAULT ((0))
  , GoodFaithDestination            VARCHAR (50)    NOT NULL    CONSTRAINT DF_Issue_GoodFaithDestination         DEFAULT ('To Ehlers')
  , Notes                           VARCHAR (MAX)   NULL
  , DebtStructureNotes              VARCHAR (MAX)   NULL
  , ObligorClientID                 INT             NULL
  , CertificateTypeID               INT             NULL
  , FirstDeadline                   DATE            NULL
  , IsAAC                           BIT             NOT NULL    CONSTRAINT DF_Issue_IsAAC                       DEFAULT ((0))
  , IsTAC                           BIT             NOT NULL    CONSTRAINT DF_Issue_IsTAC                       DEFAULT ((0))
  , RefundingOfSTFL                 BIT             NOT NULL    CONSTRAINT DF_Issue_RefundingOfSTFL             DEFAULT ((0))
  , RefundingOfLocalBankLoan        BIT             NOT NULL    CONSTRAINT DF_Issue_RefundingOfLocalBankLoan    DEFAULT ((0))
  , WIGOPlannedAbatement            BIT             NOT NULL    CONSTRAINT DF_Issue_WIGOPlannedAbatement        DEFAULT ((0))
  , InterimFinancing                BIT             NOT NULL    CONSTRAINT DF_Issue_InterimFinancing            DEFAULT ((0))
  , BalloonMaturitySchedule         BIT             NOT NULL    CONSTRAINT DF_Issue_BalloonMaturitySchedule     DEFAULT ((0))
  , ModifiedDate                    DATETIME        NOT NULL    CONSTRAINT DF_Issue_ModifiedDate                DEFAULT (getdate())
  , ModifiedUser                    VARCHAR (20)    NOT NULL    CONSTRAINT DF_Issue_ModifiedUser                DEFAULT ([dbo].[udf_GetSystemUser]())

  , CONSTRAINT FK_Issue_BondFormType
        FOREIGN KEY ( BondFormTypeID ) REFERENCES  dbo.BondFormType ( BondFormTypeID )

  , CONSTRAINT FK_Issue_CallFrequency
        FOREIGN KEY ( CallFrequencyID ) REFERENCES  dbo.CallFrequency ( CallFrequencyID )

  , CONSTRAINT FK_Issue_CertificateType
        FOREIGN KEY ( CertificateTypeID ) REFERENCES  dbo.CertificateType ( CertificateTypeID )

  , CONSTRAINT FK_Issue_Client
    FOREIGN KEY ( ClientID ) REFERENCES  dbo.Client ( ClientID )

  , CONSTRAINT FK_Issue_DisclosureType
        FOREIGN KEY ( DisclosureTypeID ) REFERENCES  dbo.DisclosureType ( DisclosureTypeID )

  , CONSTRAINT FK_Issue_InitialOfferingDocument
        FOREIGN KEY ( InitialOfferingDocumentID ) REFERENCES  dbo.InitialOfferingDocument ( InitialOfferingDocumentID )

  , CONSTRAINT FK_Issue_InterestCalcMethod
        FOREIGN KEY ( InterestCalcMethodID ) REFERENCES  dbo.InterestCalcMethod ( InterestCalcMethodID )

  , CONSTRAINT FK_Issue_InterestPaymentFreq
        FOREIGN KEY ( InterestPaymentFreqID ) REFERENCES  dbo.InterestPaymentFreq ( InterestPaymentFreqID )

  , CONSTRAINT FK_Issue_InterestType
        FOREIGN KEY ( InterestTypeID ) REFERENCES  dbo.InterestType ( InterestTypeID )

  , CONSTRAINT FK_Issue_IssueShortName
        FOREIGN KEY ( IssueShortNameID ) REFERENCES  dbo.IssueShortName ( IssueShortNameID )

  , CONSTRAINT FK_Issue_IssueStatus
        FOREIGN KEY ( IssueStatusID ) REFERENCES  dbo.IssueStatus ( IssueStatusID )

  , CONSTRAINT FK_Issue_IssueType
        FOREIGN KEY ( IssueTypeID ) REFERENCES dbo.IssueType ( IssueTypeID )

  , CONSTRAINT FK_Issue_MethodOfSale
        FOREIGN KEY ( MethodOfSaleID ) REFERENCES dbo.MethodOfSale ( MethodOfSaleID )

  , CONSTRAINT FK_Issue_ObligorClient
        FOREIGN KEY ( ObligorClientID ) REFERENCES dbo.Client ( ClientID )

  , CONSTRAINT FK_Issue_PaymentMethod
        FOREIGN KEY ( TotalFeePaymentMethodID ) REFERENCES dbo.PaymentMethod ( PaymentMethodID )

  , CONSTRAINT FK_Issue_SecurityType
        FOREIGN KEY ( SecurityTypeID ) REFERENCES dbo.SecurityType ( SecurityTypeID )
) ;
GO

CREATE INDEX IX_Issue_ClientID ON dbo.Issue( ClientID ASC ) ;
GO

CREATE INDEX IX_Issue_IssueName ON dbo.Issue( IssueName ASC ) ;
