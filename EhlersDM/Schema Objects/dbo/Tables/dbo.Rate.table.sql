CREATE TABLE dbo.Rate (
    RateID        INT              NOT NULL
  , EffectiveDate DATE             NOT NULL
  , BBIRate       DECIMAL (13, 10) NULL
  , RBIRate       DECIMAL (13, 10) NULL
  , TreasuryRate  DECIMAL (13, 10) NULL
  , ModifiedDate  DATETIME         NOT NULL    CONSTRAINT DF_Rate_ModifiedDate DEFAULT (getdate())
  , ModifiedUser  VARCHAR (20)     NOT NULL    CONSTRAINT DF_Rate_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_Rate PRIMARY KEY CLUSTERED ( RateID ASC )
  , CONSTRAINT UX_Rate_EffectiveDate UNIQUE NONCLUSTERED ( EffectiveDate ASC )
) ;
