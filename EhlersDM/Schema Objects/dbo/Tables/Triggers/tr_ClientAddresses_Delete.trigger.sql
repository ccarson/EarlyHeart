CREATE TRIGGER  tr_ClientAddresses_Delete
            ON  dbo.ClientAddresses
AFTER DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    tr_ClientAddresses_Delete
     Author:    Chris Carson
    Purpose:    Clears address data on edata.Clients


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Stop processing when trigger is fired from Conversion
    2)  UPDATE Address Data back to edata.Clients
    3)  DELETE Conversion.LegacyAddresses from trigger data

    Notes:

************************************************************************************************************************************
*/
BEGIN
BEGIN TRY

    IF  NOT EXISTS ( SELECT 1 FROM deleted WHERE AddressTypeID = 3 )
        RETURN ;

    SET NOCOUNT ON ;

    DECLARE @codeBlockNum       AS INT
          , @codeBlockDesc      AS SYSNAME
          , @codeBlockDesc01    AS SYSNAME  = 'Stop processing when trigger is fired from Conversion'
          , @codeBlockDesc02    AS SYSNAME  = 'UPDATE Address Data back to edata.Clients'
          , @codeBlockDesc03    AS SYSNAME  = 'DELETE Conversion.LegacyAddresses from trigger data' ;



    DECLARE @fromConversion     AS VARBINARY (128)  = CAST( 'fromConversion' AS VARBINARY (128) )
          , @systemUser         AS VARCHAR (30) = dbo.udf_GetSystemUser() ;



/**/SELECT  @codeBlockNum = 01, @codeBlockDesc = @codeBlockDesc01 ; --  Stop processing when trigger is fired from Conversion
    IF  CONTEXT_INFO() = @fromConversion
        RETURN ;



/**/SELECT  @codeBlockNum = 02, @codeBlockDesc = @codeBlockDesc02 ; --  UPDATE Address Data back to edata.Firms
    UPDATE  edata.Clients
       SET  Address1    = ''
          , Address2    = ''
          , City        = ''
          , State       = ''
          , Zip         = ''
          , ChangeDate  = GETDATE()
          , ChangeBy    = @systemUser
          , ChangeCode  = 'CVAddress'
     WHERE  ClientID IN ( SELECT ClientID FROM deleted WHERE AddressTypeID = 3 ) ;



/**/SELECT  @codeBlockNum = 03, @codeBlockDesc = @codeBlockDesc03 ; --  DELETE Conversion.LegacyAddresses from trigger data
    DELETE  Conversion.LegacyAddresses
     WHERE  AddressID IN ( SELECT AddressID FROM deleted WHERE AddressTypeID = 3 ) ;



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

    SELECT  @errorData = '<b>contents of deleted trigger table</b></br></br>'
                       + '<table border="1">'
                       + '<tr><th>ClientAddressesID</th><th>ClientID</th><th>AddressID</th><th>AddressTypeID</th>'
                       + '<th>ModifiedDate</th><th>ModifiedUser</th></tr>'
                       + CAST ( ( SELECT  td = ClientAddressesID    , ''
                                        , td = ClientID             , ''
                                        , td = AddressID            , ''
                                        , td = AddressTypeID        , ''
                                        , td = GETDATE()            , ''
                                        , td = @systemUser          , ''
                                    FROM  deleted
                                     FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
                       + '</table></br></br>' ;

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

