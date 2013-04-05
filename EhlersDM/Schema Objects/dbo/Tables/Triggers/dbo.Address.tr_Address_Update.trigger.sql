CREATE TRIGGER dbo.tr_Address_Update ON dbo.Address
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
    1)  Create dbo.AddressAudit records reflecting UPDATE
    2)  Stop processing when trigger is invoked by Conversion.processAddresses procedure
    3)  Update Address Data back to dbo.Firms
    4)  Update Address Data back to dbo.Clients
    5)  Update Address Data back to dbo.FirmContacts
    6)  Update Address Data back to dbo.ClientContacts

************************************************************************************************************************************
*/
BEGIN
BEGIN TRY

    SET NOCOUNT ON ;

    IF  NOT EXISTS ( SELECT 1 FROM inserted )
            AND
        NOT EXISTS ( SELECT 1 FROM deleted )
        RETURN ;


    DECLARE @conversionProcess  AS VARBINARY(128)   = CAST( 'conversionProcess' AS VARBINARY(128) ) ;


    DECLARE @codeBlockDesc01    AS SYSNAME          = 'Create dbo.AddressAudit records reflecting UPDATE'
          , @codeBlockDesc02    AS SYSNAME          = 'Stop processing when trigger is invoked during conversion process'
          , @codeBlockDesc03    AS SYSNAME          = 'Update Address Data back to edata.Firms'
          , @codeBlockDesc04    AS SYSNAME          = 'Update Address Data back to edata.Clients'
          , @codeBlockDesc05    AS SYSNAME          = 'Update Address Data back to edata.FirmContacts'
          , @codeBlockDesc06    AS SYSNAME          = 'Update Address Data back to edata.ClientContacts' ;


    DECLARE @codeBlockNum       AS INT
          , @codeBlockDesc      AS SYSNAME
          , @errorTypeID        AS INT
          , @errorSeverity      AS INT
          , @errorState         AS INT
          , @errorNumber        AS INT
          , @errorLine          AS INT
          , @errorProcedure     AS SYSNAME
          , @errorMessage       AS NVARCHAR (MAX)   = NULL
          , @errorData          AS NVARCHAR (MAX)   = NULL ;


/**/SELECT  @codeBlockNum   = 1
/**/      , @codeBlockDesc  = @codeBlockDesc01 ; -- Create dbo.AddressAudit records reflecting UPDATE

    INSERT  dbo.AddressAudit (
            AddressID
                , Address1, Address2, Address3
                , City, State, Zip
                , Verified
                , ChangeType
                , ModifiedDate, ModifiedUser )
    SELECT  d.AddressID
                , d.Address1, d.Address2, d.Address3
                , d.City, d.State, d.Zip
                , d.Verified
                , 'U'
                , i.ModifiedDate, i.ModifiedUser
      FROM  inserted AS i
INNER JOIN  deleted  AS d ON i.AddressID = d.AddressID ;


/**/SELECT  @codeBlockNum   = 2
/**/      , @codeBlockDesc  = @codeBlockDesc02 ; -- Stop processing when trigger is invoked during conversion process

    IF  CONTEXT_INFO() = @conversionProcess RETURN ;


/**/SELECT  @codeBlockNum   = 3
/**/      , @codeBlockDesc  = @codeBlockDesc03 ; -- Update Address Data back to edata.Firms

    UPDATE  edata.Firms
       SET  Address1   = i.Address1
          , Address2   = i.Address2
          , City       = i.City
          , [State]    = i.[State]
          , Zip        = i.Zip
          , ChangeDate = i.ModifiedDate
          , ChangeBy   = i.ModifiedUser
          , ChangeCode = 'CVAddress'
      FROM  inserted AS i
INNER JOIN  Conversion.LegacyAddresses AS la
        ON  la.AddressID = i.AddressID AND la.LegacyTableName = 'Firms'
INNER JOIN  edata.Firms AS f
        ON  f.FirmID = la.LegacyID ;


/**/SELECT  @codeBlockNum   = 4
/**/      , @codeBlockDesc  = @codeBlockDesc04 ; -- Update Address Data back to edata.Clients

    UPDATE  edata.Clients
       SET  Address1   = i.Address1
          , Address2   = i.Address2
          , City       = i.City
          , [State]    = i.[State]
          , Zip        = i.Zip
          , ChangeDate = i.ModifiedDate
          , ChangeBy   = i.ModifiedUser
          , ChangeCode = 'CVAddress'
      FROM  inserted AS i
INNER JOIN  Conversion.LegacyAddresses AS la
        ON  la.AddressID = i.AddressID AND la.LegacyTableName = 'Clients'
INNER JOIN  edata.Clients AS c
        ON  c.ClientID = la.LegacyID ;


/**/SELECT  @codeBlockNum   = 5
/**/      , @codeBlockDesc  = @codeBlockDesc05 ; -- Update Address Data back to edata.FirmContacts

    UPDATE  edata.FirmContacts
       SET  Address1   = i.Address1
          , Address2   = i.Address2
          , City       = i.City
          , [State]    = i.[State]
          , Zip        = i.Zip
          , ChangeDate = i.ModifiedDate
          , ChangeBy   = i.ModifiedUser
          , ChangeCode = 'CVAddress'
      FROM  inserted AS i
INNER JOIN  Conversion.LegacyAddresses AS la
        ON  la.AddressID = i.AddressID AND la.LegacyTableName = 'FirmContacts'
INNER JOIN  edata.FirmContacts AS fc
        ON  fc.ContactID = la.LegacyID ;


/**/SELECT  @codeBlockNum   = 6
/**/      , @codeBlockDesc  = @codeBlockDesc06 ; -- Update Address Data back to edata.ClientContacts

    UPDATE  edata.ClientContacts
       SET  Address1   = i.Address1
          , Address2   = i.Address2
          , City       = i.City
          , [State]    = i.[State]
          , Zip        = i.Zip
          , ChangeDate = i.ModifiedDate
          , ChangeBy   = i.ModifiedUser
          , ChangeCode = 'CVAddress'
      FROM  inserted AS i
INNER JOIN  Conversion.LegacyAddresses AS la
        ON  la.AddressID = i.AddressID AND la.LegacyTableName = 'ClientContacts'
INNER JOIN  edata.ClientContacts AS cc
        ON  cc.ContactID = la.LegacyID ;

END TRY
BEGIN CATCH

    IF  EXISTS ( SELECT 1 FROM inserted )
        SELECT  @errorData = N'<b>contents of inserted trigger table</b></br></br><table border="1">'
                           + N'<tr><th>AddressID</th><th>Address1</th><th>Address2</th><th>Address3</th>'
                           + N'<th>City</th><th>State</th><th>Zip</th><th>Verified</th>'
                           + N'<th>ModifiedDate</th><th>ModifiedUser</th></tr>'
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
                                         FOR  XMLPATH( 'tr' ), ELEMENTS XSINIL, TYPE ) AS NVARCHAR(MAX) ) 
                           + N'</table></br></br>' ;
    ELSE
        SELECT  @errorData = '' ;


    IF  EXISTS ( SELECT 1 FROM deleted )
        SELECT  @errorData = @errorData 
                           + N'<b>contents of deleted trigger table</b></br></br><table border="1">'
                           + N'<tr><th>AddressID</th><th>Address1</th><th>Address2</th><th>Address3</th>'
                           + N'<th>City</th><th>State</th><th>Zip</th><th>Verified</th>'
                           + N'<th>ModifiedDate</th><th>ModifiedUser</th></tr>'
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
                                         FOR  XMLPATH( 'tr' ), ELEMENTS XSINIL, TYPE ) AS NVARCHAR(MAX) ) 
                           + N'</table></br></br>' ;

    ROLLBACK TRANSACTION ;

    SELECT  @errorTypeID    = 1
          , @errorSeverity  = ERROR_SEVERITY()
          , @errorState     = ERROR_STATE()
          , @errorNumber    = ERROR_NUMBER()
          , @errorLine      = ERROR_LINE()
          , @errorProcedure = ERROR_PROCEDURE()

    IF  @errorMessage IS NULL
    BEGIN
        SELECT  @errorMessage = N'Error occurred in Code Block %d, %s ' + CHAR(13)
                              + N'Error %d, Level %d, State %d, Procedure %s, Line %d' + CHAR(13)
                              + N'Message: ' + ERROR_MESSAGE() ;

        RAISERROR( @errorMessage, @errorSeverity, 1
                 , @codeBlockNum
                 , @codeBlockDesc
                 , @errorNumber
                 , @errorSeverity
                 , @errorState
                 , @errorProcedure
                 , @errorLine ) ;

        SELECT  @errorMessage = ERROR_MESSAGE() ;

        EXECUTE dbo.processEhlersErrorNEW  @errorTypeID
                                      , @codeBlockNum
                                      , @codeBlockDesc
                                      , @errorNumber
                                      , @errorSeverity
                                      , @errorState
                                      , @errorProcedure
                                      , @errorLine
                                      , @errorMessage
                                      , @errorData ;

    END
        ELSE
    BEGIN
        SELECT  @errorSeverity  = ERROR_SEVERITY()
              , @errorState     = ERROR_STATE()

        RAISERROR( @errorMessage, @errorSeverity, @errorState ) ;
    END

END CATCH
END

