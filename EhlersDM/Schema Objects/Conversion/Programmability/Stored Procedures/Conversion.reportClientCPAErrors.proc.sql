CREATE PROCEDURE Conversion.reportClientCPAErrors
AS
/*
************************************************************************************************************************************

  Procedure:  Conversion.reportClientCPAErrors
     Author:  Chris Carson
    Purpose:  creates exception report for legacy ClientCPA errors.


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:


    Notes:

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;

    DECLARE @rc                     AS INT             = 0
          , @processName            AS VARCHAR (100)   = 'reportClientCPAErrors'
          , @errorMessage           AS VARCHAR (MAX)   = NULL
          , @errorQuery             AS VARCHAR (MAX)   = NULL
          , @processClientCPAs      AS VARBINARY (128) = CAST( 'processClientCPAs' AS VARBINARY(128) ) ;


    DECLARE @ClientCPAErrorCount    AS INT = 0 ;


    DECLARE @ClientCPAErrors        AS TABLE ( ClientID         INT
                                             , ClientName       VARCHAR (100)
                                             , ClientCPA        VARCHAR (100) 
                                             , AcctClass        VARCHAR (100) 
                                             , DiscCoord        VARCHAR (100) ) ;

--  1)  INSERT error records into temporary storage
BEGIN TRY
    INSERT  @ClientCPAErrors
    SELECT  ClientID    = l.ClientID
          , ClientName  = c.ClientName
          , ClientCPA   = l.ClientCPA
          , AcctClass   = ISNULL( c.AcctClass, '' )
          , DiscCoord   = c.Analyst
      FROM  Conversion.tvf_ClientCPAs ( 'Legacy' ) AS l
INNER JOIN  edata.Clients AS c on c.ClientID = l.ClientID
     WHERE  l.FirmCategoriesID = 0 OR l.ClientCPAFirmID = 0
    SELECT  @ClientCPAErrorCount = @@ROWCOUNT ;


--  2)  Exit if there are no errors
    IF  ( @ClientCPAErrorCount = 0 )
    BEGIN
        PRINT 'No Client CPA errors found, exiting' ;
        GOTO endOfProc ;
    END

    PRINT 'There are ' + CAST( @ClientCPAErrorCount AS VARCHAR(20) ) + ' Client CPA errors in legacy' ;


--  3)  Format error report from @ClientCPAErrors
    SELECT  @errorMessage = '</br><H2><b>These ClientCPA''s did not convert.</b></H2></br></br>'
                          + '<b>Instructions for resolving reported errors:</b></br>'
                          + '&nbsp;&nbsp;1)&nbsp;&nbsp;Make sure firm exists, and is set up as a Client CPA </br>'
                          + '&nbsp;&nbsp;2)&nbsp;&nbsp;Make sure correct FirmID is entered into the legacy CPAClientFirmID field in legacy </br>'
                          + '</br><b>ALTERNATE METHOD</b></br>'
                          + '&nbsp;&nbsp;1)&nbsp;&nbsp;Verify that Firm data is correct in new system </br>'
                          + '&nbsp;&nbsp;2)&nbsp;&nbsp;Update the client in new system with correct Client CPA data </br></br>'
          , @errorQuery   = N'<b>Client CPA''s that can not convert</b></br></br>'
                          + N'<table border="1">'
                          + N'<tr><th>ClientID</th><th>ClientName</th><th>Client CPA</th>'
                          + N'<th>Ehlers Team</th><th>Ehlers DC</th></tr>'
                          + CAST ( ( SELECT td = ClientID, ''
                                          , td = ClientName, ''
                                          , td = ClientCPA, ''
                                          , td = AcctClass, ''
                                          , td = DiscCoord
                                       FROM @ClientCPAErrors
                                      ORDER BY 7, 9, 5
                                        FOR XML PATH('tr'), TYPE ) AS NVARCHAR(MAX) )
                          + N'</table>' ;



--  4)  Invoke error processing routine to mail out error report
    EXECUTE dbo.processEhlersError    @processName
                                    , @errorMessage
                                    , @errorQuery ;


END TRY
BEGIN CATCH
    EXECUTE dbo.processEhlersError ;
    RETURN  16 ;
END CATCH


endOfProc:
--  5) Print control totals
    PRINT 'Conversion.processClientCPAs ' ;
    PRINT 'CONTROL TOTALS ' ;
    PRINT '    ClientCPA Errors on edata.Client = ' + STR( @ClientCPAErrorCount, 8 ) ;
    PRINT '' ;

    RETURN @rc ;
END
