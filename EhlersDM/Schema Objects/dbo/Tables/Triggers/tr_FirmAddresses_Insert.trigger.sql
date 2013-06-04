CREATE TRIGGER  tr_FirmAddresses_Insert
            ON  dbo.FirmAddresses
AFTER INSERT
AS
/*
************************************************************************************************************************************

    Trigger:    tr_FirmAddresses_Insert
     Author:    Chris Carson
    Purpose:    loads dbo.Address data back to edata.Firms


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Stop processing when trigger is fired from Conversion
    2)  UPDATE Address Data back to edata.Firms
    3)  INSERT Conversion.LegacyAddresses from trigger data

    Notes:

************************************************************************************************************************************
*/
BEGIN
BEGIN TRY

    IF  NOT EXISTS ( SELECT 1 FROM inserted WHERE AddressTypeID = 3 )
        RETURN ;

    SET NOCOUNT ON ;

    DECLARE @codeBlockNum       AS INT
          , @codeBlockDesc      AS SYSNAME
          , @codeBlockDesc01    AS SYSNAME  = 'INSERT into dbo.FirmAddressesAudit'
          , @codeBlockDesc02    AS SYSNAME  = 'Stop processing when trigger is fired from Conversion'
          , @codeBlockDesc03    AS SYSNAME  = 'UPDATE Address Data back to edata.Firms'
          , @codeBlockDesc04    AS SYSNAME  = 'INSERT Conversion.LegacyAddresses from trigger data' ;



    DECLARE @fromConversion     AS VARBINARY (128)  = CAST( 'fromConversion' AS VARBINARY (128) ) ;



/**/SELECT  @codeBlockNum = 01, @codeBlockDesc = @codeBlockDesc01 ; --  Stop processing when trigger is fired from Conversion
    IF  CONTEXT_INFO() = @fromConversion
        RETURN ;



/**/SELECT  @codeBlockNum = 02, @codeBlockDesc = @codeBlockDesc02 ; --  UPDATE Address Data back to dbo.Firms
    UPDATE  edata.Firms
       SET  Address1    = adr.Address1
          , Address2    = adr.Address2
          , City        = adr.City
          , State       = adr.State
          , Zip         = adr.Zip
          , ChangeDate  = ins.ModifiedDate
          , ChangeBy    = ins.ModifiedUser
          , ChangeCode  = 'CVAddress'
      FROM  inserted    AS ins
INNER JOIN  dbo.Address AS adr ON adr.AddressID = ins.AddressID
INNER JOIN  edata.Firms AS frm ON frm.FirmId    = ins.FirmID
     WHERE  ins.AddressTypeID = 3 ;

     

/**/SELECT  @codeBlockNum = 03, @codeBlockDesc = @codeBlockDesc03 ; --  INSERT Conversion.LegacyAddresses from trigger data
    INSERT  Conversion.LegacyAddresses ( LegacyID, LegacyTableName, AddressID )
    SELECT  FirmID, 'Firms', AddressID FROM inserted
     WHERE  AddressTypeID = 3 ;

     

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

