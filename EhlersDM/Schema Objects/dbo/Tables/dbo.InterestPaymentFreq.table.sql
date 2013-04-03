CREATE TABLE dbo.InterestPaymentFreq (
    InterestPaymentFreqID INT           NOT NULL    IDENTITY
  , Value                 VARCHAR (100) NOT NULL
  , DisplaySequence       INT           NOT NULL    CONSTRAINT DF_InterestPaymentFreq_DisplaySequence DEFAULT ((0))
  , Active                BIT           NOT NULL    CONSTRAINT DF_InterestPaymentFreq_Active DEFAULT ((1))
  , Description           VARCHAR (200) NULL
  , ModifiedDate          DATETIME      NOT NULL    CONSTRAINT DF_InterestPaymentFreq_ModifiedDate DEFAULT (getdate())
  , ModifiedUser          VARCHAR (20)  NOT NULL    CONSTRAINT DF_InterestPaymentFreq_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , LegacyValue           VARCHAR (50)  NULL
  , CONSTRAINT PK_InterestPaymentFreq PRIMARY KEY CLUSTERED ( InterestPaymentFreqID ASC )
  , CONSTRAINT UX_InterestPaymentFreq_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
