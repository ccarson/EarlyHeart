CREATE TABLE dbo.ArbitrageRecordType (
    ArbitrageRecordTypeID   INT             NOT NULL    IDENTITY
  , Value                   VARCHAR (100)   NOT NULL
  , DisplaySequence         INT             NOT NULL    CONSTRAINT DF_ArbitrageRecordType_DisplaySequence DEFAULT ((0))
  , Active                  BIT             NOT NULL    CONSTRAINT DF_ArbitrageRecordType_Active DEFAULT ((1))
  , Description             VARCHAR (200)   NULL
  , ModifiedDate            DATETIME        NOT NULL    CONSTRAINT DF_ArbitrageRecordType_ModifiedDate DEFAULT (getdate())
  , ModifiedUser            VARCHAR (20)    NOT NULL    CONSTRAINT DF_ArbitrageRecordType_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , LegacyValue             VARCHAR (50)    NULL
  , CONSTRAINT PK_ArbitrageRecordType PRIMARY KEY CLUSTERED ( ArbitrageRecordTypeID ASC )
  , CONSTRAINT UX_ArbitrageRecordType_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
