CREATE TABLE dbo.StaticListTables (
    TableName    VARCHAR (50)  NOT NULL
  , TablesUsedBy VARCHAR (MAX) NOT NULL CONSTRAINT DF_StaticListTables_TablesUsedBy DEFAULT ('')
) ;
