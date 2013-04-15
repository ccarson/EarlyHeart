CREATE TABLE dbo.RefundingCash (
    RefundingCashID INT             NOT NULL    CONSTRAINT PK_RefundingCash PRIMARY KEY CLUSTERED IDENTITY
  , ModifiedDate    DATETIME        NOT NULL
  , ModifiedUser    VARCHAR (20)    NOT NULL
) ;
