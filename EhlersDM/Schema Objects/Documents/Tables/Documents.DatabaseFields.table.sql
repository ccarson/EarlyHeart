CREATE TABLE Documents.DatabaseFields (
    DatabaseFieldID   INT           NOT NULL    IDENTITY
  , TableName         VARCHAR (50)  NOT NULL
  , FieldName         VARCHAR (100) NOT NULL
  , DescriptiveName   VARCHAR (200) NOT NULL
  , AvailableForMerge BIT           NOT NULL
  , DefaultMergeCode  BIT           NOT NULL
  , FieldNotes        VARCHAR (300) NULL
  , CONSTRAINT PK_DatabaseFields PRIMARY KEY CLUSTERED ( DatabaseFieldID ASC )
) ;
