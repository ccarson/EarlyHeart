CREATE TRIGGER  tr_ContactAddresses_Delete
            ON  dbo.ContactAddresses
AFTER DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_ContactAddresses_Delete
     Author:    Chris Carson
    Purpose:    Applies address data to specified edata.ClientContacts or edata.FirmContacts records

    Revision History:
    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Stop processing when trigger is fired from Conversion
    2)  UPDATE Address Data back to edata.FirmContacts
    3)  UPDATE Address Data back to edata.ClientContacts
    4)  Delete Conversion.LegacyAddresses from trigger data

    Notes:

********************************************************************************
*/
BEGIN
BEGIN TRY

    IF  NOT EXISTS ( SELECT 1 FROM deleted WHERE AddressTypeID = 3 )
        RETURN ;

    SET NOCOUNT ON ;

    DECLARE @codeBlockNum       AS INT
          , @codeBlockDesc      AS SYSNAME
          , @codeBlockDesc01    AS SYSNAME  = 'Stop processing when trigger is fired from Conversion'
          , @codeBlockDesc02    AS SYSNAME  = 'UPDATE Address Data back to edata.FirmContacts'
          , @codeBlockDesc03    AS SYSNAME  = 'UPDATE Address Data back to edata.ClientContacts'
          , @codeBlockDesc04    AS SYSNAME  = 'Delete Conversion.LegacyAddresses from trigger data' ;



    DECLARE @fromConversion     AS VARBINARY (128)  = CAST( 'fromConversion' AS VARBINARY (128) ) ;

    DECLARE @systemUser         AS VARCHAR (20) = dbo.udf_GetSystemUser() ;



/**/SELECT  @codeBlockNum = 01, @codeBlockDesc = @codeBlockDesc01 ; --  Stop processing when trigger is fired from Conversion
    IF  CONTEXT_INFO() = @fromConversion
        RETURN ;



/**/SELECT  @codeBlockNum = 02, @codeBlockDesc = @codeBlockDesc02 ; --  UPDATE Address Data back to edata.FirmContacts
    UPDATE  edata.FirmContacts
       SET  Address1    = ''
          , Address2    = ''
          , City        = ''
          , State       = ''
          , Zip         = ''
          , ChangeDate  = GETDATE()
          , ChangeBy    = @systemUser
          , ChangeCode  = 'CVAddress'
      FROM  deleted                     AS del
INNER JOIN  Conversion.LegacyAddresses  AS lad ON lad.AddressID = del.AddressID AND del.AddressTypeID = 3
INNER JOIN  edata.FirmContacts          AS frc ON frc.ContactId = lad.LegacyID ;



/**/SELECT  @codeBlockNum = 03, @codeBlockDesc = @codeBlockDesc03 ; --  UPDATE Address Data back to edata.ClientContacts
    UPDATE  edata.ClientContacts
       SET  Address1    = ''
          , Address2    = ''
          , City        = ''
          , State       = ''
          , Zip         = ''
          , ChangeDate  = GETDATE()
          , ChangeBy    = @systemUser
          , ChangeCode  = 'CVAddress'
      FROM  deleted                     AS del
INNER JOIN  Conversion.LegacyAddresses  AS lad ON lad.AddressID = del.AddressID AND del.AddressTypeID = 3
INNER JOIN  edata.ClientContacts        AS clc ON clc.ContactId = lad.LegacyID ;



/**/SELECT  @codeBlockNum = 04, @codeBlockDesc = @codeBlockDesc04 ; --  Delete Conversion.LegacyAddresses from trigger data
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

    SELECT  @errorData = '<b>contents of inserted trigger table</b></br></br>'
                       + '<table border="1">'
                       + '<tr><th>ContactAddressesID</th><th>ContactID</th><th>AddressID</th><th>AddressTypeID</th>'
                       + '<th>ModifiedDate</th><th>ModifiedUser</th></tr>'
                       + CAST ( ( SELECT  td = ContactAddressesID   , ''
                                        , td = ContactID            , ''
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
