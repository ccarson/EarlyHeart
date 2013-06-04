CREATE TRIGGER  tr_ClientDocument
            ON  dbo.ClientDocument
AFTER INSERT, UPDATE
AS
/*
************************************************************************************************************************************

    Trigger:    tr_ClientDocument
     Author:    ccarson
    Purpose:    writes Client disclosure data back to legacy dbo.Disclosure


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Stop processing when trigger is fired from Conversion
    2)  Stop processing unless legacy Disclosure is different
    3)  MERGE changed disclosures into edata.Disclosure


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
          , @codeBlockDesc02    AS SYSNAME  = 'Stop processing unless legacy Disclosure is different'
          , @codeBlockDesc03    AS SYSNAME  = 'MERGE changed disclosures into edata.Disclosure' ;



    DECLARE @fromConversion     AS VARBINARY (128)  = CAST( 'fromConversion' AS VARBINARY (128) )
          , @legacyChecksum     AS INT
          , @convertedChecksum  AS INT ;



/**/SELECT  @codeBlockNum = 01, @codeBlockDesc = @codeBlockDesc01 ; --  Stop processing when trigger is fired from Conversion
    IF  CONTEXT_INFO() = @fromConversion
        RETURN ;



/**/SELECT  @codeBlockNum = 02, @codeBlockDesc = @codeBlockDesc02 ;--  Stop processing unless legacy Disclosure is different
    SELECT  @legacyChecksum = CHECKSUM_AGG( CHECKSUM(*) )
      FROM  Conversion.tvf_ClientDisclosureChecksum( 'Legacy' ) AS  l
     WHERE  EXISTS ( SELECT 1 FROM inserted AS i WHERE i.ClientID = l.ClientID ) ;

    SELECT  @convertedChecksum = CHECKSUM_AGG( CHECKSUM(*) )
      FROM  Conversion.tvf_ClientDisclosureChecksum( 'Converted' ) AS c
     WHERE  EXISTS ( SELECT 1 FROM inserted AS i WHERE i.ClientID = c.ClientID ) ;

    IF  @legacyChecksum = @convertedChecksum
        RETURN ;



/**/SELECT  @codeBlockNum = 03, @codeBlockDesc = @codeBlockDesc03 ;--  MERGE changed disclosures into edata.Disclosure
      WITH  changedDisclosure AS (
            SELECT ClientID, DisclosureType, ContractType, ContractDate, ChangeDate, ChangeBy
              FROM Conversion.vw_ConvertedClientDisclosure AS c
             WHERE ClientID IN ( SELECT ClientID FROM inserted ) ) ,

            legacy AS (
            SELECT * FROM edata.Disclosure AS d
             WHERE ClientId IN ( SELECT ClientID FROM inserted ) )

     MERGE  legacy            AS tgt
     USING  changedDisclosure AS src ON src.ClientID = tgt.ClientId
      WHEN  MATCHED THEN
            UPDATE
               SET DisclosureType = src.DisclosureType
                 , ContractType   = src.ContractType
                 , ContractDate   = src.ContractDate

      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( ClientId, DisclosureType, ContractType, ContractDate )
            VALUES ( src.ClientID, src.DisclosureType, src.ContractType, src.ContractDate )

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
                       + '<tr><th>ClientDocumentID</th><th>ClientID</th><th>ClientDocumentNameID</th>'
                       + '<th>DocumentName</th><th>ClientDocumentTypeID</th><th>DocumentDate</th>'
                       + '<th>IsOnFile</th><th>ModifiedDate</th><th>ModifiedUser</th></tr>'
                       + CAST ( ( SELECT  td = ClientDocumentID, ''
                                        , td = ClientID, ''
                                        , td = ClientDocumentNameID, ''
                                        , td = DocumentName, ''
                                        , td = ClientDocumentTypeID, ''
                                        , td = DocumentDate, ''
                                        , td = IsOnFile, ''
                                        , td = ModifiedDate, ''
                                        , td = ModifiedUser, ''
                                    FROM  inserted
                                     FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
                       + N'</table></br></br>' ;

    SELECT  @errorData = @errorData
                       + '<b>contents of deleted trigger table</b></br></br>'
                       + '<table border="1">'
                       + '<tr><th>ClientDocumentID</th><th>ClientID</th><th>ClientDocumentNameID</th>'
                       + '<th>DocumentName</th><th>ClientDocumentTypeID</th><th>DocumentDate</th>'
                       + '<th>IsOnFile</th><th>ModifiedDate</th><th>ModifiedUser</th></tr>'
                       + CAST ( ( SELECT  td = ClientDocumentID, ''
                                        , td = ClientID, ''
                                        , td = ClientDocumentNameID, ''
                                        , td = DocumentName, ''
                                        , td = ClientDocumentTypeID, ''
                                        , td = DocumentDate, ''
                                        , td = IsOnFile, ''
                                        , td = ModifiedDate, ''
                                        , td = ModifiedUser, ''
                                    FROM  deleted
                                     FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
                       + N'</table></br></br>'
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


