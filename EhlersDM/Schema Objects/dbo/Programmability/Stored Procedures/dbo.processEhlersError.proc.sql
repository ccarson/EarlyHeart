CREATE PROCEDURE dbo.processEhlersError ( @inpErrorTypeID       AS INT
                                        , @inpCodeBlockNum      AS INT
                                        , @inpCodeBlockDesc     AS SYSNAME
                                        , @inpErrorNumber       AS INT
                                        , @inpErrorSeverity     AS INT
                                        , @inpErrorState        AS INT
                                        , @inpErrorProcedure    AS SYSNAME
                                        , @inpErrorLine         AS INT
                                        , @inpErrorMessage      AS VARCHAR (MAX)
                                        , @inpErrorData         AS VARCHAR (MAX) )
AS
/*
************************************************************************************************************************************

  Procedure:    dbo.processEhlersError
     Author:    Chris Carson
    Purpose:    logs error data and sends out notification


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          adapted from AdventureWorks2008R2.dbo.uspLogError and AdventureWorks2008R2.dbo.uspPrintError
    ccarson         ###DATE###          format additional SQL Server error data

    Logic Summary:

    01) Throw application error on doomed transactions ( always a fatal error )
    02) Write the error data error to SQLErrorLog
    03) Format DBMail documenting the error
    04) Attach supporting data from calling procedure if it's available
    05) Send DBMail to each recipient for given error type

    Notes:

************************************************************************************************************************************
*/
BEGIN
BEGIN TRY

    SET NOCOUNT     ON ;
    SET XACT_ABORT  ON ;


    DECLARE @codeBlockNum       AS INT
          , @codeBlockDesc      AS SYSNAME
          , @codeBlockDesc01    AS SYSNAME          = 'Throw application error on doomed transactions ( always a fatal error )'
          , @codeBlockDesc02    AS SYSNAME          = 'Write the error data error to SQLErrorLog'
          , @codeBlockDesc03    AS SYSNAME          = 'Format DBMail documenting the error'
          , @codeBlockDesc04    AS SYSNAME          = 'Attach supporting data from calling procedure if it''s available'
          , @codeBlockDesc05    AS SYSNAME          = 'Send DBMail to each recipient for given error type' ;


    DECLARE @body_format        AS VARCHAR (20)     = 'HTML'
          , @errorTime          AS VARCHAR (30)     = SYSDATETIME()
          , @databaseName       AS SYSNAME          = DB_NAME()
          , @profile_name       AS SYSNAME          = 'Ehlers SQL Server Data Manager'
          , @recipientEmail     AS VARCHAR (100)
          , @serverName         AS SYSNAME          = @@SERVERNAME
          , @userName           AS SYSNAME          = dbo.udf_GetSystemUser() ;


    DECLARE @body               AS NVARCHAR(MAX)
          , @errorLogID         AS INT
          , @subject            AS VARCHAR (100) ;

    DECLARE @recipients         AS TABLE ( RecipientEMail VARCHAR (50) ) ;

/**/SELECT  @codeBlockNum   = 01
/**/      , @codeBlockDesc  = @codeBlockDesc01 ; --  Throw application error on doomed transactions ( always a fatal error )

    IF  XACT_STATE() = -1
    BEGIN
        SELECT  @inpErrorTypeID = 1 ;
        SELECT  @subject        = @serverName + '.' + @databaseName + N' reports a processing error in ' + @inpErrorProcedure
              , @body           = @serverName + '.' + @databaseName + N' dbo.processEhlersError cannot log the error because the '
                                + 'current transaction is in an uncommittable state.  The code in '
                                + @inpErrorProcedure + ' needs to execute a ROLLBACK before invoking dbo.processEhlersError.' ;
    END
        ELSE
    BEGIN

/**/SELECT  @codeBlockNum   = 02
/**/      , @codeBlockDesc  = @codeBlockDesc02 ; --  or, write the error data error to SQLErrorLog

        INSERT  dbo.SQLErrorLog (
                CodeBlockNum, CodeBlockDesc, ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure
                    , ErrorLine, ErrorMessage, ErrorData, ModifiedDate, ModifiedUser )
        SELECT  @inpCodeBlockNum, @inpCodeBlockDesc, @inpErrorNumber, @inpErrorSeverity, @inpErrorState, @inpErrorProcedure
                    , @inpErrorLine, @inpErrorMessage, @inpErrorData, CONVERT( DATETIME2(7), @errorTime ), @userName ;

        SELECT  @errorLogID = @@IDENTITY ;


/**/SELECT  @codeBlockNum   = 03
/**/      , @codeBlockDesc  = @codeBlockDesc03 ; --  format DBMail documenting the error

        SELECT  @subject = @serverName + '.' + @databaseName + N' reports a processing error in ' + @inpErrorProcedure
              , @body    = N'<H1>Database Error on ' + @serverName + '.' + @databaseName + '</H1>'
                         + N'<TABLE border="0">'
                         + N'<tr><td>Error Log Number:</td><td></td><td>'   + CAST( @errorLogID   AS VARCHAR(20) )      + '</td></tr>'
                         + N'<tr><td>Error Timestamp:</td><td></td><td>'    + @errorTime                                + '</td></tr>'
                         + N'<tr><td>Procedure:</td><td></td><td>'          + @inpErrorProcedure                        + '</td></tr>'
                         + N'<tr><td>Code Block:</td><td></td><td>'         + CAST( @inpCodeBlockNum AS VARCHAR(20) )   + '</td></tr>'
                         + N'<tr><td>Code Description:</td><td></td><td>'   + @inpCodeBlockDesc                         + '</td></tr>'
                         + N'<tr><td>Error Line:</td><td></td><td>'         + CAST( @inpErrorLine    AS VARCHAR(20) )   + '</td></tr>'
                         + N'<tr><td>Error Code:</td><td></td><td><b>'      + CAST( @inpErrorNumber  AS VARCHAR(20) )   + '</b></td></tr>'
                         + N'<tr><td>Error Message:</td><td></td><td><b>'   + @inpErrorMessage                          + '</b></td></tr>'
                         + N'<tr></tr>'
                         + N'</TABLE></br>'
                         + N'<H2>All work from ' + @inpErrorProcedure + ' has been rolled back.</H2></br>' ;


/**/SELECT  @codeBlockNum   = 04
/**/      , @codeBlockDesc  = @codeBlockDesc04 ; --  attach supporting data from calling procedure if it's available

        IF  ( @inpErrorData IS NULL )
            SELECT  @body = @body + N'<H2>' + @inpErrorProcedure + N' did not return any supporting error data</H2>' ;
        ELSE
            SELECT  @body = @body + N'<H3>Here is the data from the error: </H3>' + @inpErrorData ;
    END


/**/SELECT  @codeBlockNum   = 05
/**/      , @codeBlockDesc  = @codeBlockDesc05 ; --  send DBMail to each recipient

    INSERT  @recipients
    SELECT  RecipientEMail
      FROM  Meta.ErrorTypeRecipient
     WHERE  ErrorTypeID = @inpErrorTypeID ;

    WHILE EXISTS ( SELECT 1 FROM @recipients )
    BEGIN
        SELECT  TOP 1
                @recipientEmail = RecipientEMail
          FROM  @recipients ;

        EXECUTE msdb.dbo.sp_send_dbmail  @profile_name          =  @profile_name
                                       , @recipients            =  @recipientEmail
                                       , @subject               =  @subject
                                       , @body                  =  @body
                                       , @body_format           =  @body_format
                                       , @exclude_query_output  = 1 ;

        DELETE @recipients WHERE RecipientEMail = @recipientEmail ;
    END


END TRY
BEGIN CATCH

    DECLARE @errorSeverity          AS INT              = ERROR_SEVERITY()
          , @errorState             AS INT              = ERROR_STATE()
          , @errorNumber            AS INT              = ERROR_NUMBER()
          , @errorLine              AS INT              = ERROR_LINE()
          , @errorProcedure         AS SYSNAME          = ERROR_PROCEDURE()
          , @errorMessage           AS VARCHAR (MAX)    = ERROR_MESSAGE()
          , @formattedErrorMessage  AS VARCHAR (MAX)    = NULL ;

    SELECT  @formattedErrorMessage = N'Error occurred in Code Block %d, %s ' + CHAR(13)
                                   + N'Error %d, Level %d, State %d, Procedure %s, Line %d, Message: ' + ERROR_MESSAGE() ;

    INSERT  dbo.SQLErrorLog (
            CodeBlockNum, CodeBlockDesc, ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure
                , ErrorLine, ErrorMessage, ErrorData, ModifiedDate, ModifiedUser )
    SELECT  @codeBlockNum, @codeBlockDesc, @errorNumber, @errorSeverity, @errorState, @errorProcedure
                , @errorLine, @errorMessage, NULL, CONVERT( DATETIME2(7), @errorTime ), @userName ;

    SELECT  @errorLogID = @@IDENTITY ;


    SELECT  @subject        = @serverName + '.' + @databaseName + N' reports a processing error in ' + ERROR_PROCEDURE()
          , @body = N'<H1>Database Error on ' + @serverName + '.' + @databaseName + '</H1>'
                  + N'<TABLE border="0">'
                  + N'<tr><td>Error Log Number:</td><td></td><td>'   + CAST( @errorLogID   AS VARCHAR(20) ) + '</td></tr>'
                  + N'<tr><td>Error Timestamp:</td><td></td><td>'   + @errorTime                            + '</td></tr>'
                  + N'<tr><td>Procedure:</td><td></td><td>'         + ERROR_PROCEDURE()                     + '</td></tr>'
                  + N'<tr><td>Error Line:</td><td></td><td>Line: '  + CAST( ERROR_LINE() AS VARCHAR(20) )   + '</td></tr>'
                  + N'<tr><td>Error Code:</td><td></td><td>'        + CAST( ERROR_NUMBER() AS VARCHAR(20) ) + '</td></tr>'
                  + N'<tr><td>Error Message:</td><td></td><td>'     + ERROR_MESSAGE()                       + '</td></tr>'
                  + N'</TABLE>' ;

    DELETE  @recipients ;

    INSERT  @recipients
    SELECT  RecipientEMail
      FROM  Meta.ErrorTypeRecipient
     WHERE  ErrorTypeID = 1 ;

    WHILE EXISTS ( SELECT 1 FROM @recipients )
    BEGIN
        SELECT  TOP 1
                @recipientEmail = RecipientEMail
          FROM  @recipients ;

        EXECUTE msdb.dbo.sp_send_dbmail  @profile_name  =  @profile_name
                                       , @recipients    =  @recipientEmail
                                       , @subject       =  @subject
                                       , @body          =  @body
                                       , @body_format   =  @body_format
                                       , @exclude_query_output  = 1 ;

        DELETE @recipients WHERE RecipientEMail = @recipientEmail ;
    END

    RAISERROR( @formattedErrorMessage, @errorSeverity, @codeBlockNum
             , @codeBlockNum
             , @codeBlockDesc
             , @errorNumber
             , @errorSeverity
             , @errorState
             , @errorProcedure
             , @errorLine ) ;

END CATCH
END
