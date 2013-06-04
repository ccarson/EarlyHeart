CREATE TRIGGER  tr_ClientOverlap
            ON  dbo.ClientOverlap
AFTER INSERT, UPDATE, DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_ClientOverlap
     Author:    ccarson
    Purpose:    writes Counties data back to legacy dbo.Clients

    revisor         date                description
    ---------       ----------          ----------------------------
    ccarson         2013-01-24          created
    ccarson         ###DATE###          revised error reporting


    Logic Summary:

    1)  Stop processing when trigger is fired from Conversion
    2)  MERGE new Counties data into edata.Clients


    Notes:

************************************************************************************************************************************
*/
BEGIN
BEGIN TRY

    IF  NOT EXISTS ( SELECT 1 FROM inserted WHERE OverlapTypeID = 1 )
        IF  NOT EXISTS ( SELECT 1 FROM deleted WHERE OverlapTypeID = 1 )
            RETURN ;

    SET NOCOUNT ON ;

    DECLARE @codeBlockNum       AS INT
          , @codeBlockDesc      AS SYSNAME
          , @codeBlockDesc01    AS SYSNAME          = 'Stop processing when trigger is fired from Conversion'
          , @codeBlockDesc02    AS SYSNAME          = 'MERGE new Counties data into edata.Clients' ;

    DECLARE @fromConversion     AS VARBINARY (128)  = CAST( 'fromConversion' AS VARBINARY (128) ) ;



    DECLARE @systemUser         AS VARCHAR (20)     = dbo.udf_GetSystemUser()
          , @systemTime         AS DATETIME         = GETDATE() ;



/**/SELECT  @codeBlockNum = 01, @codeBlockDesc = @codeBlockDesc01 ; --  Stop processing when trigger is fired from Conversion
    IF  CONTEXT_INFO() = @fromConversion
        RETURN ;



/**/SELECT  @codeBlockNum = 02, @codeBlockDesc = @codeBlockDesc02 ; --  MERGE new Counties data into edata.Clients
      WITH  changes AS (
            SELECT  ClientID FROM inserted
                UNION
            SELECT  ClientID FROM deleted ) ,

            countyData AS (
            SELECT  TOP 100 PERCENT
                    chg.ClientID, tvf.HomeCounty, tvf.County1, tvf.County2, tvf.County3, tvf.County4
              FROM  changes AS chg
         LEFT JOIN  Conversion.tvf_LegacyCounties ( 'Converted' ) AS tvf ON tvf.ClientID = chg.ClientID
             ORDER  BY ClientID ) ,

            clients AS (
            SELECT  * FROM edata.Clients
             WHERE  ClientId IN ( SELECT ClientID FROM changes ) )

     MERGE  edata.Clients   AS tgt
     USING  countyData      AS src ON src.ClientID = tgt.ClientId
      WHEN  MATCHED THEN
            UPDATE SET  HomeCounty  = src.HomeCounty
                      , County1     = src.County1
                      , County2     = src.County2
                      , County3     = src.County3
                      , County4     = src.County4
                      , County5     = NULL
                      , ChangeBy    = @systemUser
                      , ChangeCode  = 'cvCounty'
                      , ChangeDate  = @systemTime

      WHEN  NOT MATCHED BY SOURCE THEN
            UPDATE SET  HomeCounty  = NULL
                      , County1     = NULL
                      , County2     = NULL
                      , County3     = NULL
                      , County4     = NULL
                      , County5     = NULL
                      , ChangeBy    = @systemUser
                      , ChangeCode  = 'cvCounty'
                      , ChangeDate  = @systemTime ;


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
          + '<tr><th>ClientOverlapID</th><th>ClientID</th><th>ClientName</th><th>OverlapClientID</th>'
          + '<th>CountyName</th><th>Ordinal</th><th>ModifiedDate</th><th>ModifiedUser</th></tr>'
          + CAST ( ( SELECT  td = ins.ClientOverlapID, ''
                           , td = ins.ClientID, ''
                           , td = cli.ClientName, ''
                           , td = ins.OverlapClientID, ''
                           , td = cty.ClientName, ''
                           , td = ins.Ordinal, ''
                           , td = ins.ModifiedDate, ''
                           , td = ins.ModifiedUser, ''
                       FROM  inserted      AS ins
                 INNER JOIN  dbo.Client    AS cli ON cli.ClientID = ins.ClientID
                 INNER JOIN  dbo.Client    AS cty ON cty.ClientID = ins.OverlapClientID
                      ORDER  BY 3, 7
                        FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
          + '</table></br></br>'
     WHERE  EXISTS ( SELECT 1 FROM inserted ) ;

     
    SELECT  @errorData = ISNULL( @errorData, '' )
          + '<b>contents of deleted trigger table</b></br></br>'
          + '<table border="1">'
          + '<tr><th>ClientOverlapID</th><th>ClientID</th><th>ClientName</th><th>OverlapClientID</th>'
          + '<th>CountyName</th><th>Ordinal</th><th>ModifiedDate</th><th>ModifiedUser</th></tr>'
          + CAST ( ( SELECT  td = del.ClientOverlapID, ''
                           , td = del.ClientID, ''
                           , td = cli.ClientName, ''
                           , td = del.OverlapClientID, ''
                           , td = cty.ClientName, ''
                           , td = del.Ordinal, ''
                           , td = del.ModifiedDate, ''
                           , td = del.ModifiedUser, ''
                       FROM  deleted       AS del
                 INNER JOIN  dbo.Client    AS cli ON cli.ClientID = del.ClientID
                 INNER JOIN  dbo.Client    AS cty ON cty.ClientID = del.OverlapClientID
                      ORDER  BY 3, 7
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
