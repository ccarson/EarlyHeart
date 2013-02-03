CREATE TABLE dbo.ClientRating (
    ClientRatingID  INT             NOT NULL    IDENTITY
  , ClientID        INT             NOT NULL
  , RatingID        INT             NOT NULL
  , RatingTypeID    INT             NOT NULL
  , RatedDate       DATE            NOT NULL
  , Event           VARCHAR (50)    NOT NULL    CONSTRAINT DF_ClientRating_Event    DEFAULT ('')
  , ModifiedDate    DATETIME        NOT NULL    CONSTRAINT DF_ClientRating_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser    VARCHAR (20)    NOT NULL    CONSTRAINT DF_ClientRating_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_ClientRating PRIMARY KEY CLUSTERED ( ClientRatingID ASC )
  , CONSTRAINT FK_ClientRating_Client
        FOREIGN KEY ( ClientID ) REFERENCES dbo.Client ( ClientID )
  , CONSTRAINT FK_ClientRating_Rating
        FOREIGN KEY ( RatingID ) REFERENCES dbo.Rating ( RatingID )
  , CONSTRAINT FK_ClientRating_RatingType
        FOREIGN KEY ( RatingTypeID ) REFERENCES dbo.RatingType ( RatingTypeID )
) ;
GO

CREATE INDEX IX_ClientRating_ClientID ON dbo.ClientRating ( ClientID ASC ) ;
GO

CREATE INDEX IX_ClientRating_RatingID ON dbo.ClientRating ( RatingID ASC ) ;
