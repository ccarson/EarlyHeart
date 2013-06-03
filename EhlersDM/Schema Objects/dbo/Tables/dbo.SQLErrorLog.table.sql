CREATE TABLE dbo.SQLErrorLog (
    SQLErrorLogID   INT             NOT NULL   CONSTRAINT PK_SQLErrorLog PRIMARY KEY CLUSTERED IDENTITY
  , CodeBlockNum    INT             NOT NULL
  , CodeBlockDesc   SYSNAME   NOT NULL
  , ErrorNumber     INT             NOT NULL
  , ErrorSeverity   INT             NULL
  , ErrorState      INT             NULL
  , ErrorProcedure  SYSNAME         NULL
  , ErrorLine       INT             NULL
  , ErrorMessage    NVARCHAR (4000) NOT NULL
  , ErrorData       VARCHAR (MAX)   NULL
  , ModifiedDate    DATETIME        NOT NULL   CONSTRAINT DF_SQLErrorLog_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser    VARCHAR (20)    NOT NULL   CONSTRAINT DF_SQLErrorLog_ModifiedUser DEFAULT dbo.udf_GetSystemUser() 
) ;