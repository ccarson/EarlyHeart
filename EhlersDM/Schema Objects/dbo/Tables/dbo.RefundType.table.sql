﻿CREATE TABLE dbo.RefundType (
    RefundTypeID    INT           NOT NULL  IDENTITY
  , Value           VARCHAR (100) NOT NULL
  , DisplaySequence INT           NOT NULL    CONSTRAINT DF_RefundType_DisplaySequence DEFAULT 0
  , Active          BIT           NOT NULL    CONSTRAINT DF_RefundType_Active DEFAULT 1
  , Description     VARCHAR (200) NULL
  , ModifiedDate    DATETIME      NOT NULL    CONSTRAINT DF_RefundType_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser    VARCHAR (20)  NOT NULL    CONSTRAINT DF_RefundType_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , LegacyValue     VARCHAR (50)  NULL
  , CONSTRAINT PK_RefundType PRIMARY KEY CLUSTERED ( RefundTypeID ASC )
  , CONSTRAINT UX_RefundType_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
