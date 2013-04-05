CREATE TRIGGER  tr_FirmCategories
            ON  dbo.FirmCategories
AFTER INSERT, UPDATE, DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_FirmCategories
     Author:    Chris Carson
    Purpose:    writes FirmCategories changes back to legacy dbo.Firms


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created
    ccarson         ###DATE###          revised error reporting

    Logic Summary:
    1)  Stop processing when trigger is invoked by Conversion.processFirmCategories
    2)  INSERT FirmID and ModifiedUser into temp storage
    3)  UPDATE temp storage with legacy version of FirmCategory data
    4)  UPDATE edata.Firms.FirmCategory with new data

    Notes:
        legacy firms are updated with legacy version ( comma-separated list ) of converted FirmCategories data

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

BEGIN TRY


    SET NOCOUNT ON ;

    DECLARE @fromConversion AS VARBINARY (128) = CAST( 'fromConversion' AS VARBINARY (128) ) ;


    DECLARE @codeBlockDesc01        AS SYSNAME    = 'Stop processing when trigger is invoked by Conversion.processFirmCategories'
          , @codeBlockDesc02        AS SYSNAME    = 'INSERT FirmID and ModifiedUser into temp storage'
          , @codeBlockDesc03        AS SYSNAME    = 'UPDATE temp storage with legacy version of FirmCategory data'
          , @codeBlockDesc04        AS SYSNAME    = 'UPDATE edata.Firms.FirmCategory with new data' ;


    DECLARE @codeBlockNum           AS INT
          , @codeBlockDesc          AS SYSNAME
          , @errorTypeID            AS INT
          , @errorSeverity          AS INT
          , @errorState             AS INT
          , @errorNumber            AS INT
          , @errorLine              AS INT
          , @errorProcedure         AS SYSNAME
          , @errorMessage           AS VARCHAR (MAX) = NULL
          , @errorData              AS VARCHAR (MAX) = NULL ;


    DECLARE @changedData           AS TABLE ( FirmID        INT
                                            , FirmCategory  VARCHAR (50)
                                            , ModifiedUser  VARCHAR (20)
                                            , ModifiedDate  DATETIME ) ;


/**/SELECT  @codeBlockNum   = 1
/**/      , @codeBlockDesc  = @codeBlockDesc01 ; -- Stop processing when trigger is invoked by Conversion.processFirmCategories

    IF  CONTEXT_INFO() = @fromConversion
        RETURN ;



/**/SELECT  @codeBlockNum   = 2
/**/      , @codeBlockDesc  = @codeBlockDesc02 ; -- INSERT FirmID and ModifiedUser into temp storage

    INSERT  @changedData ( FirmID, ModifiedUser, ModifiedDate )
    SELECT  DISTINCT FirmID, ModifiedUser, ModifiedDate
      FROM  inserted ;

    INSERT  @changedData ( FirmID, ModifiedUser, ModifiedDate )
    SELECT  DISTINCT FirmID, ModifiedUser, ModifiedDate
      FROM  deleted
     WHERE  FirmID NOT IN ( SELECT FirmID FROM inserted ) ;



/**/SELECT  @codeBlockNum   = 3
/**/      , @codeBlockDesc  = @codeBlockDesc03 ; -- UPDATE temp storage with legacy version of FirmCategory data

    UPDATE  @changedData
       SET  FirmCategory = ISNULL( b.FirmCategory, '' )
      FROM  @changedData AS a
 LEFT JOIN  Conversion.tvf_LegacyFirmCategories ( 'Converted' ) AS b ON b.FirmID = a.FirmID



/**/SELECT  @codeBlockNum   = 4
/**/      , @codeBlockDesc  = @codeBlockDesc04 ; -- UPDATE edata.Firms.FirmCategory with new data
    UPDATE  edata.Firms
       SET  FirmCategory = c.FirmCategory
          , ChangeBy     = c.ModifiedUser
          , ChangeDate   = c.ModifiedDate
          , ChangeCode   = 'cvFirmCat'
      FROM  edata.Firms AS f
INNER JOIN  @changedData    AS c ON c.FirmID = f.FirmID ;


END TRY
BEGIN CATCH
    SELECT  @errorData = '<b>contents of temp storage</b></br></br>'
                       + '<table border="1">'
                       + '<tr><th>FirmID</th><th>FirmCategory data</th>'
                       + '<th>ModifiedDate</th><th>ModifiedUser</th></tr>'
                       + CAST ( ( SELECT  td = FirmID, ''
                                        , td = FirmCategory, ''
                                        , td = ModifiedDate, ''
                                        , td = ModifiedUser, ''
                                    FROM  @changedData
                                     FOR XML PATH('tr'), TYPE ) AS VARCHAR(MAX) )
                       + N'</table>' ;

    ROLLBACK TRANSACTION ;

    SELECT  @errorTypeID    = 1
          , @errorSeverity  = ERROR_SEVERITY()
          , @errorState     = ERROR_STATE()
          , @errorNumber    = ERROR_NUMBER()
          , @errorLine      = ERROR_LINE()
          , @errorProcedure = ISNULL( ERROR_PROCEDURE(), '-' )

    IF  @errorMessage IS NULL
    BEGIN
        SELECT  @errorMessage = N'Error occurred in Code Block %d, %s ' + CHAR(13)
                              + N'Error %d, Level %d, State %d, Procedure %s, Line %d, Message: ' + ERROR_MESSAGE() ;

        RAISERROR( @errorMessage, @errorSeverity, 1
                 , @codeBlockNum
                 , @codeBlockDesc
                 , @errorNumber
                 , @errorSeverity
                 , @errorState
                 , @errorProcedure
                 , @errorLine ) ;

        SELECT  @errorMessage = ERROR_MESSAGE() ;

        EXECUTE dbo.processEhlersError  @errorTypeID
                                      , @codeBlockNum
                                      , @codeBlockDesc
                                      , @errorNumber
                                      , @errorSeverity
                                      , @errorState
                                      , @errorProcedure
                                      , @errorLine
                                      , @errorMessage
                                      , @errorData ;

    END
        ELSE
    BEGIN
        SELECT  @errorSeverity  = ERROR_SEVERITY()
              , @errorState     = ERROR_STATE()

        RAISERROR( @errorMessage, @errorSeverity, @errorState ) ;
    END

END CATCH
END
