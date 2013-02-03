CREATE TABLE dbo.SQLErrorLog (
    SQLErrorLogID  INT              NOT NULL  IDENTITY
  , ErrorTime      DATETIME         NOT NULL
  , UserName       SYSNAME          NOT NULL
  , ErrorNumber    INT              NOT NULL
  , ErrorSeverity  INT              NULL
  , ErrorState     INT              NULL
  , ErrorProcedure NVARCHAR (126)   NULL
  , ErrorLine      INT              NULL
  , ErrorMessage   NVARCHAR (4000)  NOT NULL
  , CONSTRAINT PK_SQLErrorLog PRIMARY KEY CLUSTERED ( SQLErrorLogID ASC )
) ;
