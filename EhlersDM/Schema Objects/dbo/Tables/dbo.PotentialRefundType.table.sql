CREATE TABLE dbo.PotentialRefundType (
    PotentialRefundTypeID   INT             NOT NULL    IDENTITY
  , Value                   VARCHAR (100)   NOT NULL
  , DisplaySequence         INT             NOT NULL    CONSTRAINT DF_PotentialRefundType_DisplaySequence DEFAULT 0
  , Active                  BIT             NOT NULL    CONSTRAINT DF_PotentialRefundType_Active DEFAULT 1
  , Description             VARCHAR (200)   NULL
  , ModifiedDate            DATETIME        NOT NULL    CONSTRAINT DF_PotentialRefundType_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser            VARCHAR (20)    NOT NULL    CONSTRAINT DF_PotentialRefundType_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , LegacyValue             VARCHAR (50)    NULL
  , CONSTRAINT PK_PotentialRefundType PRIMARY KEY CLUSTERED ( PotentialRefundTypeID ASC )
  , CONSTRAINT UX_PotentialRefundType_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
