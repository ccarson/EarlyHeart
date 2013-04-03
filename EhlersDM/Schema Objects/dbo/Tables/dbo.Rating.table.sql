CREATE TABLE dbo.Rating (
    RatingID        INT          NOT NULL   IDENTITY
  , RatingAgency    VARCHAR (20) NOT NULL   CONSTRAINT DF_Rating_RatingAgency   DEFAULT ('')
  , Value           VARCHAR (10) NOT NULL
  , DisplaySequence INT          NOT NULL    CONSTRAINT DF_Rating_DisplaySequence DEFAULT ((0))
  , Active          BIT          NOT NULL    CONSTRAINT DF_Rating_Active DEFAULT ((1))
  , IssueUseOnly    BIT          NOT NULL   CONSTRAINT DF_Rating_IssueUseOnly   DEFAULT ((0))
  , CONSTRAINT PK_Rating PRIMARY KEY CLUSTERED ( RatingID ASC )
  --, CONSTRAINT IX_Value UNIQUE NONCLUSTERED ( RatingID )
) ;
