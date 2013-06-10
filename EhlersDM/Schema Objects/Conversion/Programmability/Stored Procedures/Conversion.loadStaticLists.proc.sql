CREATE PROCEDURE Conversion.loadStaticLists ( @tableList    VARCHAR(MAX) = 'All' )
AS
/*
************************************************************************************************************************************

  Procedure:    Conversion.loadStaticLists
     Author:    Chris Carson
    Purpose:    loads Static Lists from Ehlers_Dev into selected environment


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         ###DATE###          created


    Logic Summary
    1)  Load dbo.StaticListTables into temp storage
    2)  Process each record from temp storage
    3)  Initialize variables
    4)  SELECT column list for INSERT statement
    5)  SELECT column list for UPDATE statement
    6)  SELECT key column for table
    7)  format dynamic SQL statement to execute table refresh
    8)  load variable data into formatted SQL statement
    9)  execute dynamic SQL statement
   10)  commit refreshed data

   NOTES
   In order for static lists to be loaded, Ehlers_Dev.dbo.StaticListTables needs to be populated
   If any RI exists for the StaticListTables, it needs to be set up and enforced in Ehlers_Dev


************************************************************************************************************************************
*/
BEGIN
BEGIN TRY
    SET NOCOUNT ON ;

    DECLARE @codeBlockDesc01    AS SYSNAME   = 'Load dbo.StaticListTables into temp storage'
          , @codeBlockDesc02    AS SYSNAME   = 'Process each record from temp storage'
          , @codeBlockDesc03    AS SYSNAME   = 'Initialize variables'
          , @codeBlockDesc04    AS SYSNAME   = 'SELECT column list for INSERT statement'
          , @codeBlockDesc05    AS SYSNAME   = 'SELECT column list for UPDATE statement'
          , @codeBlockDesc06    AS SYSNAME   = 'SELECT key column for table'
          , @codeBlockDesc07    AS SYSNAME   = 'format dynamic SQL statement to execute table refresh'
          , @codeBlockDesc08    AS SYSNAME   = 'load variable data into formatted SQL statement'
          , @codeBlockDesc09    AS SYSNAME   = 'execute dynamic SQL statement'
          , @codeBlockDesc10    AS SYSNAME   = 'commit refreshed data' ;

    DECLARE @codeBlockNum       AS INT
          , @codeBlockDesc      AS SYSNAME
          , @errorTypeID        AS INT
          , @errorSeverity      AS INT
          , @errorState         AS INT
          , @errorNumber        AS INT
          , @errorLine          AS INT
          , @errorProcedure     AS SYSNAME
          , @errorMessage       AS VARCHAR (MAX) = NULL
          , @errorData          AS VARCHAR (MAX) = NULL ;


    DECLARE @columns            AS TABLE ( columnName   SYSNAME ) ;
    DECLARE @tableName          AS sysname
    DECLARE @tableKey           AS sysname
    DECLARE @tables             AS TABLE ( tableName    SYSNAME
                                         , ordinal      INT  ) ;

    DECLARE @columnList         AS NVARCHAR (MAX) ;
    DECLARE @updateList         AS NVARCHAR (MAX) ;

    DECLARE @sql                AS NVARCHAR (MAX) ;

/**/SELECT  @codeBlockNum   = 1
/**/      , @codeBlockDesc  = @codeBlockDesc01 ; -- Load dbo.StaticListTables into temp storage

    IF ( @tableList = 'ALL' )
        INSERT  @tables ( tableName )
        SELECT  TableName
          FROM  [$(Server)].[$(SourceDatabase)].dbo.StaticListTables ;
    ELSE
        INSERT  @tables ( tableName )
        SELECT  Item
          FROM  dbo.tvf_CSVSplit ( @TableList, ',' ) ;

/**/SELECT  @codeBlockNum   = 2
/**/      , @codeBlockDesc  = @codeBlockDesc02 ; -- Process each record from temp storage

    WHILE EXISTS ( SELECT 1 FROM @tables )
    BEGIN

        BEGIN TRANSACTION ;

        SELECT TOP 1 @tableName = tableName FROM @tables ORDER BY ordinal ;

        RAISERROR ( 'Processing Static List dbo.%s', 0, 0, @tableName) ;

/**/SELECT  @codeBlockNum   = 3
/**/      , @codeBlockDesc  = @codeBlockDesc03 ; -- Initialize variables

        SELECT  @columnList = NULL
              , @updateList = NULL
              , @SQL        = NULL ;


/**/SELECT  @codeBlockNum   = 4
/**/      , @codeBlockDesc  = @codeBlockDesc04 ; -- SELECT column list for INSERT statement

        SELECT  @columnList = ISNULL( @columnList, '') + ', ' + COLUMN_NAME
          FROM  INFORMATION_SCHEMA.COLUMNS
         WHERE  TABLE_NAME = @tableName
      ORDER BY  ORDINAL_POSITION ;


/**/SELECT  @codeBlockNum   = 5
/**/      , @codeBlockDesc  = @codeBlockDesc05 ; -- SELECT column list for UPDATE statement

        SELECT  @updateList = ISNULL( @updateList, '') + ', ' + COLUMN_NAME + ' = src.' + COLUMN_NAME
          FROM  INFORMATION_SCHEMA.COLUMNS
         WHERE  TABLE_NAME = @tableName AND ORDINAL_POSITION > 1
      ORDER BY  ORDINAL_POSITION ;


/**/SELECT  @codeBlockNum   = 6
/**/      , @codeBlockDesc  = @codeBlockDesc06 ; -- SELECT key column for table

        SELECT  @tableKey = COLUMN_NAME
          FROM  INFORMATION_SCHEMA.COLUMNS
         WHERE  TABLE_NAME = @tableName AND ORDINAL_POSITION = 1 ;


/**/SELECT  @codeBlockNum   = 7
/**/      , @codeBlockDesc  = @codeBlockDesc07 ; -- format dynamic SQL statement to execute table refresh

        SELECT  @columnList = STUFF(@columnList, 1, 2, '' )
              , @updateList = STUFF(@updateList, 1, 2, '' )

        SELECT @SQL = N'
        DECLARE @tableName AS SYSNAME = ''##@tableName##'' ;

          WITH  oldRecords AS (
                SELECT * FROM dbo.##@tableName##
                 WHERE ##@tableKey## NOT IN ( SELECT ##@tableKey## FROM [$(Server)].[$(SourceDatabase)].dbo.##@tableName## ) )
        DELETE  oldRecords ;

        RAISERROR ( ''%d records deleted from into dbo.%s'', 0, 0, @@ROWCOUNT, @tableName ) ;

        SET IDENTITY_INSERT dbo.##@tableName## ON ;

          WITH  newRecords AS (
                SELECT * FROM [$(Server)].[$(SourceDatabase)].dbo.##@tableName##
                 WHERE ##@tableKey## NOT IN ( SELECT ##@tableKey## FROM dbo.##@tableName## ) )

        INSERT  dbo.##@tableName## ( ##@columnList## )
        SELECT  ##@columnList##
          FROM  newRecords ;

        RAISERROR ( ''%d records inserted into dbo.%s'', 0, 0, @@ROWCOUNT, @tableName ) ;

          WITH  changedRecords AS (
                SELECT ##@tableKey##, N = BINARY_CHECKSUM(*) FROM [EHLERS-SS4].Ehlers_Dev.dbo.##@tableName##
                    EXCEPT
                SELECT ##@tableKey##, N = BINARY_CHECKSUM(*) FROM dbo.##@tableName## )
        UPDATE  dbo.##@tableName##
           SET  ##@updateList##
          FROM  dbo.##@tableName##                                  AS tgt
    INNER JOIN  [$(Server)].[$(SourceDatabase)].dbo.##@tableName##  AS src ON src.##@tableKey## = tgt.##@tableKey##
    INNER JOIN  changedRecords                                      AS chg ON chg.##@tableKey## = tgt.##@tableKey## ;

        RAISERROR ( ''%d records updated on into dbo.%s'', 0, 0, @@ROWCOUNT, @tableName ) ;

        SET IDENTITY_INSERT dbo.##@tableName## OFF ; ' ;

/**/SELECT  @codeBlockNum   = 8
/**/      , @codeBlockDesc  = @codeBlockDesc08 ; -- load variable data into formatted SQL statement

        SELECT  @SQL = REPLACE( @SQL, '##@tableName##', @tableName ) ;
        SELECT  @SQL = REPLACE( @SQL, '##@tableKey##',  @tableKey ) ;
        SELECT  @SQL = REPLACE( @SQL, '##@columnList##', @columnList ) ;
        SELECT  @SQL = REPLACE( @SQL, '##@updateList##', @updateList ) ;


/**/SELECT  @codeBlockNum   = 9
/**/      , @codeBlockDesc  = @codeBlockDesc09 ; -- execute dynamic SQL statement

        EXEC ( @SQL ) ;


/**/SELECT  @codeBlockNum   = 10
/**/      , @codeBlockDesc  = @codeBlockDesc10 ; -- commit refreshed data

        DELETE @tables
          FROM @tables AS t
         WHERE TableName = @tableName

        COMMIT TRANSACTION ;

    END

END TRY
BEGIN CATCH

    IF  @@TRANCOUNT > 0
        ROLLBACK TRANSACTION ;

    EXECUTE dbo.processEhlersError ;

--    SELECT  @errorTypeID    = 1
--          , @errorSeverity  = ERROR_SEVERITY()
--          , @errorState     = ERROR_STATE()
--          , @errorNumber    = ERROR_NUMBER()
--          , @errorLine      = ERROR_LINE()
--          , @errorProcedure = ISNULL( ERROR_PROCEDURE(), '-' )
--
--    IF  @errorMessage IS NULL
--    BEGIN
--        SELECT  @errorMessage = N'Error occurred in Code Block %d, %s ' + CHAR(13)
--                              + N'Error %d, Level %d, State %d, Procedure %s, Line %d, Message: ' + ERROR_MESSAGE() ;
--
--        RAISERROR( @errorMessage, @errorSeverity, 1
--                 , @codeBlockNum
--                 , @codeBlockDesc
--                 , @errorNumber
--                 , @errorSeverity
--                 , @errorState
--                 , @errorProcedure
--                 , @errorLine ) ;
--
--        SELECT  @errorMessage = ERROR_MESSAGE() ;
--
--        EXECUTE dbo.processEhlersError  @errorTypeID
--                                      , @codeBlockNum
--                                      , @codeBlockDesc
--                                      , @errorNumber
--                                      , @errorSeverity
--                                      , @errorState
--                                      , @errorProcedure
--                                      , @errorLine
--                                      , @errorMessage
--                                      , @errorData ;
--
--    END
--        ELSE
--    BEGIN
--        SELECT  @errorSeverity  = ERROR_SEVERITY()
--              , @errorState     = ERROR_STATE()
--
--        RAISERROR( @errorMessage, @errorSeverity, @errorState ) ;
--    END

END CATCH
END