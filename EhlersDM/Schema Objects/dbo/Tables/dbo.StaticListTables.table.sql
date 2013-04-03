CREATE TABLE dbo.StaticListTables (
    TableName       VARCHAR (50)    NOT NULL    CONSTRAINT PK_StaticListTables PRIMARY KEY CLUSTERED
  , IsBridge        BIT             NOT NULL    CONSTRAINT DF_StaticListTables_IsBridge        DEFAULT ((0))
  , TablesUsedBy    VARCHAR (MAX)   NOT NULL    CONSTRAINT DF_StaticListTables_TablesUsedBy    DEFAULT ('')
) ;
