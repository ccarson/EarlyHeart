CREATE TABLE dbo.InterestCalcMethod (
    InterestCalcMethodID INT           NOT NULL IDENTITY
  , Value                VARCHAR (100) NOT NULL
  , DisplaySequence      INT           NOT NULL    CONSTRAINT DF_InterestCalcMethod_DisplaySequence DEFAULT 0
  , Active               BIT           NOT NULL    CONSTRAINT DF_InterestCalcMethod_Active DEFAULT 1
  , Description          VARCHAR (200) NULL
  , ModifiedDate         DATETIME      NOT NULL    CONSTRAINT DF_InterestCalcMethod_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser         VARCHAR (20)  NOT NULL    CONSTRAINT DF_InterestCalcMethod_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , LegacyValue          VARCHAR (50)  NULL
  , CONSTRAINT PK_InterestCalcMethod PRIMARY KEY CLUSTERED ( InterestCalcMethodID ASC )
  , CONSTRAINT UX_InterestCalcMethod_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
