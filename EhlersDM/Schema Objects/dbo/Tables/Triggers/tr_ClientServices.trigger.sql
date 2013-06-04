CREATE TRIGGER  tr_ClientServices
            ON  dbo.ClientServices
AFTER INSERT, UPDATE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_ClientServices
     Author:    Chris Carson
    Purpose:    Synchronizes ClientServices data with Legacy edata.ClientServices table


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:

    Notes:

************************************************************************************************************************************
*/
BEGIN
BEGIN TRY

    IF  NOT EXISTS ( SELECT 1 FROM inserted )
        RETURN ;

    SET NOCOUNT ON ;

    DECLARE @codeBlockNum       AS INT
          , @codeBlockDesc      AS SYSNAME
          , @codeBlockDesc01    AS SYSNAME  = 'Stop processing when trigger is fired from Conversion'
          , @codeBlockDesc02    AS SYSNAME  = 'Stop processing unless Clients data has actually changed'
          , @codeBlockDesc03    AS SYSNAME  = 'MERGE new Client data onto edata.Clients' ;


    DECLARE @fromConversion     AS VARBINARY (128)  = CAST( 'fromConversion' AS VARBINARY (128) )
          , @legacyChecksum     AS INT
          , @convertedChecksum  AS INT ;


/**/SELECT  @codeBlockNum = 01, @codeBlockDesc = @codeBlockDesc01 ; --  Stop processing when trigger is fired from Conversion
    IF  CONTEXT_INFO() = @fromConversion
        RETURN ;



/**/SELECT  @codeBlockNum = 02, @codeBlockDesc = @codeBlockDesc02 ; --  MERGE new client service data onto edata.ClientContacts
      WITH  legacy AS (
            SELECT ClientID, ServiceCode FROM edata.ClientsServices
             WHERE ClientID IN ( SELECT ClientID FROM inserted ) ) ,

            clientServices AS (
            SELECT ClientID, ServiceCode FROM Conversion.vw_ConvertedClientServices
             WHERE ClientID IN ( SELECT ClientID FROM inserted ) )

     MERGE  legacy          AS tgt
     USING  clientServices  AS src ON tgt.ClientID = src.ClientID AND tgt.ServiceCode = src.ServiceCode
      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( ClientID, ServiceCode )
            VALUES ( src.ClientID, src.ServiceCode )

      WHEN  NOT MATCHED BY SOURCE THEN
            DELETE ;


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

    SELECT  @errorData = '<b>contents of inserted trigger table</b></br></br>'
          + '<table border="1">'
          + '<tr><th>ClientServicesID</th><th>ClientID</th><th>ClientServiceID</th><th>Active</th>'
          + '<th>ModifiedDate</th><th>ModifiedUser</th></tr>'
          + CAST ( ( SELECT  td = ClientServicesID, ''
                          ,  td = ClientID, ''
                          ,  td = ClientServiceID, ''
                          ,  td = Active, ''
                          ,  td = ModifiedDate, ''
                          ,  td = ModifiedUser, ''
                       FROM  inserted
                        FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
          + N'</table></br></br>' ;

    SELECT  @errorData = @errorData
          + '<b>contents of deleted trigger table</b></br></br>'
          + '<table border="1">'
          + '<tr><th>ClientServicesID</th><th>ClientID</th><th>ClientServiceID</th><th>Active</th>'
          + '<th>ModifiedDate</th><th>ModifiedUser</th></tr>'
          + CAST ( ( SELECT  td = ClientServicesID, ''
                          ,  td = ClientID, ''
                          ,  td = ClientServiceID, ''
                          ,  td = Active, ''
                          ,  td = ModifiedDate, ''
                          ,  td = ModifiedUser, ''
                       FROM  deleted
                        FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
          + N'</table>'
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

