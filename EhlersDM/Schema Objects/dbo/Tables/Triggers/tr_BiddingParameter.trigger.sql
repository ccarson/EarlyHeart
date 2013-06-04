CREATE TRIGGER  tr_BiddingParameter
            ON  dbo.BiddingParameter
AFTER INSERT, UPDATE, DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_BiddingParameter
     Author:    Chris Carson
    Purpose:    loads BiddingParameter data into edata.Issues


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Stop processing when trigger is fired from Conversion
    2)  INSERT changed IssueIDs into temp storage
    3)  Stop processing unless data has actually changed
    4)  UPDATE edata.Issues with trigger data


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
          , @codeBlockDesc01    AS SYSNAME  = 'Stop processing when trigger is fired from Conversion'
          , @codeBlockDesc02    AS SYSNAME  = 'INSERT changed IssueIDs into temp storage'
          , @codeBlockDesc03    AS SYSNAME  = 'Stop processing unless data has actually changed'
          , @codeBlockDesc04    AS SYSNAME  = 'UPDATE edata.Issues with trigger data' ;



    DECLARE @fromConversion     AS VARBINARY (128)  = CAST( 'fromConversion' AS VARBINARY (128) ) ;



    DECLARE @legacyChecksum     AS INT
          , @convertedChecksum  AS INT
          , @systemUser         AS VARCHAR (30) = dbo.udf_GetSystemUser() ;

    DECLARE @changedIssues AS TABLE ( IssueID INT ) ;



/**/SELECT  @codeBlockNum = 01, @codeBlockDesc = @codeBlockDesc01 ; --  Stop processing when trigger is fired from Conversion
    IF  CONTEXT_INFO() = @fromConversion
        RETURN ;



/**/SELECT  @codeBlockNum = 02, @codeBlockDesc = @codeBlockDesc02 ; --  INSERT changed IssueIDs into temp storage
    INSERT  @changedIssues
    SELECT  IssueID FROM inserted
        UNION
    SELECT  IssueID FROM deleted ;



/**/SELECT  @codeBlockNum = 03, @codeBlockDesc = @codeBlockDesc03 ; --  Stop processing unless data has actually changed
    SELECT  @legacyChecksum = CHECKSUM_AGG( CHECKSUM(*) ) FROM Conversion.tvf_BiddingParameterChecksum( 'Legacy' )
     WHERE  IssueID IN ( SELECT IssueID FROM @changedIssues ) ;

    SELECT  @convertedChecksum = CHECKSUM_AGG( CHECKSUM(*) ) FROM Conversion.tvf_BiddingParameterChecksum( 'Converted' )
     WHERE  IssueID IN ( SELECT IssueID FROM @changedIssues ) ;

    IF  @legacyChecksum = @convertedChecksum
        RETURN ;



/**/SELECT  @codeBlockNum = 04, @codeBlockDesc = @codeBlockDesc04 ; --  UPDATE edata.Issues with trigger data
    UPDATE  edata.Issues
       SET  MinimumBid      = cbp.MinimumBid
          , MaximumBid      = cbp.MaximumBid
          , AllowDecrease   = cbp.AllowDecrease
          , TermBonds       = ISNULL( cbp.TermBonds, 0 )
          , AdjustIssue     = ISNULL( cbp.AdjustIssue, 0 )
          , PctInterest     = ISNULL( cbp.PctInterest, 0 )
          , MaximumDecrease = cbp.MaximumDecrease
          , DateDecrease    = cbp.DateDecrease
          , AwardBasis      = ISNULL( cbp.AwardBasis, 0 )
          , InternetSale    = cbp.InternetSale
          , ChangeDate      = ISNULL( cbp.ChangeDate, GETDATE() )
          , ChangeBy        = ISNULL( cbp.ChangeBy, @systemUser )
      FROM  edata.Issues                            AS iss
 LEFT JOIN  Conversion.vw_ConvertedBiddingParameter AS cbp ON cbp.IssueID = iss.IssueId
     WHERE  iss.IssueId IN ( SELECT IssueID FROM @changedIssues ) ;



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

    SELECT  @errorData = '<b>contents of new data from trigger table</b></br></br><table border="1">'
                       + '<tr><th>IssueID</th><th>MinimumBid</th><th>MaximumBid</th><th>AllowDecrease</th>'
                       + '<th>TermBonds</th><th>AdjustIssue</th><th>PctInterest</th><th>MaximumDecrease</th>'
                       + '<th>DateDecrease</th><th>AwardBasis</th><th>InternetSale</th>'
                       + '<th>ChangeDate</th><th>ChangeBy</th></tr>'
                       + CAST ( ( SELECT  td = chg.IssueID
                                        , td = cbp.MinimumBid
                                        , td = cbp.MaximumBid
                                        , td = cbp.AllowDecrease
                                        , td = ISNULL( cbp.TermBonds, 0 )
                                        , td = ISNULL( cbp.AdjustIssue, 0 )
                                        , td = ISNULL( cbp.PctInterest, 0 )
                                        , td = cbp.MaximumDecrease
                                        , td = cbp.DateDecrease
                                        , td = ISNULL( cbp.AwardBasis, 0 )
                                        , td = cbp.InternetSale
                                        , td = ISNULL( cbp.ChangeDate, GETDATE() )
                                        , td = ISNULL( cbp.ChangeBy, @systemUser )
                                    FROM  @changedIssues                          AS chg
                               LEFT JOIN  Conversion.vw_ConvertedBiddingParameter AS cbp ON cbp.IssueID = chg.IssueID
                                     FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
                       + '</table></br></br>'
     WHERE  EXISTS ( SELECT 1 FROM @changedIssues ) ;

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

