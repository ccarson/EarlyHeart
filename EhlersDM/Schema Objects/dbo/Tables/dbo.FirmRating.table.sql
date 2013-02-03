CREATE TABLE dbo.FirmRating (
    FirmRatingID INT          NOT NULL  IDENTITY
  , FirmID       INT          NOT NULL
  , RatingID     INT          NOT NULL
  , RatedDate    DATE         NOT NULL
  , Event        VARCHAR (50) NOT NULL  CONSTRAINT DF_FirmRating_Event DEFAULT ('')
  , ModifiedDate DATETIME     NOT NULL    CONSTRAINT DF_FirmRating_ModifiedDate DEFAULT GETDATE()
  , ModifiedUser VARCHAR (20) NOT NULL    CONSTRAINT DF_FirmRating_ModifiedUser DEFAULT dbo.udf_GetSystemUser()
  , CONSTRAINT PK_FirmRating PRIMARY KEY CLUSTERED ( FirmRatingID ASC )
  , CONSTRAINT FK_FirmRating_Firm
        FOREIGN KEY ( FirmID ) REFERENCES dbo.Firm ( FirmID )
  , CONSTRAINT FK_FirmRating_Rating
        FOREIGN KEY ( RatingID ) REFERENCES dbo.Rating ( RatingID )
) ;
GO

CREATE INDEX IX_FirmRating_FirmID ON dbo.FirmRating ( FirmID ASC ) ;
