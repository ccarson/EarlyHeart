CREATE PROCEDURE dbo.processEhlersError( @processName   AS VARCHAR(100)  = NULL
                                       , @errorMessage  AS NVARCHAR(MAX) = NULL
                                       , @errorQuery    AS NVARCHAR(MAX) = NULL )

AS
/*
************************************************************************************************************************************

  Procedure:    dbo.processEhlersError
     Author:    Chris Carson
                Original Code: Microsoft ( AdventureWorks )
    Purpose:    log error data to ErrorLog table


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          adapted from AdventureWorks2008R2.dbo.uspLogError and AdventureWorks2008R2.dbo.uspPrintError

    Logic Summary:

    Notes:

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;

--  Constants
    DECLARE @body_format        AS VARCHAR (20)     = 'HTML'
          , @errorTime          AS VARCHAR (30)     = CONVERT( VARCHAR(30), SYSDATETIME(), 121 )
          , @databaseName       AS NVARCHAR(128)    = DB_NAME()
          , @profile_name       AS SYSNAME          = 'Ehlers SQL Server Data Manager'
          , @recipients         AS VARCHAR (100)    = 'ccarson@ehlers-inc.com'
          , @serverName         AS NVARCHAR(128)    = @@SERVERNAME
          , @userName           AS SYSNAME          = dbo.udf_GetSystemUser() ;

--  Formatted by CATCH block on SQL Server errors
    DECLARE @errorLine          AS VARCHAR (20)
          , @errorNumber        AS VARCHAR (20)
          , @errorProcedure     AS SYSNAME
          , @errorSeverity      AS VARCHAR (20)
          , @errorState         AS VARCHAR (20)
          , @SQLErrorMessage    AS NVARCHAR(4000) ;

--  Formatted by error-handling routine
    DECLARE @body               AS NVARCHAR(MAX)
          , @errorLogID         AS INT
          , @rc                 AS INT              = 0
          , @subject            AS VARCHAR (100) ;


    BEGIN TRY
--  1)  Load SQL Server error values ( will be NULL if the error is an application error )
    SELECT  @errorLine       = CAST( ERROR_LINE()     AS VARCHAR(20) )
          , @errorNumber     = CAST( ERROR_NUMBER()   AS VARCHAR(20) )
          , @errorProcedure  = ERROR_PROCEDURE()
          , @errorSeverity   = CAST( ERROR_SEVERITY() AS VARCHAR(20) )
          , @errorState      = CAST( ERROR_STATE()    AS VARCHAR(20) )
          , @SQLErrorMessage = ERROR_MESSAGE() ;

--  2)  Format Database Mail depending on processing either application error or SQL Server error
    IF  @errorNumber IS NULL
        SELECT  @subject    = QUOTENAME( @serverName ) + N' reports a processing error in ' + @processName
              , @body       = N'<H1>Ehlers Database Application Error</H1>'
                            + N'<TABLE border="0">'
                            + N'<tr><td>Process:</td><td></td><td>'       + @processName  + '</td></tr>'
                            + N'<tr><td>SQL Server:</td><td></td><td>'    + @serverName   + '</td></tr>'
                            + N'<tr><td>Database:</td><td></td><td>'      + @databaseName + '</td></tr>'
                            + N'<tr><td>Occurred:</td><td></td><td>'      + @errorTime    + '</td></tr>'
                            + N'<tr><td>Error Message:</td><td></td><td>' + @errorMessage + '</td></tr>'
                            + N'</TABLE>' ;
    ELSE
        SELECT  @subject    = QUOTENAME( @serverName ) + N'reports a SQL Server error on ' + @databaseName
              , @body       = N'<H1>SQL Server Error on ' + QUOTENAME( @serverName ) + '</H1>'
                            + N'<TABLE border="0">'
                            + N'<tr><td>Error Timestamp:</td><td></td><td>'  + @errorTime       + '</td></tr>'
                            + N'<tr><td>SQL Server:</td><td></td><td>'       + @serverName      + '</td></tr>'
                            + N'<tr><td>Database:</td><td></td><td>'         + @databaseName    + '</td></tr>'
                            + N'<tr><td>Procedure:</td><td></td><td>'        + @errorProcedure  + '</td></tr>'
                            + N'<tr><td>Error Line:</td><td></td><td>Line: ' + @errorLine       + '</td></tr>'
                            + N'<tr><td>Error Code:</td><td></td><td>'       + @errorNumber     + '</td></tr>'
                            + N'<tr><td>Error Message:</td><td></td><td>'    + @SQLErrorMessage + '</td></tr>'
                            + N'<tr></tr>'
                            + N'<tr><b>Any transactions related to this error have been rolled back.</b></tr>'
                            + N'</TABLE>' ;

--  3)  When calling application includes query results, append query results to the formatted database mail
    SELECT  @body = ISNULL( @body + N'<H2>See attached query results for details</H2>' + @errorQuery, @body ) ;

--  4)  Throw application error when transaction is in an uncommitable state
    IF  XACT_STATE() = -1
        SELECT  @processName  = 'logEhlersSQLError'
              , @subject      = QUOTENAME( @serverName ) + N' reports a processing error in ' + @processName
              , @body         = @serverName + ' is trying to log an error, but the current transaction is in '
                              + 'an uncommittable state. '
                              + 'Application code needs to execute a ROLLBACK before invoking logEhlersSQLError.' ;
    ELSE
--  5)  Log SQL Server database errors
        INSERT  dbo.SQLErrorLog (
                ModifiedDate, ModifiedUser, ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage )
        SELECT  SYSDATETIME(), @userName, @errorState, @errorNumber, @errorSeverity, @errorProcedure, @errorLine, @SQLErrorMessage
         WHERE  @errorNumber IS NOT NULL ;

    SELECT  @errorLogID = @@IDENTITY ;

    IF  @errorNumber IS NULL
        PRINT   'Application Error thrown by ' + @processName + ' check with system administrators.' ;
    ELSE
        PRINT   'SQL Server Error Log Entry # ' + CAST( @ErrorLogID AS VARCHAR(20) ) + ' recorded.' ;

--  6)  Send Database Mail with formatted error information
    EXECUTE msdb.dbo.sp_send_dbmail  @profile_name  =  @profile_name
                                   , @recipients    =  @recipients
                                   , @subject       =  @subject
                                   , @body          =  @body
                                   , @body_format   =  @body_format ;

    END TRY
    BEGIN CATCH
        SELECT  @errorNumber     = CAST( ERROR_NUMBER()   AS VARCHAR(20) )
              , @errorProcedure  = ERROR_PROCEDURE()
              , @errorLine       = CAST( ERROR_LINE()     AS VARCHAR(20) )
              , @SQLErrorMessage = ERROR_MESSAGE()
              , @processName     = 'logEhlersSQLError'
              , @subject         = QUOTENAME( @serverName ) + N' reports a processing error in ' + @processName
              , @body = N'<H1>SQL Server Error</H1>'
                      + N'<TABLE border="0">'
                      + N'<tr><td>Error Timestamp:</td><td></td><td>'   + @errorTime       + '</td></tr>'
                      + N'<tr><td>SQL Server:</td><td></td><td>'        + @serverName      + '</td></tr>'
                      + N'<tr><td>Database:</td><td></td><td>'          + @databaseName    + '</td></tr>'
                      + N'<tr><td>Procedure:</td><td></td><td>'         + @errorProcedure  + '</td></tr>'
                      + N'<tr><td>Error Line:</td><td></td><td>Line: '  + @errorLine       + '</td></tr>'
                      + N'<tr><td>Error Code:</td><td></td><td>'        + @errorNumber     + '</td></tr>'
                      + N'<tr><td>Error Message:</td><td></td><td>'     + @SQLErrorMessage + '</td></tr>'
                      + N'</TABLE>' ;

        EXECUTE msdb.dbo.sp_send_dbmail  @profile_name  =  @profile_name
                                       , @recipients    =  @recipients
                                       , @subject       =  @subject
                                       , @body          =  @body
                                       , @body_format   =  @body_format ;

        RETURN - 1 ;
    END CATCH

    RETURN 0 ;
END
