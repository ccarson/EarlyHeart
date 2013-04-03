CREATE TABLE dbo.States (
    StatesID        INT          NOT NULL  IDENTITY
  , Abbreviation    CHAR (2)     NOT NULL
  , FullName        VARCHAR (50) NOT NULL
  , DisplaySequence INT          NOT NULL    CONSTRAINT DF_States_DisplaySequence DEFAULT ((0))
  , CONSTRAINT PK_States PRIMARY KEY CLUSTERED ( StatesID ASC )
) ;
