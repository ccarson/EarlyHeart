﻿CREATE TABLE dbo.FirmSpeciality (
    FirmSpecialityID    INT             NOT NULL    IDENTITY
  , Value               VARCHAR (100)   NOT NULL
  , DisplaySequence     INT             NOT NULL    CONSTRAINT DF_FirmSpeciality_DisplaySequence DEFAULT 0
  , Active              BIT             NOT NULL    CONSTRAINT DF_FirmSpeciality_Active DEFAULT 1
  , Description         VARCHAR (200)   NULL
  , ModifiedDate        DATETIME        NOT NULL    CONSTRAINT DF_FirmSpeciality_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser        VARCHAR (20)    NOT NULL    CONSTRAINT DF_FirmSpeciality_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , LegacyValue         VARCHAR (50)    NULL
  , CONSTRAINT PK_FirmSpeciality PRIMARY KEY CLUSTERED ( FirmSpecialityID ASC )
  , CONSTRAINT UX_FirmSpeciality_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
