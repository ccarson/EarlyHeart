CREATE TRIGGER  tr_IssueCall
            ON  dbo.IssueCall
AFTER INSERT, UPDATE, DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    tr_IssueCall
     Author:    Chris Carson
    Purpose:    writes IssueCall changes back to legacy dbo.Calls

    revisor         date                description
    ---------       ----------          ----------------------------
    ccarson         2013-01-24          created
    ccarson         ###DATE###          revised error reporting

    Logic Summary:
    1)  Stop processing when trigger is invoked by Conversion.processCalls procedure
    2)  Load CTE with temp data from inserted and deleted...
    3)  ...MERGE data from CTE onto edata.Calls

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
          , @codeBlockDesc02    AS SYSNAME  = 'Stop processing unless Firm data has actually changed'
          , @codeBlockDesc03    AS SYSNAME  = 'MERGE new Firm data onto edata.Firms' ;



    DECLARE @fromConversion     AS VARBINARY (128)  = CAST( 'fromConversion' AS VARBINARY (128) )



/**/SELECT  @codeBlockNum = 01, @codeBlockDesc = @codeBlockDesc01 ; --  Stop processing when trigger is fired from Conversion
    IF  CONTEXT_INFO() = @fromConversion
        RETURN ;



/**/SELECT  @codeBlockNum = 02, @codeBlockDesc = @codeBlockDesc02 ; --  MERGE trigger table data into edata.Calls
      WITH  triggerData AS (
            SELECT  IssueCallID         = IssueCallID
                  , IssueID             = IssueID
                  , FirstCallDate       = CallDate
                  , CallPrice           = CallPricePercent
                  , CallableMatDate     = FirstCallableMatDate
                  , isDelete            = CAST( 0 AS BIT )
              FROM  inserted
                UNION ALL
            SELECT  IssueCallID         = IssueCallID
                  , IssueID             = IssueID
                  , FirstCallDate       = CallDate
                  , CallPrice           = CallPricePercent
                  , CallableMatDate     = FirstCallableMatDate
                  , isDelete            = CAST( 1 AS BIT )
              FROM  deleted
             WHERE  IssueCallID NOT IN ( SELECT IssueCallID FROM inserted ) )

     MERGE  edata.Calls AS tgt
     USING  triggerData AS src  ON tgt.IssueId = src.IssueID
                               AND ISNULL( tgt.FirstCallDate,'1900-01-01' ) = ISNULL( src.FirstCallDate,'1900-01-01' )
                               AND tgt.CallPrice = src.CallPrice
                               AND ISNULL( tgt.CallableMatDate,'1900-01-01' ) = ISNULL( src.CallableMatDate,'1900-01-01' )
      WHEN  MATCHED AND src.isDelete = 1 THEN
            DELETE
      WHEN  MATCHED THEN
            UPDATE  SET  FirstCallDate   =  src.FirstCallDate
                       , CallPrice       =  src.CallPrice
                       , CallableMatDate =  src.CallableMatDate
      WHEN  NOT MATCHED BY TARGET AND src.isDelete = 0 THEN
            INSERT ( IssueID, FirstCallDate, CallPrice, CallableMatDate )
            VALUES ( IssueID, FirstCallDate, CallPrice, CallableMatDate ) ;

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

    SELECT  @errorData = ISNULL( @errorData, '' )
                       + '<b>contents of inserted trigger table</b></br></br>'
                       + '<table border="1">'
                       + '<tr><th>IssueCallID</th><th>IssueID</th><th>CallDate</th>'
                       + '<th>CallPricePercent</th><th>FirstCallableMatDate</th></tr>'
                       + CAST ( ( SELECT  td = IssueCallID          , ''
                                        , td = IssueID              , ''
                                        , td = CallDate             , ''
                                        , td = CallPricePercent     , ''
                                        , td = FirstCallableMatDate , ''
                                    FROM  inserted
                                     FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
                       + '</table></br></br>'
     WHERE  EXISTS ( SELECT 1 FROM inserted ) ;

    SELECT  @errorData = ISNULL( @errorData, '' )
                       + '<b>contents of deleted trigger table</b></br></br>'
                       + '<table border="1">'
                       + '<tr><th>IssueCallID</th><th>IssueID</th><th>CallDate</th>'
                       + '<th>CallPricePercent</th><th>FirstCallableMatDate</th></tr>'
                       + CAST ( ( SELECT  td = IssueCallID          , ''
                                        , td = IssueID              , ''
                                        , td = CallDate             , ''
                                        , td = CallPricePercent     , ''
                                        , td = FirstCallableMatDate , ''
                                    FROM  deleted
                                     FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
                       + '</table></br></br>'
     WHERE  EXISTS ( SELECT 1 FROM deleted ) ;

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
