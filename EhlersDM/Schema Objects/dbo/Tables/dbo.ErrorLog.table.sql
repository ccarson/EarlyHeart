CREATE TABLE dbo.ErrorLog (
    ErrorLogID      INT             NOT NULL    IDENTITY
  , Message         VARCHAR (MAX)   NOT NULL    CONSTRAINT DF_ErrorLog_Message      DEFAULT ('')
  , StackTrace      VARCHAR (MAX)   NOT NULL    CONSTRAINT DF_ErrorLog_StackTrace   DEFAULT ('')
  , Source          VARCHAR (MAX)   NOT NULL    CONSTRAINT DF_ErrorLog_Source       DEFAULT ('')
  , TargetSite      VARCHAR (MAX)   NOT NULL    CONSTRAINT DF_ErrorLog_TargetSite   DEFAULT ('')
  , SessionState    VARCHAR (MAX)   NOT NULL    CONSTRAINT DF_ErrorLog_SessionState DEFAULT ('')
  , ModifiedDate    DATETIME        NOT NULL    CONSTRAINT DF_ErrorLog_ModifiedDate DEFAULT (getdate())
  , ModifiedUser    VARCHAR (20)    NOT NULL    CONSTRAINT DF_ErrorLog_ModifiedUser DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_ErrorLog PRIMARY KEY CLUSTERED ( ErrorLogID ASC )
) ;
