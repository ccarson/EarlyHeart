CREATE TABLE Meta.ErrorType (
    ErrorTypeID     INT             NOT NULL    CONSTRAINT PK_ErrorType PRIMARY KEY CLUSTERED
  , Value           VARCHAR (50)    NOT NULL
  , DisplaySequence INT             NOT NULL    CONSTRAINT DF_ErrorType_DisplaySequence DEFAULT 0
  , ModifiedDate    DATETIME        NOT NULL    CONSTRAINT DF_ErrorType_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser    VARCHAR (20)    NOT NULL    CONSTRAINT DF_ErrorType_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
) ;
