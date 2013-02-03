﻿CREATE TABLE dbo.SecurityType (
    SecurityTypeID  INT           NOT NULL  IDENTITY
  , Value           VARCHAR (100) NOT NULL
  , DisplaySequence INT           NOT NULL    CONSTRAINT DF_SecurityType_DisplaySequence DEFAULT 0
  , Active          BIT           NOT NULL    CONSTRAINT DF_SecurityType_Active DEFAULT 1
  , Description     VARCHAR (200) NULL
  , ModifiedDate    DATETIME      NOT NULL    CONSTRAINT DF_SecurityType_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser    VARCHAR (20)  NOT NULL    CONSTRAINT DF_SecurityType_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , LegacyValue     VARCHAR (50)  NULL
  , CONSTRAINT PK_SecurityType PRIMARY KEY CLUSTERED ( SecurityTypeID ASC )
  , CONSTRAINT UX_SecurityType_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
