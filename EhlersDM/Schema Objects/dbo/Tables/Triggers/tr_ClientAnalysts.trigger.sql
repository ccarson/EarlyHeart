CREATE TRIGGER  tr_ClientAnalysts
            ON  dbo.ClientAnalysts
AFTER INSERT, UPDATE, DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    tr_ClientAnalysts
     Author:    ccarson
    Purpose:    writes EhlersFA, DisclosureCoordinator, and OriginatingFA data back to legacy dbo.Clients


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created
    ccarson         ###DATE###          revised error reporting

    Logic Summary:
    1)  Stop processing when trigger is fired from Conversion
    2)  MERGE trigger data into edata.Clients

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
          , @codeBlockDesc01    AS SYSNAME = 'Stop processing when trigger is fired from Conversion'
          , @codeBlockDesc02    AS SYSNAME = 'MERGE trigger data into edata.Clients' ;



    DECLARE @fromConversion     AS VARBINARY (128)  = CAST( 'fromConversion' AS VARBINARY (128) )
          , @systemUser         AS VARCHAR (20)     = dbo.udf_GetSystemUser()
          , @systemTime         AS DATETIME         = GETDATE() ;

    DECLARE @changedClients     AS TABLE ( ClientID INT ) ;



/**/SELECT  @codeBlockNum = 01, @codeBlockDesc = @codeBlockDesc01 ; --  Stop processing when trigger is fired from Conversion
    IF  CONTEXT_INFO() = @fromConversion
        RETURN ;



/**/SELECT  @codeBlockNum = 02, @codeBlockDesc = @codeBlockDesc02 ; --  MERGE trigger data into edata.Clients
      WITH  changes AS (
            SELECT  ClientID FROM inserted
                UNION
            SELECT  ClientID FROM deleted ) ,

            changedData AS (
            SELECT  TOP 100 PERCENT
                    ClientID        = chg.ClientID
                  , EhlersContact1  = tvf.EhlersContact1
                  , EhlersContact2  = tvf.EhlersContact2
                  , EhlersContact3  = tvf.EhlersContact3
                  , OriginatingFA1  = tvf.OriginatingFA1
                  , OriginatingFA2  = tvf.OriginatingFA2
                  , Analyst         = tvf.Analyst
                  , ChangeBy        = @systemUser
                  , ChangeCode      = 'CVAnalyst'
                  , ChangeDate      = @systemTime
              FROM  changes                                       AS chg
         LEFT JOIN  Conversion.tvf_LegacyAnalysts ( 'Converted' ) AS tvf ON tvf.ClientID = chg.ClientID
             ORDER  BY ClientID ) ,

            clients AS (
            SELECT  * FROM edata.Clients
             WHERE  ClientId IN ( SELECT ClientID FROM changes ) )

     MERGE  clients     AS tgt
     USING  changedData AS src ON src.ClientID = tgt.ClientId
      WHEN  MATCHED THEN
            UPDATE SET  EhlersContact1  = src.EhlersContact1
                      , EhlersContact2  = src.EhlersContact2
                      , EhlersContact3  = src.EhlersContact3
                      , OriginatingFA1  = src.OriginatingFA1
                      , OriginatingFA2  = src.OriginatingFA2
                      , Analyst         = src.Analyst
                      , ChangeBy        = @systemUser
                      , ChangeCode      = 'CVAnalyst'
                      , ChangeDate      = @systemTime

      WHEN  NOT MATCHED BY SOURCE THEN
            UPDATE SET  EhlersContact1  = NULL
                      , EhlersContact2  = NULL
                      , EhlersContact3  = NULL
                      , OriginatingFA1  = NULL
                      , OriginatingFA2  = NULL
                      , Analyst         = NULL
                      , ChangeBy        = @systemUser
                      , ChangeCode      = 'CVAnalyst'
                      , ChangeDate      = @systemTime ;


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
                       + '<tr><th>ClientAnalystsID</th><th>ClientID</th><th>EhlersEmployeeJobGroupsID</th>'
                       + '<th>Ordinal</th><th>ModifiedDate</th><th>ModifiedUser</th></tr>'
                       + CAST ( ( SELECT  td = ClientAnalystsID, ''
                                        , td = ClientID, ''
                                        , td = EhlersEmployeeJobGroupsID, ''
                                        , td = Ordinal, ''
                                        , td = ModifiedDate, ''
                                        , td = ModifiedUser, ''
                                    FROM  inserted
                                   ORDER  BY 3, 7
                                     FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
                       + '</table></br></br>'
     WHERE  EXISTS ( SELECT 1 FROM inserted ) ;

    SELECT  @errorData = ISNULL( @errorData, '' )
                       + '<b>contents of deleted trigger table</b></br></br>'
                       + '<table border="1">'
                       + '<tr><th>ClientAnalystsID</th><th>ClientID</th><th>EhlersEmployeeJobGroupsID</th>'
                       + '<th>Ordinal</th><th>ModifiedDate</th><th>ModifiedUser</th></tr>'
                       + CAST ( ( SELECT  td = ClientAnalystsID, ''
                                        , td = ClientID, ''
                                        , td = EhlersEmployeeJobGroupsID, ''
                                        , td = Ordinal, ''
                                        , td = ModifiedDate, ''
                                        , td = ModifiedUser, ''
                                    FROM  deleted
                                   ORDER  BY 3, 7
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
