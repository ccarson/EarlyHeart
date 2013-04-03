CREATE TABLE dbo.MeetingType (
    MeetingTypeID   INT           NOT NULL  IDENTITY
  , Value           VARCHAR (100) NOT NULL
  , DisplaySequence INT           NOT NULL    CONSTRAINT DF_MeetingType_DisplaySequence DEFAULT ((0))
  , Active          BIT           NOT NULL    CONSTRAINT DF_MeetingType_Active DEFAULT ((1))
  , Description     VARCHAR (200) NULL
  , ModifiedDate    DATETIME      NOT NULL    CONSTRAINT DF_MeetingType_ModifiedDate DEFAULT (getdate())
  , ModifiedUser    VARCHAR (20)  NOT NULL    CONSTRAINT DF_MeetingType_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , LegacyValue     VARCHAR (50)  NULL
  , CONSTRAINT PK_MeetingType PRIMARY KEY CLUSTERED ( MeetingTypeID ASC )
  , CONSTRAINT UX_MeetingType_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;
