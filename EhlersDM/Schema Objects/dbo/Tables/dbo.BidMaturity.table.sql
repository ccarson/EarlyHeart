CREATE TABLE dbo.BidMaturity (
    BidMaturityID        INT             NOT NULL   IDENTITY
  , BidderID             INT             NOT NULL
  , PaymentDate          DATE            NOT NULL   CONSTRAINT DF_BidMaturity_MaturityDate    DEFAULT ('')
  , PaymentAmount        DECIMAL (15, 2) NOT NULL   CONSTRAINT DF_BidMaturity_Maturity        DEFAULT ((0))
  , OrginalPaymentAmount DECIMAL (15, 2) NOT NULL   CONSTRAINT DF_BidMaturity_OrginalMaturity DEFAULT ((0))
  , InterestRate         DECIMAL (6, 3)  NOT NULL   CONSTRAINT DF_BidMaturity_Coupon          DEFAULT ((0))
  , TermBond             SMALLINT        NOT NULL   CONSTRAINT DF_BidMaturity_TermBond        DEFAULT ((0))
  , ModifiedDate         DATETIME        NOT NULL    CONSTRAINT DF_BidMaturity_ModifiedDate DEFAULT (getdate())
  , ModifiedUser         VARCHAR (20)    NOT NULL    CONSTRAINT DF_BidMaturity_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_BidMaturity PRIMARY KEY CLUSTERED ( BidMaturityID ASC )
  , CONSTRAINT FK_BidMaturity_Bidder
        FOREIGN KEY ( BidderID ) REFERENCES dbo.Bidder ( BidderID )
) ;
GO

CREATE INDEX IX_BidMaturity_BidderID ON dbo.BidMaturity ( BidderID ASC ) ;
GO

CREATE INDEX IX_BidMaturity_Compare ON dbo.BidMaturity ( 
    BidderID ASC, PaymentDate ASC, PaymentAmount ASC
        , OrginalPaymentAmount ASC, InterestRate ASC, TermBond ASC ) ;
