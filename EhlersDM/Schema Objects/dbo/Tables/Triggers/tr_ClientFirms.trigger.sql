CREATE TRIGGER  tr_ClientFirms
            ON  dbo.ClientFirms
AFTER INSERT, UPDATE, DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_ClientFirms
     Author:    Chris Carson
    Purpose:    Synchronizes ClientFirms data with Legacy edata.Clients table


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
          , @systemDate         AS DATETIME         = GETDATE()
          , @systemUser         AS VARCHAR (20)     = dbo.udf_GetSystemUser() ;



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
                  , ClientCPA       = ISNULL ( cpa.ClientCPA, '' )
                  , ClientCPAFirmID = ISNULL ( cpa.ClientCPAFirmID, 0 )
                  , LocalAttorney   = ISNULL ( lat.LocalAttorney, '' )
                  , LACity          = ISNULL ( a.City, '' )
                  , LAState         = ISNULL ( a.State, '' )
                  , ChangeDate      = @systemDate
                  , ChangeCode      = 'CVClientFirms'
                  , ChangeBy        = @systemUser
              FROM  changes                                     AS chg
         LEFT JOIN  Conversion.tvf_ClientCPAs( 'Converted' )    AS cpa ON cpa.ClientID = chg.ClientID
         LEFT JOIN  Conversion.tvf_LocalAttorney( 'Converted' ) AS lat ON lat.ClientID = chg.ClientID
         LEFT JOIN  dbo.FirmCategories                          AS fc  ON lat.FirmCategoriesID = fc.FirmCategoriesID
         LEFT JOIN  dbo.FirmAddresses                           AS fa  ON fa.FirmID = fc.FirmID
         LEFT JOIN  dbo.Address                                 AS a   ON a.AddressID = fa.AddressID
             ORDER  BY chg.ClientID ) ,

            clients AS (
            SELECT  TOP 100 PERCENT * FROM edata.Clients WHERE ClientId IN ( SELECT ClientID FROM changes ) ORDER BY ClientId )

     MERGE  clients     AS tgt
     USING  changedData AS src ON src.ClientID = tgt.ClientId
      WHEN  MATCHED THEN
            UPDATE SET  ClientCPA       = src.ClientCPA
                      , ClientCPAFirmID = src.ClientCPAFirmID
                      , LocalAttorney   = src.LocalAttorney
                      , LACity          = src.LACity
                      , LAState         = src.LAState
                      , ChangeDate      = src.ChangeDate
                      , ChangeCode      = src.ChangeCode
                      , ChangeBy        = src.ChangeBy

      WHEN  NOT MATCHED BY SOURCE THEN
            UPDATE SET  ClientCPA       = NULL
                      , ClientCPAFirmID = NULL
                      , LocalAttorney   = NULL
                      , LACity          = NULL
                      , LAState         = NULL
                      , ChangeDate      = @systemDate
                      , ChangeCode      = 'CVClientFirms'
                      , ChangeBy        = @systemUser ;

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
          + '<tr><th>ClientFirmsID</th><th>ClientID</th><th>FirmCategoriesID</th>'
          + '<th>ModifiedDate</th><th>ModifiedUser</th></tr>'
          + CAST ( ( SELECT  td = ClientFirmsID, ''
                           , td = ClientID, ''
                           , td = FirmCategoriesID, ''
                           , td = ModifiedDate, ''
                           , td = ModifiedUser, ''
                       FROM  inserted
                      ORDER  BY 3
                        FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
          + '</table></br></br>'
     WHERE  EXISTS ( SELECT 1 FROM inserted ) ;

    SELECT  @errorData = ISNULL( @errorData, '' )
          + '<b>contents of deleted trigger table</b></br></br>'
          + '<table border="1">'
          + '<tr><th>ClientFirmsID</th><th>ClientID</th><th>FirmCategoriesID</th>'
          + '<th>ModifiedDate</th><th>ModifiedUser</th></tr>'
          + CAST ( ( SELECT  td = ClientFirmsID, ''
                           , td = ClientID, ''
                           , td = FirmCategoriesID, ''
                           , td = ModifiedDate, ''
                           , td = ModifiedUser, ''
                       FROM  deleted      AS del
                      ORDER  BY 3
                        FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
          + N'</table></br></br>'
     WHERE  EXISTS ( SELECT 1 FROM deleted ) ;


      WITH  changes AS (
            SELECT  ClientID FROM inserted
                UNION
            SELECT  ClientID FROM deleted )

    SELECT  @errorData = ISNULL( @errorData, '' )
              + '<b>data to be updated on edata.Clients</b></br></br>'
              + '<table border="1">'
              + '<tr><th>ClientID</th><th>ClientCPA</th><th>ClientCPAFirmID</th>'
              + '<th>LocalAttorney</th><th>LACity</th><th>LAState</th></tr>'
              + CAST ( ( SELECT  td = chg.ClientID, ''
                               , td = cpa.ClientCPA, ''
                               , td = cpa.ClientCPAFirmID, ''
                               , td = lat.LocalAttorney, ''
                               , td = a.City, ''
                               , td = a.State, ''
                           FROM  changes                                     AS chg
                      LEFT JOIN  Conversion.tvf_ClientCPAs( 'Converted' )    AS cpa ON cpa.ClientID = chg.ClientID
                      LEFT JOIN  Conversion.tvf_LocalAttorney( 'Converted' ) AS lat ON lat.ClientID = chg.ClientID
                      LEFT JOIN  dbo.FirmCategories                          AS fc  ON lat.FirmCategoriesID = fc.FirmCategoriesID
                      LEFT JOIN  dbo.FirmAddresses                           AS fa  ON fa.FirmID = fc.FirmID
                      LEFT JOIN  dbo.Address                                 AS a   ON a.AddressID = fa.AddressID
                          ORDER  BY 1
                            FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
              + N'</table></br></br>' ;


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
