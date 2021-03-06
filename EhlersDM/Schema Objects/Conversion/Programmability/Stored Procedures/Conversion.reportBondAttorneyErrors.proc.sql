﻿CREATE PROCEDURE Conversion.reportBondAttorneyErrors
AS
/*
************************************************************************************************************************************

  Procedure:  Conversion.reportBondAttorneyErrors
     Author:  Chris Carson
    Purpose:  creates exception report for legacy Bond Attorney errors.



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
BEGIN TRY
    SET NOCOUNT ON ;

    DECLARE @rc                         AS INT = 0
          , @processName                AS VARCHAR(100) = 'reportBondAttorneyErrors'
          , @errorMessage               AS VARCHAR(MAX) = NULL
          , @errorQuery                 AS VARCHAR(MAX) = NULL ;


    DECLARE @errorCount                 AS INT = 0 ;


    DECLARE @bondAttorneyErrors         AS TABLE ( IssueID      INT
                                                 , FirmID       INT
                                                 , FirmName     VARCHAR (100)
                                                 , Attorney     VARCHAR (100)
                                                 , AcctClass    VARCHAR (100) 
                                                 , DiscCoord    VARCHAR (100) ) ;

                                                 
--  1)  INSERT Bond Attorney records into temporary storage
      WITH  legacyBondAttorney AS ( 
            SELECT  iss.IssueID
                  , ips.FirmID 
                  , iss.Attorney
              FROM  edata.dbo.Issues        AS iss
        INNER JOIN  edata.dbo.IssueProfSvcs AS ips ON ips.IssueID = iss.IssueID
             WHERE  ips.Category = 'bc' AND ips.FirmID <> 0 AND iss.Attorney <> 'Check with FA' ) 
             
    INSERT  @bondAttorneyErrors ( IssueID, FirmID, Attorney ) 
    SELECT  IssueID, FirmID, Attorney
      FROM  legacyBondAttorney AS a
     WHERE  NOT EXISTS ( SELECT 1 FROM Conversion.tvf_BondAttorney( 'Legacy' ) AS b
                          WHERE b.IssueID = a.IssueID and b.FirmID = a.FirmID AND b.Attorney = a.Attorney ) ; 
    SELECT  @errorCount = @@ROWCOUNT ;
                          
     
--  2)  Exit if there are no errors
    IF  ( @errorCount = 0 ) 
        GOTO endOfProc ;
        
 
--  3)  UPDATE errors with firm name, Accounting Team and DisclosureCoordinator
    UPDATE  @bondAttorneyErrors
       SET  FirmName  = ISNULL( f.FirmName, 'No Firm Name' )
          , AcctClass = ISNULL( c.AcctClass, '' )
          , DiscCoord = ISNULL( dc.Analyst, '' )
      FROM  @bondAttorneyErrors                     AS b
INNER JOIN  Conversion.vw_LegacyIssues              AS l  ON l.IssueID   = b.IssueID
INNER JOIN  Conversion.vw_ConvertedClients          AS c  ON c.ClientID  = l.ClientID
 LEFT JOIN  Conversion.tvf_LegacyDCs( 'Converted' ) AS dc ON dc.ClientID = c.ClientID 
 LEFT JOIN  dbo.Firm                                AS f  ON f.FirmID    = b.FirmID ;
 

--  3)  Format error report from @localAttorneyErrors
    SELECT  @errorMessage = '</br><H2><b>These Bond Attorneys will not convert.</b></H2></br></br>'
                          + '<b>Instructions for resolving reported errors:</b></br>'
                          + '&nbsp;&nbsp;1)&nbsp;&nbsp;Verify that Firm data is correct in new system </br>'
                          + '&nbsp;&nbsp;2)&nbsp;&nbsp;Verify that the Firm is set up as Bond Counsel</br>'
                          + '&nbsp;&nbsp;3)&nbsp;&nbsp;Verify that the Attorney is listed as a contact for the firm </br>'
                          + '&nbsp;&nbsp;4)&nbsp;&nbsp;Verify that the contact is set up as a Bond Attorney</br></br>'
          , @errorQuery   = N'<b>Bond Attorney records that can not convert</b></br></br>'
                          + N'<table border="1">'
                          + N'<tr><th>IssueID</th><th>FirmID</th><th>Firm Name</th><th>Bond Attorney</th>'
                          + N'<th>Ehlers Team</th><th>Ehlers DC</th></tr>'
                          + CAST ( ( SELECT td = IssueID, ''
                                          , td = FirmID, ''
                                          , td = FirmName, ''
                                          , td = Attorney, ''
                                          , td = AcctClass, ''
                                          , td = DiscCoord
                                       FROM @bondAttorneyErrors
                                      ORDER BY 9, 11, 7, 1
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
    PRINT 'Conversion.reportBondAttorneyErrors ' ;
    PRINT 'CONTROL TOTALS ' ;
    PRINT '    Bond Attorney Errors on edata.dbo.Issues = ' + STR( @errorCount, 8 ) ;
    PRINT '' ;

    RETURN @rc ;
END
GO

