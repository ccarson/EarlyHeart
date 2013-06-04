CREATE TRIGGER  tr_FirmContacts_Delete
            ON  dbo.FirmContacts
AFTER DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    tr_FirmContacts_Delete
     Author:    Chris Carson
    Purpose:    Drops legacy FirmContacts records after deletion in Firm application

    revisor         date                description
    ---------       ----------          ----------------------------
    ccarson         2013-01-24          created
    ccarson         ###DATE###          revised error handling

    Logic Summary:
    1)  DELETE edata.FirmContacts based on trigger data
    2)  DELETE Conversion.LegacyContacts based on trigger data

************************************************************************************************************************************
*/
BEGIN
BEGIN TRY

    IF  NOT EXISTS ( SELECT 1 FROM deleted )
        RETURN ;

    SET NOCOUNT ON ;

    DECLARE @codeBlockNum       AS INT
          , @codeBlockDesc      AS SYSNAME
          , @codeBlockDesc01    AS SYSNAME  = 'DELETE edata.FirmContacts based on trigger data'
          , @codeBlockDesc02    AS SYSNAME  = 'DELETE Conversion.LegacyContacts based on trigger data' ;

    DECLARE @systemUser AS VARCHAR(20) = dbo.udf_GetSystemUser() ;

/**/SELECT  @codeBlockNum = 01, @codeBlockDesc = @codeBlockDesc01 ; --  DELETE edata.FirmContacts based on trigger data
    DELETE  edata.FirmContacts
     WHERE  ContactID IN ( SELECT LegacyContactID FROM Conversion.LegacyContacts
                            WHERE LegacyTableName = 'FirmContacts'
                              AND ContactID IN ( SELECT ContactID FROM deleted ) ) ;



/**/SELECT  @codeBlockNum = 02, @codeBlockDesc = @codeBlockDesc02 ; --  DELETE Conversion.LegacyContacts based on trigger data
    DELETE  Conversion.LegacyContacts
     WHERE  ContactID IN ( SELECT ContactID FROM deleted ) ;

     

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

    SELECT  @errorData = '<b>contents of deleted trigger table</b></br></br>'
                       + '<table border="1">'
                       + '<tr><th>FirmContactsID</th><th>FirmID</th><th>ContactID</th>'
                       + '<th>ModifiedDate</th><th>ModifiedUser</th></tr>'
                       + CAST ( ( SELECT  td = FirmContactsID, ''
                                        , td = FirmID, ''
                                        , td = ContactID, ''
                                        , td = ModifiedDate, ''
                                        , td = ModifiedUser, ''
                                    FROM  deleted
                                     FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
                       + N'</table></br></br>' ;

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
