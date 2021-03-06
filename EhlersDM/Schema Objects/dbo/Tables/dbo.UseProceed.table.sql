﻿CREATE TABLE dbo.UseProceed (
    UseProceedID    INT           NOT NULL  IDENTITY
  , Value           VARCHAR (100) NOT NULL
  , DisplaySequence INT           NOT NULL    CONSTRAINT DF_UseProceed_DisplaySequence DEFAULT 0
  , Active          BIT           NOT NULL    CONSTRAINT DF_UseProceed_Active DEFAULT 1
  , Description     VARCHAR (200) NULL
  , ModifiedDate    DATETIME      NOT NULL    CONSTRAINT DF_UseProceed_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser    VARCHAR (20)  NOT NULL    CONSTRAINT DF_UseProceed_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , LegacyValue     VARCHAR (50)  NULL
  , CONSTRAINT PK_UseProceed PRIMARY KEY CLUSTERED ( UseProceedID ASC )
  , CONSTRAINT UX_UseProceed_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
