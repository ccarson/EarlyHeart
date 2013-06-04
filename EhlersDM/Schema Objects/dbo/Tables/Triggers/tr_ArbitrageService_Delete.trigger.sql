﻿CREATE TRIGGER  tr_ArbitrageService_Delete
            ON  dbo.ArbitrageService
AFTER DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    tr_ArbitrageService_Delete
     Author:    Chris Carson
    Purpose:    deletes legacy edata.IssueArbitrageServices data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created
    ccarson         ###DATE###          revised error reporting

    Logic Summary:
    1)  Stop processing when trigger is fired from Conversion
    2)  UPDATE edata.IssueArbitrageServices from trigger data


************************************************************************************************************************************
*/
BEGIN
BEGIN TRY

    IF  NOT EXISTS ( SELECT 1 FROM deleted )
        RETURN ;

    SET NOCOUNT ON ;

    DECLARE @codeBlockNum               AS INT
          , @codeBlockDesc              AS SYSNAME
          , @codeBlockDesc01            AS SYSNAME          = 'Stop processing when trigger is fired from Conversion'
          , @codeBlockDesc02            AS SYSNAME          = 'UPDATE edata.IssueArbitrageServices from trigger data' ;

    DECLARE @fromConversion             AS VARBINARY (128)  = CAST( 'fromConversion' AS VARBINARY (128) ) ;

    DECLARE @systemUser                 AS VARCHAR(20)      = dbo.udf_GetSystemUser() ;



/**/SELECT  @codeBlockNum = 01, @codeBlockDesc = @codeBlockDesc01 ; --  Stop processing when trigger is fired from Conversion
    IF  CONTEXT_INFO() = @fromConversion
        RETURN ;



/**/SELECT  @codeBlockNum = 02, @codeBlockDesc = @codeBlockDesc02 ; --  DELETE edata.IssueArbitrageServices from trigger data
    DELETE  edata.IssueArbitrageServices
     WHERE  ID IN ( SELECT ArbitrageServiceID FROM deleted ) ;


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
                       + '<b>contents of deleted trigger table</b></br></br>'
                       + '<table border="1">'
                       + '<tr><th>ArbitrageServiceID</th><th>IssueID</th><th>ServiceDate</th><th>ArbitrageComputationTypeID</th>'
                       + '<th>DataRequested</th><th>DataReceived</th><th>ArbitrageReport</th><th>ArbitrageFee</th><th>InvoiceDate</th>'
                       + '<th>ModifiedDate</th><th>ModifiedUser</th></tr>'
                       + CAST ( ( SELECT  td = ArbitrageServiceID        , ''
                                        , td = IssueID                   , ''
                                        , td = ServiceDate               , ''
                                        , td = ArbitrageComputationTypeID, ''
                                        , td = DataRequested             , ''
                                        , td = DataReceived              , ''
                                        , td = ArbitrageReport           , ''
                                        , td = ArbitrageFee              , ''
                                        , td = InvoiceDate               , ''
                                        , td = ModifiedDate              , ''
                                        , td = ModifiedUser              , ''
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

