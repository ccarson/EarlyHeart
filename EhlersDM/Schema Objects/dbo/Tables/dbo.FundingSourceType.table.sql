CREATE TABLE dbo.FundingSourceType (
    FundingSourceTypeID INT           NOT NULL  IDENTITY
  , Value               VARCHAR (100) NOT NULL
  , DisplaySequence     INT           NOT NULL    CONSTRAINT DF_FundingSourceType_DisplaySequence DEFAULT ((0))
  , Active              BIT           NOT NULL    CONSTRAINT DF_FundingSourceType_Active DEFAULT ((1))
  , Description         VARCHAR (200) NULL
  , ModifiedDate        DATETIME      NOT NULL    CONSTRAINT DF_FundingSourceType_ModifiedDate DEFAULT (getdate())
  , ModifiedUser        VARCHAR (20)  NOT NULL    CONSTRAINT DF_FundingSourceType_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , LegacyValue         VARCHAR (50)  NULL
  , CONSTRAINT PK_FundingSourceType PRIMARY KEY CLUSTERED ( FundingSourceTypeID ASC )
  , CONSTRAINT UX_FundingSourceType_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
