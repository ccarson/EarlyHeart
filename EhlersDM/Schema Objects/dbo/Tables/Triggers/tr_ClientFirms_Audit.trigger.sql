CREATE TRIGGER  tr_ClientFirms_Audit
            ON  dbo.ClientFirms
AFTER INSERT, UPDATE, DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    tr_ClientFirms_Audit
     Author:    mkiemen
    Purpose:    writes audit record to dbo.ClientFirmsAudit

    revisor         date                description
    ---------       ----------          ----------------------------
    ccarson         ###DATE###          refactored audit triggers into single trigger, revised error reporting

    Logic Summary:
    1)  Determine trigger action
    2)  Write trigger data to dbo.ClientFirmsAudit


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
          , @codeBlockDesc02    AS SYSNAME  = 'Write trigger data to dbo.ClientFirmsAudit' ;

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


/**/SELECT  @codeBlockNum = 02, @codeBlockDesc = @codeBlockDesc02 ; --  Write trigger data to dbo.ClientContactsAudit
    IF  @action = 'D'
        INSERT  dbo.ClientFirmsAudit ( ClientFirmsID, ClientID, FirmCategoriesID, ChangeType, ModifiedDate, ModifiedUser )
        SELECT  ClientFirmsID, ClientID, FirmCategoriesID, @action, GETDATE(), @systemUser
          FROM  deleted ;
          
    IF  @action = 'I'
        INSERT  dbo.ClientFirmsAudit ( ClientFirmsID, ClientID, FirmCategoriesID, ChangeType, ModifiedDate, ModifiedUser )
        SELECT  ClientFirmsID, ClientID, FirmCategoriesID, @action, ModifiedDate, ModifiedUser
          FROM  inserted ;

    IF  @action = 'U'
        INSERT  dbo.ClientFirmsAudit ( ClientFirmsID, ClientID, FirmCategoriesID, ChangeType, ModifiedDate, ModifiedUser )
        SELECT  del.ClientFirmsID, del.ClientID, del.FirmCategoriesID, @action, ins.ModifiedDate, ins.ModifiedUser
          FROM  inserted AS ins 
    INNER JOIN  deleted  AS del ON del.ClientFirmsID = ins.ClientFirmsID ;


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
                       + '<tr><th>ClientFirmsID</th><th>ClientID</th><th>FirmCategoriesID</th>'
                       + '<th>ModifiedDate</th><th>ModifiedUser</th></tr>'
                       + CAST ( ( SELECT  td = ClientFirmsID    , ''
                                        , td = ClientID         , ''
                                        , td = FirmCategoriesID , ''
                                        , td = ModifiedDate     , ''
                                        , td = ModifiedUser     , ''
                                    FROM  inserted
                                     FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
                       + '</table></br></br>'
     WHERE  EXISTS ( SELECT 1 FROM inserted ) ;

    SELECT  @errorData = ISNULL( @errorData, '' )
                       + '<b>contents of deleted trigger table</b></br></br>'
                       + '<table border="1">'
                       + '<tr><th>ClientFirmsID</th><th>ClientID</th><th>FirmCategoriesID</th>'
                       + '<th>ModifiedDate</th><th>ModifiedUser</th></tr>'
                       + CAST ( ( SELECT  td = ClientFirmsID    , ''
                                        , td = ClientID         , ''
                                        , td = FirmCategoriesID , ''
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
