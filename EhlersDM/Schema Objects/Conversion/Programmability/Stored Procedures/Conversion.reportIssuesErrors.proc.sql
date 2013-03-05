CREATE PROCEDURE Conversion.reportIssuesErrors
AS
/*
************************************************************************************************************************************

  Procedure:    Conversion.reportIssuesErrors
     Author:    Chris Carson
    Purpose:    creates exception report for Issues that cannot convert


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  SELECT error counts from edata.Issues and edata.Clients
    2)  Exit if there are no errors
    3)  INSERT orphan Issues records into @errorRecords
    4)  SELECT error report data from @errorRecords for Orphan Issues report
    5)  Invoke error processing routine to mail out error report
    6)  INSERT invalid ObligorClientID issues into @errorRecords
    7)  SELECT error report data from @errorRecords for invalid ObligorClientID records
    8)  Invoke error processing routine to mail out error report
    9)  Validate control counts
   10)  Print control totals


    Notes:

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;

    DECLARE @rc                 AS INT          = 0
          , @processName        AS VARCHAR(100) = 'reportIssuesErrors'
          , @errorMessage       AS VARCHAR(MAX) = NULL
          , @errorQuery         AS VARCHAR(MAX) = NULL ;


    DECLARE @orphanErrorCount   AS INT = 0
          , @orphanErrorActual  AS INT = 0
          , @obligorErrorCount  AS INT = 0
          , @obligorErrorActual AS INT = 0 ;


    DECLARE @errorRecords       AS TABLE ( IssueID          INT
                                         , IssuerName       VARCHAR (120)
                                         , IssueName        VARCHAR (150)
                                         , DatedDate        DATE
                                         , IssueStatus      VARCHAR (50)
                                         , Amount           DECIMAL (19, 4)
                                         , ClientID         INT
                                         , ObligorClientID  INT ) ;


--  1)  SELECT error counts from edata.Issues and edata.Clients
BEGIN TRY
    SELECT  @orphanErrorCount = COUNT(*)
      FROM  edata.Issues AS i
     WHERE  NOT EXISTS ( SELECT 1 FROM edata.Clients AS c WHERE c.ClientID = i.ClientID ) ;

    SELECT  @obligorErrorCount = COUNT(*)
      FROM  edata.Issues AS i
     WHERE  i.ObligorClientID IS NOT NULL
       AND  EXISTS ( SELECT 1 FROM edata.Clients AS c WHERE c.ClientID = i.ClientID )
       AND  NOT EXISTS ( SELECT 1 FROM edata.Clients AS c WHERE c.ClientID = i.ObligorClientID ) ;


--  2)  Exit if there are no errors
    IF  ( @orphanErrorCount  = 0 )
        AND
        ( @obligorErrorCount = 0 )
    BEGIN
        PRINT 'No Issue errors found, exiting' ;
    END


--  3)  INSERT orphan Issues records into @errorRecords
    INSERT  @errorRecords
    SELECT  IssueID                 =  i.IssueID
          , IssuerName              =  i.IssuerName
          , IssueName               =  ISNULL( i.IssueName,'' )
          , DatedDate               =  i.DatedDate
          , IssueStatus             =  i.IssueStatus
          , Amount                  =  ISNULL( i.Amount, 0.00 )
          , ClientID                =  i.ClientID
          , ObligorClientID         =  NULL
      FROM  edata.Issues AS i
     WHERE  NOT EXISTS ( SELECT 1 FROM edata.Clients AS c WHERE c.ClientID = i.ClientID ) ;
    SELECT  @orphanErrorActual = @@ROWCOUNT ;


--  4)  SELECT error report data from @errorRecords for Orphan Issues report
    SELECT  @errorMessage = '</br><H2><b>These issues will not convert.</b></H2></br></br>'
                          + '<b>Instructions for resolving reported errors:</b></br>'
                          + '<b><i>( requires assistance from system support )</i></b></br>'
                          + '&nbsp;&nbsp;1)&nbsp;&nbsp;Manually find the issuer in the Client application </br>'
                          + '&nbsp;&nbsp;2)&nbsp;&nbsp;Update the legacy issue with the ClientID from the Client application </br></br>'
                          + '<b><i>OR</i></b></br>'
                          + '&nbsp;&nbsp;1)&nbsp;&nbsp;Create a new Client for the affected Issue</br>'
                          + '&nbsp;&nbsp;2)&nbsp;&nbsp;Update the legacy issue with the ClientID from the Client application </br></br>'
          , @errorQuery   = N'<H2>The following Issues do not have Client data in the new system </H2>' +
                            N'<table border="1">' +
                            N'<tr><th>IssueID</th><th>IssuerName</th><th>IssueName</th><th>DatedDate</th>' +
                            N'<th>IssueStatus</th><th>Amount</th><th>ClientID</th></tr>' +
                            CAST ( ( SELECT td = IssueID, ''
                                          , td = IssuerName, ''
                                          , td = IssueName, ''
                                          , td = DatedDate, ''
                                          , td = IssueStatus, ''
                                          , td = Amount, ''
                                          , td = ClientID
                                       FROM @errorRecords
                                      ORDER BY 3, 7, 1
                                        FOR XML PATH('tr'), TYPE ) AS NVARCHAR(MAX) ) +
                            N'</table>' ;


--  5)  Invoke error processing routine to mail out error report
    IF  ( @orphanErrorActual <> 0 )
        EXECUTE dbo.processEhlersError    @processName
                                        , @errorMessage
                                        , @errorQuery ;


--  6)  INSERT invalid ObligorClientID issues into @errorRecords
    INSERT  @errorRecords
    SELECT  IssueID                 =  i.IssueID
          , IssuerName              =  i.IssuerName
          , IssueName               =  ISNULL( i.IssueName,'' )
          , DatedDate               =  i.DatedDate
          , IssueStatus             =  i.IssueStatus
          , Amount                  =  ISNULL( i.Amount, 0.00 )
          , ClientID                =  i.ClientID
          , ObligorClientID         =  i.ObligorClientID
      FROM  edata.Issues AS i
     WHERE  ObligorClientID IS NOT NULL
       AND  EXISTS ( SELECT 1 FROM edata.Clients AS c WHERE c.ClientID = i.ClientID )
       AND  NOT EXISTS ( SELECT 1 FROM edata.Clients AS c WHERE c.ClientID = i.ObligorClientID ) ;
    SELECT  @obligorErrorActual = @@ROWCOUNT ;


--  7)  SELECT error report data from @errorRecords for invalid ObligorClientID records
    SELECT  @errorMessage = '</br><H2><b>These issues have invalid ObligorClientIDs</b></H2></br></br>'
                          + '<b>Instructions for resolving reported errors:</b></br>'
                          + '&nbsp;&nbsp;1)&nbsp;&nbsp;Identify the correct ObligorClient for the issue </br>'
                          + '&nbsp;&nbsp;2)&nbsp;&nbsp;Update the Issue with the correct ObligorClientID </br></br>'
                          + '<b><i>OR</i></b></br></br>'
                          + '&nbsp;&nbsp;1)&nbsp;&nbsp;Use the legacy Issues application to remove the ObligorClientID</br>'
          , @errorQuery   = N'<H2>The following Issues have an invalid ObligorClientID</H2>' +
                            N'<table border="1">' +
                            N'<tr><th>IssueID</th><th>IssuerName</th><th>IssueName</th><th>DatedDate</th>' +
                            N'<th>IssueStatus</th><th>Amount</th><th>ClientID</th><th>ObligorClientID</th></tr>' +
                            CAST ( ( SELECT td = IssueID, ''
                                          , td = IssuerName, ''
                                          , td = IssueName, ''
                                          , td = DatedDate, ''
                                          , td = IssueStatus, ''
                                          , td = Amount, ''
                                          , td = ClientID, ''
                                          , td = ObligorClientID
                                       FROM @errorRecords
                                      ORDER BY 3, 7, 1
                                        FOR XML PATH('tr'), TYPE ) AS NVARCHAR(MAX) ) +
                            N'</table>' ;


--  8)  Invoke error processing routine to mail out error report
    IF  ( @obligorErrorActual <> 0 )
        EXECUTE dbo.processEhlersError    @processName
                                        , @errorMessage
                                        , @errorQuery ;


--  9)  Validate control counts
    IF  ( @orphanErrorCount <> @orphanErrorActual )
        OR
        ( @obligorErrorCount <> @obligorErrorActual )
    BEGIN
        PRINT 'Control Totals Error!  Please review counts and processing!' ;
        PRINT '@orphanErrorCount         = ' + STR( @orphanErrorCount, 8 ) ;
        PRINT '@orphanErrorActual        = ' + STR( @orphanErrorActual, 8 ) ;
        PRINT ''
        PRINT '@obligorErrorCount        = ' + STR( @obligorErrorCount, 8 ) ;
        PRINT '@obligorErrorActual       = ' + STR( @obligorErrorActual, 8 ) ;
        PRINT ''

        SELECT  @rc = 0 ;
    END


END TRY
BEGIN CATCH
    EXECUTE dbo.processEhlersError ;
    RETURN  16 ;
END CATCH


endOfProc:
-- 10)  Print control totals
    PRINT 'Conversion.reportIssuesErrors ' ;
    PRINT 'CONTROL TOTALS ' ;
    PRINT '    Legacy Issues that can not be converted = ' + STR( @orphanErrorCount, 8 ) ;
    PRINT '' ;
    PRINT '    Legacy Issues with invalid ObligorClientID = ' + STR( @obligorErrorCount, 8 ) ;
    PRINT '' ;

    RETURN @rc ;
END