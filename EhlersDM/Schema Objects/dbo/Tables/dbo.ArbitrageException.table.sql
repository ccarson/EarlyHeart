CREATE TABLE dbo.ArbitrageException (
    ArbitrageExceptionID    INT             NOT NULL    IDENTITY
  , Value                   VARCHAR (100)   NOT NULL
  , DisplaySequence         INT             NOT NULL    CONSTRAINT DF_ArbitrageException_DisplaySequence DEFAULT 0
  , Active                  BIT             NOT NULL    CONSTRAINT DF_ArbitrageException_Active DEFAULT 1
  , Description             VARCHAR (200)   NULL
  , ModifiedDate            DATETIME        NOT NULL    CONSTRAINT DF_ArbitrageException_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser            VARCHAR (20)    NOT NULL    CONSTRAINT DF_ArbitrageException_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , LegacyValue             VARCHAR (50)    NULL
  , CONSTRAINT PK_ArbitrageException PRIMARY KEY CLUSTERED ( ArbitrageExceptionID ASC )
  , CONSTRAINT UX_ArbitrageException_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
