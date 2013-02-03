CREATE PROCEDURE Conversion.reportLocalAttorneyErrors
AS
/*
************************************************************************************************************************************

  Procedure:  Conversion.reportLocalAttorneyErrors
     Author:  Chris Carson
    Purpose:  creates exception report for legacy LocalAttorney errors.



    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  INSERT error records into temporary storage
    2)  Exit if there are no errors
    3)  Format error report from @localAttorneyErrors
    4)  Invoke error processing routine to mail out error report
    5)  Print control totals

    Notes:

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;

    DECLARE @rc                         AS INT = 0
          , @processName                AS VARCHAR(100) = 'reportLocalAttorneyErrors'
          , @errorMessage               AS VARCHAR(MAX) = NULL
          , @errorQuery                 AS VARCHAR(MAX) = NULL ;


    DECLARE @errorCount                 AS INT = 0 ;


    DECLARE @localAttorneyErrors        AS TABLE ( ClientID         INT
                                                 , ClientName       VARCHAR (100)
                                                 , LocalAttorney    VARCHAR (100)
                                                 , City             VARCHAR (100)
                                                 , State            VARCHAR (100) 
                                                 , AcctClass        VARCHAR (100) 
                                                 , DiscCoord        VARCHAR (100) ) ;


--  1)  INSERT error records into temporary storage
BEGIN TRY
    INSERT  @localAttorneyErrors
    SELECT  ClientID        = l.ClientID
          , ClientName      = c.ClientName
          , LocalAttorney   = l.LocalAttorney
          , City            = ISNULL( c.LACity, '' )
          , State           = ISNULL( c.LAState, '' )
          , AcctClass       = ISNULL( c.AcctClass, '' )
          , DiscCoord       = c.Analyst
      FROM  Conversion.tvf_LocalAttorney ( 'Legacy' ) AS l
INNER JOIN  edata.dbo.Clients AS c on c.ClientID = l.ClientID
     WHERE  l.FirmCategoriesID = 0
    SELECT  @errorCount = @@ROWCOUNT ;

--  2)  Exit if there are no errors
    IF  ( @errorCount = 0 )
    BEGIN
        PRINT 'No Local Attorney errors found, exiting' ;
        GOTO endOfProc ;
    END

    PRINT 'There are ' + CAST( @errorCount AS VARCHAR(20) ) + ' Local Attorney errors in legacy' ;

--  3)  Format error report from @localAttorneyErrors
    SELECT  @errorMessage = '</br><H2><b>These Local Attorneys will not convert.</b></H2></br></br>'
                          + '<b>Instructions for resolving reported errors:</b></br>'
                          + '&nbsp;&nbsp;1)&nbsp;&nbsp;Verify that Firm data is correct in new system </br>'
                          + '&nbsp;&nbsp;2)&nbsp;&nbsp;If Firm does not exist, create it in new system </br>'
                          + '&nbsp;&nbsp;3)&nbsp;&nbsp;Verify that new firm has a category of Local Attorney </br>'
                          + '&nbsp;&nbsp;4)&nbsp;&nbsp;Select new firm as Local Attorney on Client Identification page </br></br>'
          , @errorQuery   = N'<b>Client Local Attorney records that can not convert</b></br></br>'
                          + N'<table border="1">'
                          + N'<tr><th>ClientID</th><th>Client Name</th><th>Local Attorney</th><th>City</th><th>State</th>'
                          + N'<th>Ehlers Team</th><th>Ehlers DC</th></tr>'
                          + CAST ( ( SELECT td = ClientID, ''
                                          , td = ClientName, ''
                                          , td = LocalAttorney, ''
                                          , td = City, ''
                                          , td = State, ''
                                          , td = AcctClass, ''
                                          , td = DiscCoord
                                       FROM @localAttorneyErrors
                                      ORDER BY 11, 13, 5, 7, 3
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
--  5)  Print control totals
    PRINT 'Conversion.reportLocalAttorneyErrors ' ;
    PRINT 'CONTROL TOTALS ' ;
    PRINT '    Local Attorney Errors on edata.dbo.Client = ' + STR( @errorCount, 8 ) ;
    PRINT '' ;

    RETURN @rc ;
END
