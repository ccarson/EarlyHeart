CREATE TABLE Meta.ErrorTypeRecipient (
    ErrorTypeRecipientID    INT             NOT NULL    CONSTRAINT PK_ErrorTypeRecipient PRIMARY KEY CLUSTERED IDENTITY
  , ErrorTypeID             INT             NOT NULL    
  , RecipientEMail          VARCHAR (100)   NOT NULL
  , ModifiedDate            DATETIME        NOT NULL    CONSTRAINT DF_ErrorTypeRecipient_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser            VARCHAR (20)    NOT NULL    CONSTRAINT DF_ErrorTypeRecipient_ModifiedUser DEFAULT dbo.udf_GetSystemUser()

  , CONSTRAINT FK_ErrorTypeRecipient_ErrorType
        FOREIGN KEY ( ErrorTypeID ) REFERENCES Meta.ErrorType ( ErrorTypeID )
) ;
