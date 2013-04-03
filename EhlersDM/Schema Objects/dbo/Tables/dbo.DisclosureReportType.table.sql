CREATE TABLE dbo.DisclosureReportType (
    DisclosureReportTypeID  INT             NOT NULL    IDENTITY
  , Value                   VARCHAR (100)   NOT NULL
  , DisplaySequence         INT             NOT NULL    CONSTRAINT DF_DisclosureReportType_DisplaySequence DEFAULT ((0))
  , Active                  BIT             NOT NULL    CONSTRAINT DF_DisclosureReportType_Active DEFAULT ((1))
  , Description             VARCHAR (200)   NULL
  , ModifiedDate            DATETIME        NOT NULL    CONSTRAINT DF_DisclosureReportType_ModifiedDate DEFAULT (getdate())
  , ModifiedUser            VARCHAR (20)    NOT NULL    CONSTRAINT DF_DisclosureReportType_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , LegacyValue             VARCHAR (50)    NULL
  , CONSTRAINT PK_DisclosureReportType PRIMARY KEY CLUSTERED ( DisclosureReportTypeID ASC )
  , CONSTRAINT UX_DisclosureReportType_Value UNIQUE NONCLUSTERED ( Value ASC )
) ;