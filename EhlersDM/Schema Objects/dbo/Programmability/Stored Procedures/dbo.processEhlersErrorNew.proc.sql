CREATE PROCEDURE dbo.processEhlersErrorNew ( @errorTypeID      AS INT
                                           , @codeBlockNum     AS INT
                                           , @codeBlockDesc    AS VARCHAR (128)
                                           , @errorNumber      AS INT
                                           , @errorSeverity    AS INT
                                           , @errorState       AS INT
                                           , @errorProcedure   AS VARCHAR (128)
                                           , @errorLine        AS INT
                                           , @errorMessage     AS VARCHAR (4000) 
                                           , @errorData        AS VARCHAR (MAX) )
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

    Notes:

************************************************************************************************************************************
*/
BEGIN
BEGIN TRY

    SET NOCOUNT ON ;

    DECLARE @body_format        AS VARCHAR (20)     = 'HTML'
          , @errorTime          AS DATETIME2 (7)    = SYSDATETIME() 
          , @databaseName       AS SYSNAME          = DB_NAME()
          , @profile_name       AS SYSNAME          = 'Ehlers SQL Server Data Manager'
          , @recipientEmail     AS VARCHAR (100) 
          , @serverName         AS SYSNAME          = @@SERVERNAME
          , @userName           AS SYSNAME          = dbo.udf_GetSystemUser() ;


    DECLARE @body               AS NVARCHAR(MAX)
          , @errorLogID         AS INT
          , @subject            AS VARCHAR (100) ;
          
    DECLARE @recipients         AS TABLE ( RecipientEMail VARCHAR (50) ) ; 
    
    INSERT  @recipients
    SELECT  RecipientEMail
      FROM  Meta.ErrorTypeRecipient
     WHERE  ErrorTypeID = @errorTypeID ;


--  1)  Throw application error when transaction is in an uncommitable state
    IF  XACT_STATE() = -1
    BEGIN
        SELECT  @errorProcedure = 'processEhlersError'
              , @subject        = @serverName + '.' + @databaseName + N' reports a processing error in ' + @errorProcedure
              , @body           = @serverName + '.' + @databaseName + N' cannot log the error because the current transaction is in '
                                + 'an uncommittable state. '
                                + @errorProcedure + ' code needs to execute a ROLLBACK before invoking processEhlersError.' ;
    END
        ELSE
    BEGIN 
--  2)  write error to log
        INSERT  dbo.SQLErrorLog (
                CodeBlockNum, CodeBlockDesc, ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure
                    , ErrorLine, ErrorMessage, ErrorData, ModifiedDate, ModifiedUser )
        SELECT  @codeBlockNum, @codeBlockDesc, @errorNumber, @errorSeverity, @errorState, @errorProcedure
                    , @errorLine, @errorMessage, @errorData, @errorTime, @userName ; 

        SELECT  @errorLogID = @@IDENTITY ;


--  3)  format DB mail documenting the error
        SELECT  @subject = @serverName + '.' + @databaseName + N' reports a processing error in ' + @errorProcedure
              , @body    = N'<H1>Database Error on ' + @serverName + '.' + @databaseName + '</H1>'
                         + N'<TABLE border="0">'
                         + N'<tr><td>Error Log Number:</td><td></td><td>'   + CAST( @errorLogID   AS VARCHAR(20) )    + '</td></tr>'
                         + N'<tr><td>Error Timestamp:</td><td></td><td>'    + CONVERT( VARCHAR(30), @errorTime, 121 ) + '</td></tr>'
                         + N'<tr><td>Procedure:</td><td></td><td>'          + @errorProcedure                         + '</td></tr>'
                         + N'<tr><td>Code Block:</td><td></td><td>'         + CAST( @codeBlockNum AS VARCHAR(20) )    + '</td></tr>'
                         + N'<tr><td>Code Description:</td><td></td><td>'   + @codeBlockDesc                          + '</td></tr>'
                         + N'<tr><td>Error Line:</td><td></td><td>'         + CAST( @errorLine    AS VARCHAR(20) )    + '</td></tr>'
                         + N'<tr><td>Error Code:</td><td></td><td><b>'      + CAST( @errorNumber  AS VARCHAR(20) )    + '</b></td></tr>'
                         + N'<tr><td>Error Message:</td><td></td><td><b>'   + @errorMessage                           + '</b></td></tr>'
                         + N'<tr></tr>'
                         + N'</TABLE></br>'
                         + N'<H2>All work from ' + @errorProcedure + ' has been rolled back.</H2>' ;

--  4)  attach supporting data if it's available
        IF  ( @errorData IS NULL )
            SELECT  @body = @body + N'<H2>' + @errorProcedure + N' did not return any supporting error data</H2>' ;
        ELSE
            SELECT  @body = @body + N'<H3>Here is the data from the error: </H3>' + @errorData ;
    END 
    
--  5)  Send Database Mail with formatted error information
    INSERT  @recipients
    SELECT  RecipientEMail
      FROM  Meta.ErrorTypeRecipient
     WHERE  ErrorTypeID = @errorTypeID ;
     
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
    SELECT  @errorTime      = SYSDATETIME()
          , @subject        = @serverName + '.' + @databaseName + N' reports a processing error in ' + ERROR_PROCEDURE()
          , @body = N'<H1>Database Error on ' + @serverName + '.' + @databaseName + '</H1>'
                  + N'<TABLE border="0">'
                  + N'<tr><td>Error Timestamp:</td><td></td><td>'   + CONVERT( VARCHAR(30), @errorTime, 121 ) + '</td></tr>'
                  + N'<tr><td>Procedure:</td><td></td><td>'         + ERROR_PROCEDURE()                       + '</td></tr>'
                  + N'<tr><td>Error Line:</td><td></td><td>Line: '  + CAST( ERROR_LINE() AS VARCHAR(20) )     + '</td></tr>'
                  + N'<tr><td>Error Code:</td><td></td><td>'        + CAST( ERROR_NUMBER() AS VARCHAR(20) )   + '</td></tr>'
                  + N'<tr><td>Error Message:</td><td></td><td>'     + ERROR_MESSAGE()                         + '</td></tr>'
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
        
END CATCH

END
