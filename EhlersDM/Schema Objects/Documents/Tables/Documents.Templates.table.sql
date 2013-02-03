CREATE TABLE Documents.Templates (
    TemplateID         INT           NOT NULL   IDENTITY
  , TemplateName       VARCHAR (500) NOT NULL
  , DocumentSectionID  INT           NOT NULL
  , OrderWithinSection SMALLINT      NOT NULL
  , TemplateType       VARCHAR (15)  NULL
  , Condition          VARCHAR (MAX) NULL
  , ActiveVersion      INT           NULL 
  , CONSTRAINT PK_Templates PRIMARY KEY CLUSTERED ( TemplateID ASC )
  , CONSTRAINT FK_Templates_DocumentSections
        FOREIGN KEY ( DocumentSectionID ) REFERENCES Documents.DocumentSections ( DocumentSectionID )
) ; 
