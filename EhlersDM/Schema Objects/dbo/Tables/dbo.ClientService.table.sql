﻿CREATE TABLE dbo.ClientService (
    ClientServiceID INT             NOT NULL    IDENTITY
  , Value           VARCHAR (100)   NOT NULL
  , DisplaySequence INT             NOT NULL    CONSTRAINT DF_ClientService_DisplaySequence DEFAULT 0
  , Active          BIT             NOT NULL    CONSTRAINT DF_ClientService_Active DEFAULT 1
  , Description     VARCHAR (200)   NULL
  , ModifiedDate    DATETIME        NOT NULL    CONSTRAINT DF_ClientService_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser    VARCHAR (20)    NOT NULL    CONSTRAINT DF_ClientService_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , LegacyValue     VARCHAR (50)    NULL
  , CONSTRAINT PK_ClientService PRIMARY KEY CLUSTERED ( ClientServiceID ASC )
  , CONSTRAINT UX_ClientService_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
