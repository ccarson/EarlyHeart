﻿CREATE TABLE dbo.MeetingPurpose (
    MeetingPurposeID INT           NOT NULL IDENTITY
  , Value            VARCHAR (100) NOT NULL
  , DisplaySequence  INT           NOT NULL    CONSTRAINT DF_MeetingPurpose_DisplaySequence DEFAULT 0
  , Active           BIT           NOT NULL    CONSTRAINT DF_MeetingPurpose_Active DEFAULT 1
  , Description      VARCHAR (200) NULL
  , ModifiedDate     DATETIME      NOT NULL    CONSTRAINT DF_MeetingPurpose_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser     VARCHAR (20)  NOT NULL    CONSTRAINT DF_MeetingPurpose_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , LegacyValue      VARCHAR (50)  NULL
  , CONSTRAINT PK_MeetingPurpose PRIMARY KEY CLUSTERED ( MeetingPurposeID ASC )
  , CONSTRAINT UX_MeetingPurpose_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
