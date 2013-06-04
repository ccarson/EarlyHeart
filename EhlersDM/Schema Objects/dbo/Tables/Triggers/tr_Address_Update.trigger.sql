CREATE TRIGGER  tr_Address_Update
            ON  dbo.Address
AFTER UPDATE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_Address_Update
     Author:    Chris Carson
    Purpose:    applies Address change data back to legacy tables


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Stop processing when trigger is fired from Conversion
    2)  UPDATE Address Data back to edata.Firms
    3)  UPDATE Address Data back to edata.Clients
    4)  UPDATE Address Data back to edata.FirmContacts
    5)  UPDATE Address Data back to edata.ClientContacts

************************************************************************************************************************************
*/
BEGIN
BEGIN TRY

    SET NOCOUNT ON ;

    IF  NOT EXISTS ( SELECT 1 FROM inserted )
        IF  NOT EXISTS ( SELECT 1 FROM deleted )
            RETURN ;

    SET NOCOUNT ON ;

    DECLARE @codeBlockNum       AS INT
          , @codeBlockDesc      AS SYSNAME
          , @codeBlockDesc01    AS SYSNAME          = 'Stop processing when trigger is fired from Conversion'
          , @codeBlockDesc02    AS SYSNAME          = 'UPDATE Address Data back to edata.Firms'
          , @codeBlockDesc03    AS SYSNAME          = 'UPDATE Address Data back to edata.Clients'
          , @codeBlockDesc04    AS SYSNAME          = 'UPDATE Address Data back to edata.FirmContacts'
          , @codeBlockDesc05    AS SYSNAME          = 'UPDATE Address Data back to edata.ClientContacts' ;



    DECLARE @fromConversion AS VARBINARY (128) = CAST( 'fromConversion' AS VARBINARY (128) ) ; ;



/**/SELECT  @codeBlockNum = 01, @codeBlockDesc = @codeBlockDesc01 ; --  Stop processing when trigger is fired from Conversion
    IF  CONTEXT_INFO() = @fromConversion
        RETURN ;



/**/SELECT  @codeBlockNum = 02, @codeBlockDesc = @codeBlockDesc02 ; --  UPDATE Address Data back to edata.Firms
    UPDATE  edata.Firms
       SET  Address1   = ins.Address1
          , Address2   = ins.Address2
          , City       = ins.City
          , [State]    = ins.[State]
          , Zip        = ins.Zip
          , ChangeDate = ins.ModifiedDate
          , ChangeBy   = ins.ModifiedUser
          , ChangeCode = 'CVAddress'
      FROM  inserted                    AS ins
INNER JOIN  Conversion.LegacyAddresses  AS lad ON lad.AddressID = ins.AddressID AND lad.LegacyTableName = 'Firms'
INNER JOIN  edata.Firms                 AS frm ON frm.FirmId = lad.LegacyID ;



/**/SELECT  @codeBlockNum = 03, @codeBlockDesc = @codeBlockDesc03 ; --  UPDATE Address Data back to edata.Clients
    UPDATE  edata.Clients
       SET  Address1   = ins.Address1
          , Address2   = ins.Address2
          , City       = ins.City
          , [State]    = ins.[State]
          , Zip        = ins.Zip
          , ChangeDate = ins.ModifiedDate
          , ChangeBy   = ins.ModifiedUser
          , ChangeCode = 'CVAddress'
      FROM  inserted                    AS ins
INNER JOIN  Conversion.LegacyAddresses  AS lad ON lad.AddressID = ins.AddressID AND lad.LegacyTableName = 'Clients'
INNER JOIN  edata.Clients               AS cli ON cli.ClientId = lad.LegacyID ;



/**/SELECT  @codeBlockNum = 04, @codeBlockDesc = @codeBlockDesc04 ; --  UPDATE Address Data back to edata.FirmContacts
    UPDATE  edata.FirmContacts
       SET  Address1   = ins.Address1
          , Address2   = ins.Address2
          , City       = ins.City
          , [State]    = ins.[State]
          , Zip        = ins.Zip
          , ChangeDate = ins.ModifiedDate
          , ChangeBy   = ins.ModifiedUser
          , ChangeCode = 'CVAddress'
      FROM  inserted                    AS ins
INNER JOIN  Conversion.LegacyAddresses  AS lad ON lad.AddressID = ins.AddressID AND lad.LegacyTableName = 'FirmContacts'
INNER JOIN  edata.FirmContacts          AS frc ON frc.ContactId = lad.LegacyID ;



/**/SELECT  @codeBlockNum = 05, @codeBlockDesc = @codeBlockDesc05 ; --  UPDATE Address Data back to edata.ClientContacts
    UPDATE  edata.ClientContacts
       SET  Address1   = ins.Address1
          , Address2   = ins.Address2
          , City       = ins.City
          , [State]    = ins.[State]
          , Zip        = ins.Zip
          , ChangeDate = ins.ModifiedDate
          , ChangeBy   = ins.ModifiedUser
          , ChangeCode = 'CVAddress'
      FROM  inserted                    AS ins
INNER JOIN  Conversion.LegacyAddresses  AS lad ON lad.AddressID = ins.AddressID AND lad.LegacyTableName = 'ClientContacts'
INNER JOIN  edata.ClientContacts        AS clc ON clc.ContactId = lad.LegacyID ;



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

    SELECT  @errorData = '<b>contents of inserted trigger table</b></br></br><table border="1">'
                       + '<tr><th>AddressID</th><th>Address1</th><th>Address2</th><th>Address3</th>'
                       + '<th>City</th><th>State</th><th>Zip</th><th>Verified</th>'
                       + '<th>ModifiedDate</th><th>ModifiedUser</th></tr>'
                       + CAST ( ( SELECT  td = AddressID    , ''
                                        , td = Address1     , ''
                                        , td = Address2     , ''
                                        , td = Address3     , ''
                                        , td = City         , ''
                                        , td = State        , ''
                                        , td = Zip          , ''
                                        , td = Verified     , ''
                                        , td = ModifiedDate , ''
                                        , td = ModifiedUser , ''
                                    FROM  inserted
                                     FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
                       + '</table></br></br>' ;

    SELECT  @errorData = @errorData
                       + '<b>contents of deleted trigger table</b></br></br><table border="1">'
                       + '<tr><th>AddressID</th><th>Address1</th><th>Address2</th><th>Address3</th>'
                       + '<th>City</th><th>State</th><th>Zip</th><th>Verified</th>'
                       + '<th>ModifiedDate</th><th>ModifiedUser</th></tr>'
                       + CAST ( ( SELECT  td = AddressID    , ''
                                        , td = Address1     , ''
                                        , td = Address2     , ''
                                        , td = Address3     , ''
                                        , td = City         , ''
                                        , td = State        , ''
                                        , td = Zip          , ''
                                        , td = Verified     , ''
                                        , td = ModifiedDate , ''
                                        , td = ModifiedUser , ''
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

