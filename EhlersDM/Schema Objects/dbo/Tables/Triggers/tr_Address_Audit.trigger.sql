CREATE TRIGGER  tr_Address_Audit
            ON  dbo.Address
AFTER INSERT, UPDATE, DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    tr_Address_Audit
     Author:    Chris Carson
    Purpose:    writes audit data to dbo.AddressAudit


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  Determine trigger action
    2)  INSERT dbo.AddressAudit from trigger data

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
          , @codeBlockDesc02    AS SYSNAME  = 'INSERT dbo.AddressAudit from trigger data' ;

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


/**/SELECT  @codeBlockNum = 02, @codeBlockDesc = @codeBlockDesc02 ; --  INSERT dbo.AddressAudit from trigger data
    IF  @action = 'D'
        INSERT  dbo.AddressAudit (
                AddressID, Address1, Address2, Address3, City, State, Zip, Verified, ChangeType, ModifiedDate, ModifiedUser )
        SELECT  AddressID, Address1, Address2, Address3, City, State, Zip, Verified, 'D', GETDATE(), @systemUser
          FROM  deleted ;

    IF  @action = 'I'
        INSERT  dbo.AddressAudit (
                AddressID, Address1, Address2, Address3, City, State, Zip, Verified, ChangeType, ModifiedDate, ModifiedUser )
        SELECT  AddressID, Address1, Address2, Address3, City, State, Zip, Verified, 'I', ModifiedDate, ModifiedUser
          FROM  inserted ;

    IF  @action = 'U'
        INSERT  dbo.AddressAudit (
                AddressID, Address1, Address2, Address3, City, State, Zip, Verified
                    , ChangeType, ModifiedDate, ModifiedUser )
        SELECT  del.AddressID, del.Address1, del.Address2, del.Address3, del.City, del.State, del.Zip, del.Verified
                    , 'U', ins.ModifiedDate, ins.ModifiedUser
          FROM  inserted AS ins
    INNER JOIN  deleted  AS del ON del.AddressID = ins.AddressID ;



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
                       + '</table></br></br>' 
     WHERE  EXISTS ( SELECT 1 FROM inserted ) ;

    SELECT  @errorData = ISNULL( @errorData, '' )
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

