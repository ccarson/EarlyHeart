CREATE TABLE dbo.IssueRating (
    IssueRatingID               INT             NOT NULL    IDENTITY
  , IssueID                     INT             NOT NULL
  , RatingTypeID                INT             NULL
  , IsMoodyRated                BIT             NOT NULL    CONSTRAINT DF_IssueRating_IsMoodyRated        DEFAULT ((0))
  , IsSPRated                   BIT             NOT NULL    CONSTRAINT DF_IssueRating_IsSPRated           DEFAULT ((0))
  , IsFitchRated                BIT             NOT NULL    CONSTRAINT DF_IssueRating_IsFitchRated        DEFAULT ((0))
  , IsMoodyShadowRated          BIT             NOT NULL    CONSTRAINT DF_IssueRating_IsMoodyShadowRated  DEFAULT ((0))
  , IsSPShadowRated             BIT             NOT NULL    CONSTRAINT DF_IssueRating_IsSPShadowRated     DEFAULT ((0))
  , IsFitchShadowRated          BIT             NOT NULL    CONSTRAINT DF_IssueRating_IsFitchShadowRated  DEFAULT ((0))
  , IsNotRated                  BIT             NOT NULL    CONSTRAINT DF_IssueRating_IsNotRated          DEFAULT ((0))
  , IsNotRatedCreditEnhanced    BIT             NOT NULL    CONSTRAINT DF_IssueRating_IsCreditEnhanced    DEFAULT ((0))
  , MoodyCreditEnhanced         VARCHAR (50)    NOT NULL    CONSTRAINT DF_IssueRating_MoodyCreditEnhanced DEFAULT ('')
  , SPCreditEnhanced            VARCHAR (50)    NOT NULL    CONSTRAINT DF_IssueRating_SPCreditEnhanced    DEFAULT ('')
  , ModifiedDate                DATETIME        NOT NULL    CONSTRAINT DF_IssueRating_ModifiedDate        DEFAULT (getdate())
  , ModifiedUser                VARCHAR (20)    NOT NULL    CONSTRAINT DF_IssueRating_ModifiedUser        DEFAULT ([dbo].[udf_GetSystemUser]())
  , CONSTRAINT PK_IssueRating PRIMARY KEY CLUSTERED ( IssueRatingID ASC )
  , CONSTRAINT FK_IssueRating_Issue
        FOREIGN KEY ( IssueID ) REFERENCES  dbo.Issue ( IssueID )
  , CONSTRAINT FK_IssueRating_RatingType
        FOREIGN KEY ( RatingTypeID ) REFERENCES  dbo.RatingType ( RatingTypeID )
) ;
GO

CREATE INDEX IX_IssueRating_IssueID ON dbo.IssueRating ( IssueID ASC ) ;
