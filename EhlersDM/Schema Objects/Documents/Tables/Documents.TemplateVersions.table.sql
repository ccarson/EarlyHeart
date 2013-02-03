CREATE TABLE Documents.TemplateVersions (
    TemplateID      INT            NOT NULL
  , Version         INT            NOT NULL
  , CurrentVersion  BIT            NOT NULL
  , Content         IMAGE          NULL
  , TemplateContent NVARCHAR (MAX) NULL 
  , CONSTRAINT PK_TemplateVersions PRIMARY KEY CLUSTERED ( TemplateID ASC, Version ASC )
) ;
