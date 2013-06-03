CREATE TRIGGER  tr_Firm_Update
            ON  dbo.Firm
AFTER UPDATE
AS
/*
************************************************************************************************************************************

    Trigger:    tr_Firm_Update
     Author:    Chris Carson
    Purpose:    writes FirmNameHistory records to reflect Firm name changes


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created
    ccarson         ###DATE###          revised error reporting

    Logic Summary:
    1)  Stop processing unless FirmName has changed
    2)  INSERT dbo.FirmNameHistory to reflect firm name change
    3)  Stop processing when trigger is fired from Conversion
    4)  INSERT firm name changes onto edata.FirmHistory

    Notes:

************************************************************************************************************************************
*/
BEGIN
BEGIN TRY

    IF  NOT EXISTS ( SELECT 1 FROM inserted )
        IF  NOT EXISTS ( SELECT 1 FROM deleted )
            RETURN ;

    SET NOCOUNT ON ;

    DECLARE @codeBlockNum       AS INT
          , @codeBlockDesc      AS SYSNAME
          , @codeBlockDesc01    AS SYSNAME  = 'Stop processing unless FirmName has changed'
          , @codeBlockDesc02    AS SYSNAME  = 'INSERT dbo.FirmNameHistory to reflect firm name change'
          , @codeBlockDesc03    AS SYSNAME  = 'Stop processing when trigger is fired from Conversion'
          , @codeBlockDesc04    AS SYSNAME  = 'INSERT firm name changes onto edata.FirmHistory' ;

    DECLARE @fromConversion     AS VARBINARY (128)  = CAST( 'fromConversion' AS VARBINARY (128) ) ;



/**/SELECT  @codeBlockNum = 1, @codeBlockDesc = @codeBlockDesc01 ; -- Stop processing unless FirmName has changed
    IF  NOT EXISTS ( SELECT 1 FROM inserted AS i INNER JOIN deleted AS d ON d.FirmID = i.FirmID
                      WHERE d.FirmName <> i.FirmName )
        RETURN ;



/**/SELECT  @codeBlockNum = 2, @codeBlockDesc = @codeBlockDesc02 ; -- INSERT dbo.FirmNameHistory to reflect firm name change
    INSERT  dbo.FirmNameHistory ( FirmID, FirmName, ModifiedDate, ModifiedUser )
    SELECT  d.FirmID, d.FirmName, i.ModifiedDate, i.ModifiedUser
      FROM  deleted  AS d
INNER JOIN  inserted AS i ON i.FirmID = d.FirmID AND i.FirmName <> d.FirmName ;



/**/SELECT  @codeBlockNum = 3, @codeBlockDesc = @codeBlockDesc03 ; -- Stop processing when trigger is fired from Conversion
    IF  CONTEXT_INFO() = @fromConversion
        RETURN ;



/**/SELECT  @codeBlockNum = 4, @codeBlockDesc = @codeBlockDesc04 ; -- INSERT firm name changes onto edata.FirmHistory
    INSERT  edata.FirmHistory ( FirmID, FirmName, EffectiveDate, sequence )
    SELECT  d.FirmID, d.FirmName, i.ModifiedDate, 0
      FROM  deleted  AS d
INNER JOIN  inserted AS i ON i.FirmID = d.FirmID AND i.FirmName <> d.FirmName ;



END TRY
BEGIN CATCH

    DECLARE @errorTypeID            AS INT              = 1
          , @errorSeverity          AS INT              = ERROR_SEVERITY()
          , @errorState             AS INT              = ERROR_STATE()
          , @errorNumber            AS INT              = ERROR_NUMBER()
          , @errorLine              AS INT              = ERROR_LINE()
          , @errorProcedure         AS SYSNAME          = ERROR_PROCEDURE()
          , @errorMessage           AS VARCHAR (MAX)
          , @formattedErrorMessage  AS VARCHAR (MAX)    = NULL
          , @errorData              AS VARCHAR (MAX)    = NULL ;

    SELECT  @errorData = '<b>firm name history changes</b></br></br>'
                       + '<table border="1">'
                       + '<tr><th>FirmID</th><th>OldFirmName</th><th>NewFirmName</th>'
                       + '<th>ModifiedDate</th><th>ModifiedUser</th></tr>'
                       + CAST ( ( SELECT  td = d.FirmID       , ''
                                        , td = d.FirmName     , ''
                                        , td = i.FirmName     , ''
                                        , td = i.ModifiedDate , ''
                                        , td = i.ModifiedUser , ''
                                    FROM  deleted  AS d
                              INNER JOIN  inserted AS i ON i.FirmID = d.FirmID
                                   WHERE  i.FirmName <> d.FirmName
                                     FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
                       + '</table>' ;

    ROLLBACK TRANSACTION ;

    IF  @errorMessage IS NULL
    BEGIN
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


        SELECT  @formattedErrorMessage = N'Error occurred in Code Block %d, %s ' + CHAR(13)
                                       + N'Error %d, Level %d, State %d, Procedure %s, Line %d, Message: %s ' ;

        RAISERROR( @formattedErrorMessage, @errorSeverity, @codeBlockNum
                 , @codeBlockNum
                 , @codeBlockDesc
                 , @errorNumber
                 , @errorSeverity
                 , @errorState
                 , @errorProcedure
                 , @errorLine
                 , @errorMessage ) ;

    END
        ELSE
    BEGIN
        SELECT  @errorMessage   = ERROR_MESSAGE()
              , @errorSeverity  = ERROR_SEVERITY()
              , @errorState     = ERROR_STATE()

        RAISERROR( @errorMessage, @errorSeverity, @errorState ) ;
    END

END CATCH
END
