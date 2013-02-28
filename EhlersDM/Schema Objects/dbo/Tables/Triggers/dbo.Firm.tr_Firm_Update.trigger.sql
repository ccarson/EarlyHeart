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
    3)  Stop processing when trigger is invoked by Conversion.processFirms
    4)  INSERT firm name changes onto edata.dbo.FirmHistory

    Notes:

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

BEGIN TRY 

    SET NOCOUNT ON ;

    DECLARE @processFirms AS VARBINARY(128) = CAST( 'processFirms' AS VARBINARY(128) ) ;
    

    DECLARE @codeBlockDesc01        AS VARCHAR (128)    = 'Stop processing unless FirmName has changed'
          , @codeBlockDesc02        AS VARCHAR (128)    = 'INSERT dbo.FirmNameHistory to reflect firm name change'
          , @codeBlockDesc03        AS VARCHAR (128)    = 'Stop processing when trigger is invoked by Conversion.processFirms' 
          , @codeBlockDesc04        AS VARCHAR (128)    = 'INSERT firm name changes onto edata.FirmHistory' ;


    DECLARE @codeBlockNum           AS INT
          , @codeBlockDesc          AS VARCHAR (128)
          , @errorTypeID            AS INT
          , @errorSeverity          AS INT
          , @errorState             AS INT
          , @errorNumber            AS INT
          , @errorLine              AS INT
          , @errorProcedure         AS VARCHAR (128)
          , @errorMessage           AS VARCHAR (MAX) = NULL
          , @errorData              AS VARCHAR (MAX) = NULL ;    


/**/SELECT  @codeBlockNum  = 1
/**/      , @codeBlockDesc = @codeBlockDesc01 ; -- Stop processing unless FirmName has changed
    IF  NOT EXISTS ( SELECT FirmID, FirmName FROM deleted
                        EXCEPT
                     SELECT FirmID, FirmName FROM inserted )
        RETURN ;


/**/SELECT  @codeBlockNum  = 2
/**/      , @codeBlockDesc = @codeBlockDesc02 ; -- INSERT dbo.FirmNameHistory to reflect firm name change
    INSERT  dbo.FirmNameHistory ( FirmID, FirmName, ModifiedDate, ModifiedUser )
    SELECT  d.FirmID, d.FirmName, i.ModifiedDate, i.ModifiedUser
      FROM  deleted  AS d
INNER JOIN  inserted AS i ON i.FirmID = d.FirmID AND i.FirmName <> d.FirmName ;


/**/SELECT  @codeBlockNum  = 3
/**/      , @codeBlockDesc = @codeBlockDesc03 ; -- Stop processing when trigger is invoked by Conversion.processFirms
    IF  CONTEXT_INFO() = @processFirms
        RETURN ;


/**/SELECT  @codeBlockNum  = 4
/**/      , @codeBlockDesc = @codeBlockDesc04 ; -- INSERT firm name changes onto edata.FirmHistory
    INSERT  edata.FirmHistory ( FirmID, FirmName, EffectiveDate, sequence )
    SELECT  d.FirmID, d.FirmName, i.ModifiedDate, 0
      FROM  deleted  AS d
INNER JOIN  inserted AS i ON i.FirmID = d.FirmID AND i.FirmName <> d.FirmName ;


END TRY
BEGIN CATCH
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
