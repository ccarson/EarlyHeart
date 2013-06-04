CREATE TRIGGER  tr_FirmAddresses_Audit
            ON  dbo.FirmAddresses
AFTER INSERT, UPDATE, DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    tr_FirmAddresses_Audit
     Author:    Chris Carson
    Purpose:    writes audit record to dbo.FirmAddressesAudit


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         ###DATE###          refactored audit triggers into single trigger, revised error reporting

    Logic Summary:
    1)  Determine trigger action
    2)  INSERT dbo.FirmAddressesAudit from trigger data

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
          , @codeBlockDesc01    AS SYSNAME  = 'Determine trigger action'
          , @codeBlockDesc02    AS SYSNAME  = 'INSERT dbo.FirmAddressesAudit from trigger data' ;

    DECLARE @systemUser AS VARCHAR(20) = dbo.udf_GetSystemUser()
          , @action     AS CHAR(1)  ;



/**/SELECT  @codeBlockNum = 01, @codeBlockDesc = @codeBlockDesc01 ; --  Determine trigger action
    IF  EXISTS ( SELECT 1 FROM inserted )
        IF  EXISTS ( SELECT 1 FROM deleted )
            SELECT  @action = 'U' ;
        ELSE
            SELECT  @action = 'I' ;
    ELSE
        SELECT @action = 'D' ;


/**/SELECT  @codeBlockNum = 02, @codeBlockDesc = @codeBlockDesc02 ; --  INSERT dbo.FirmAddressesAudit from trigger data
    IF  @action = 'D'
        INSERT  dbo.FirmAddressesAudit ( 
                FirmAddressesID, FirmID, AddressID, AddressTypeID, ChangeType, ModifiedDate, ModifiedUser )
        SELECT  FirmAddressesID, FirmID, AddressID, AddressTypeID, 'D', GETDATE(), @systemUser
        FROM    deleted ;
    ELSE
        INSERT  dbo.FirmAddressesAudit ( 
                FirmAddressesID, FirmID, AddressID, AddressTypeID, ChangeType, ModifiedDate, ModifiedUser )
        SELECT  FirmAddressesID, FirmID, AddressID, AddressTypeID, @action, ModifiedDate, ModifiedUser
        FROM    inserted ;



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
                       + '<tr><th>FirmAddressesID</th><th>FirmID</th><th>AddressID</th><th>AddressTypeID</th>'
                       + '<th>ModifiedDate</th><th>ModifiedUser</th></tr>'
                       + CAST ( ( SELECT  td = FirmAddressesID  , ''
                                        , td = FirmID           , ''
                                        , td = AddressID        , ''
                                        , td = AddressTypeID    , ''
                                        , td = ModifiedDate     , ''
                                        , td = ModifiedUser     , ''
                                    FROM  inserted
                                     FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
                       + '</table></br></br>' 
     WHERE  EXISTS ( SELECT 1 FROM inserted ) ;
     
    SELECT  @errorData = ISNULL( @errorData, '' ) 
                       + '<b>contents of deleted trigger table</b></br></br>'
                       + '<table border="1">'
                       + '<tr><th>FirmAddressesID</th><th>FirmID</th><th>AddressID</th><th>AddressTypeID</th>'
                       + '<th>ModifiedDate</th><th>ModifiedUser</th></tr>'
                       + CAST ( ( SELECT  td = FirmAddressesID  , ''
                                        , td = FirmID           , ''
                                        , td = AddressID        , ''
                                        , td = AddressTypeID    , ''
                                        , td = GETDATE()        , ''
                                        , td = @systemUser      , ''
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
