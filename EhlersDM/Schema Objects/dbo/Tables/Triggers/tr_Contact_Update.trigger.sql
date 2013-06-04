CREATE TRIGGER  tr_Contact_Update
            ON  dbo.Contact
AFTER UPDATE
AS
/*
************************************************************************************************************************************

    Trigger:    tr_Contact_Update
     Author:    Chris Carson
    Purpose:    Synchronizes Contact data back to legacy systems


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created
    ccarson         ###DATE###          revised error reporting

    Logic Summary:
    1)  Stop processing when trigger is invoked by Conversion.processContacts procedure
    2)  Stop processing unless Contacts data has actually changed
    3)  UPDATE edata.FirmContacts from trigger data
    4)  UPDATE edata.ClientContacts from trigger data


    Notes:
        Each time trigger executes, either 3) or 4) will run, but not both

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
          , @codeBlockDesc01    AS SYSNAME  = 'Stop processing when trigger is fired from Conversion'
          , @codeBlockDesc02    AS SYSNAME  = 'Stop processing unless Contacts data has actually changed'
          , @codeBlockDesc03    AS SYSNAME  = 'UPDATE edata.FirmContacts from trigger data' 
          , @codeBlockDesc04    AS SYSNAME  = 'UPDATE edata.ClientContacts from trigger data' ;


    DECLARE @fromConversion     AS VARBINARY (128)  = CAST( 'fromConversion' AS VARBINARY (128) )
          , @legacyChecksum     AS INT
          , @convertedChecksum  AS INT ;


/**/SELECT  @codeBlockNum = 01, @codeBlockDesc = @codeBlockDesc01 ; --  Stop processing when trigger is fired from Conversion
    IF  CONTEXT_INFO() = @fromConversion
        RETURN ;



/**/SELECT  @codeBlockNum = 02, @codeBlockDesc = @codeBlockDesc02 ; --  Stop processing unless Contacts data has actually changed
    SELECT  @legacyChecksum = CHECKSUM_AGG( CHECKSUM(*) ) FROM Conversion.tvf_ContactChecksum( 'Legacy' )
     WHERE  ContactID IN ( SELECT ContactID FROM inserted ) ;

    SELECT  @convertedChecksum = CHECKSUM_AGG( CHECKSUM(*) ) FROM Conversion.tvf_ContactChecksum( 'Converted' )
     WHERE  ContactID IN ( SELECT ContactID FROM inserted ) ;

    IF  ( @legacyChecksum = @convertedChecksum )
        RETURN ;


/**/SELECT  @codeBlockNum = 03, @codeBlockDesc = @codeBlockDesc03 ; --  UPDATE edata.FirmContacts from trigger data
    UPDATE  edata.FirmContacts
       SET  NamePrefix  = cnv.NamePrefix
          , FirstName   = cnv.FirstName
          , LastName    = cnv.LastName
          , Department  = cnv.Department
          , Title       = cnv.Title
          , Phone       = cnv.Phone
          , Email       = cnv.Email
          , Fax         = cnv.Fax
          , CellPhone   = cnv.CellPhone
          , Notes       = cnv.Notes
          , ChangeCode  = 'cnvContact'
          , ChangeDate  = cnv.ChangeDate
          , ChangeBy    = cnv.ChangeBy
      FROM  Conversion.vw_ConvertedContacts  AS cnv
INNER JOIN  edata.FirmContacts               AS frm ON  frm.ContactId = cnv.LegacyContactID AND cnv.LegacyTableName = 'FirmContacts'
     WHERE  cnv.ContactID IN ( SELECT ContactID FROM inserted ) ;



/**/SELECT  @codeBlockNum = 04, @codeBlockDesc = @codeBlockDesc04 ; --  UPDATE edata.ClientContacts from trigger data
    UPDATE  edata.ClientContacts
       SET  NamePrefix  = cnv.NamePrefix
          , FirstName   = cnv.FirstName
          , LastName    = cnv.LastName
          , Department  = cnv.Department
          , Title       = cnv.Title
          , Phone       = cnv.Phone
          , Email       = cnv.Email
          , Fax         = cnv.Fax
          , CellPhone   = cnv.CellPhone
          , Notes       = cnv.Notes
          , ChangeCode  = 'CVContact'
          , ChangeDate  = cnv.ChangeDate
          , ChangeBy    = cnv.ChangeBy
      FROM  Conversion.vw_ConvertedContacts  AS cnv
INNER JOIN  edata.ClientContacts             AS cli ON cli.ContactId = cnv.LegacyContactID AND  cnv.LegacyTableName = 'ClientContacts'
     WHERE  cnv.ContactID IN ( SELECT ContactID FROM inserted ) ;


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

    IF  @codeBlockNum = 03
        SELECT  @errorData = '<b>data to be updated on edata.FirmContacts</b></br></br>'
                           + '<table border="1">'
                           + '<tr><th>ContactID</th><th>NamePrefix</th><th>FirstName</th><th>LastName</th><th>Department</th>'
                           + '<th>Title</th><th>Phone</th><th>Email</th><th>Fax</th><th>CellPhone</th><th>Notes</th>'
                           + '<th>ChangeCode</th><th>ChangeDate</th><th>ChangeBy</th></tr>'
                           + CAST ( ( SELECT  td = cnv.LegacyContactID, ''
                                           ,  td = cnv.NamePrefix, ''
                                           ,  td = cnv.FirstName, ''
                                           ,  td = cnv.LastName, ''
                                           ,  td = cnv.Department, ''
                                           ,  td = cnv.Title, ''
                                           ,  td = cnv.Phone, ''
                                           ,  td = cnv.Email, ''
                                           ,  td = cnv.Fax, ''
                                           ,  td = cnv.CellPhone, ''
                                           ,  td = cnv.Notes, ''
                                           ,  td = 'CVContact', ''
                                           ,  td = cnv.ChangeDate, ''
                                           ,  td = cnv.ChangeBy, ''
                                        FROM  Conversion.vw_ConvertedContacts  AS cnv
                                  INNER JOIN  edata.FirmContacts               AS frm ON  frm.ContactId = cnv.LegacyContactID AND cnv.LegacyTableName = 'FirmContacts'
                                       WHERE  cnv.ContactID IN ( SELECT ContactID FROM inserted ) 
                                         AND  cnv.LegacyTableName = 'FirmContacts'
                                         FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
                           + N'</table></br></br>' ;

    IF  @codeBlockNum = 04
        SELECT  @errorData = '<b>data to be updated on edata.ClientContacts</b></br></br>'
                           + '<table border="1">'
                           + '<tr><th>ContactID</th><th>NamePrefix</th><th>FirstName</th><th>LastName</th><th>Department</th>'
                           + '<th>Title</th><th>Phone</th><th>Email</th><th>Fax</th><th>CellPhone</th><th>Notes</th>'
                           + '<th>ChangeCode</th><th>ChangeDate</th><th>ChangeBy</th></tr>'
                           + CAST ( ( SELECT  td = cnv.LegacyContactID, ''
                                           ,  td = cnv.NamePrefix, ''
                                           ,  td = cnv.FirstName, ''
                                           ,  td = cnv.LastName, ''
                                           ,  td = cnv.Department, ''
                                           ,  td = cnv.Title, ''
                                           ,  td = cnv.Phone, ''
                                           ,  td = cnv.Email, ''
                                           ,  td = cnv.Fax, ''
                                           ,  td = cnv.CellPhone, ''
                                           ,  td = cnv.Notes, ''
                                           ,  td = 'CVContact', ''
                                           ,  td = cnv.ChangeDate, ''
                                           ,  td = cnv.ChangeBy, ''
                                        FROM  Conversion.vw_ConvertedContacts  AS cnv
                                  INNER JOIN  edata.ClientContacts             AS cli ON cli.ContactId = cnv.LegacyContactID AND  cnv.LegacyTableName = 'ClientContacts'
                                       WHERE  cnv.ContactID IN ( SELECT ContactID FROM inserted ) 
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
