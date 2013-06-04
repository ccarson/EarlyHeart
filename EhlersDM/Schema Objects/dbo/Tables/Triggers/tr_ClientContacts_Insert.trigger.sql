CREATE TRIGGER  tr_ClientContacts_Insert
            ON  dbo.ClientContacts
AFTER INSERT
AS
/*
************************************************************************************************************************************

    Trigger:    tr_ClientContacts_Insert
     Author:    Chris Carson
    Purpose:    Synchronizes contact data back to dbo.ClientContacts

    revisor         date                description
    ---------       ----------          ----------------------------
    ccarson         2013-01-24          created
    ccarson         ###DATE###          revised error reporting


    Logic Summary:
    1)  Stop processing when trigger is fired from Conversion
    2)  SELECT current ContactID from edata.ClientContacts for INSERT
    3)  INSERT Conversion.LegacyContacts from trigger tables
    4)  INSERT edata.ClientContacts from trigger data

    Notes:

************************************************************************************************************************************
*/
BEGIN
BEGIN TRY

    IF  NOT EXISTS ( SELECT 1 FROM inserted )
        RETURN ;

    SET NOCOUNT ON ;

    DECLARE @codeBlockNum       AS INT
          , @codeBlockDesc      AS SYSNAME
          , @codeBlockDesc01    AS SYSNAME = 'Stop processing when trigger is fired from Conversion'
          , @codeBlockDesc02    AS SYSNAME = 'SELECT current ContactID from edata.ClientContacts for INSERT'
          , @codeBlockDesc03    AS SYSNAME = 'INSERT Conversion.LegacyContacts from trigger tables'
          , @codeBlockDesc04    AS SYSNAME = 'INSERT edata.ClientContacts from trigger data' ;


    DECLARE @fromConversion     AS VARBINARY (128)  = CAST( 'fromConversion' AS VARBINARY (128) )
          , @currentContactID   AS INT = 0 ;



/**/SELECT  @codeBlockNum = 01, @codeBlockDesc = @codeBlockDesc01 ; --  Stop processing when trigger is fired from Conversion
    IF  CONTEXT_INFO() = @fromConversion
        RETURN ;



/**/SELECT  @codeBlockNum = 02, @codeBlockDesc = @codeBlockDesc02 ; --  SELECT current ContactID from edata.ClientContacts for INSERT
    SELECT  @currentContactID = ISNULL( MAX( ContactID ), 0 )
      FROM  edata.ClientContacts ;



/**/SELECT  @codeBlockNum = 03, @codeBlockDesc = @codeBlockDesc03 ; --  INSERT Conversion.LegacyContacts from trigger tables
    INSERT  Conversion.LegacyContacts ( ContactID, LegacyTableName, LegacyContactID )
    SELECT  ContactID       = ContactID
          , LegacyTableName = 'ClientContacts'
          , LegacyContactID = @currentContactID + ROW_NUMBER() OVER ( ORDER BY (SELECT NULL) )
      FROM  inserted ;



/**/SELECT  @codeBlockNum = 04, @codeBlockDesc = @codeBlockDesc04 ; --  INSERT edata.ClientContacts from trigger data
    INSERT  edata.ClientContacts (
            ContactId, ClientId, CDN, NamePrefix, FirstName, LastName
                , Title, Department, Phone, Email, Fax, CellPhone, Notes
                , ChangeCode, ChangeDate, ChangeBy )
    SELECT  ContactID   = lgc.LegacyContactID
          , ClientID    = ins.ClientID
          , CDN         = cli.ClientDescriptiveName
          , NamePrefix  = cnv.NamePrefix
          , FirstName   = cnv.FirstName
          , LastName    = cnv.LastName
          , Title       = cnv.Title
          , Department  = cnv.Department
          , Phone       = cnv.Phone
          , Email       = cnv.Email
          , Fax         = cnv.Fax
          , CellPhone   = cnv.CellPhone
          , Notes       = cnv.Notes
          , ChangeCode  = 'cnvContact'
          , ChangeDate  = cnv.ChangeDate
          , ChangeBy    = cnv.ChangeBy
      FROM  inserted                        AS ins
INNER JOIN  edata.Clients                   AS cli ON cli.ClientId  = ins.ClientID
INNER JOIN  Conversion.LegacyContacts       AS lgc ON lgc.ContactID = ins.ContactID
INNER JOIN  Conversion.vw_ConvertedContacts AS cnv ON cnv.ContactID = ins.ContactID ;


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

    SELECT  @errorData = '<b>contents of insert to edata.ClientContacts</b></br></br>'
                       + '<table border="1">'
                       + '<tr><th>ContactID</th><th>ClientID</th><th>FDN</th><th>NamePrefix</th><th>FirstName</th><th>LastName</th>'
                       + '<th>Title</th><th>Department</th><th>Phone</th><th>Email</th><th>Fax</th><th>CellPhone</th><th>Notes</th>'
                       + '<th>ChangeCode</th><th>ChangeDate</th><th>ChangeBy</th></tr>'
                       + CAST ( ( SELECT  td = lgc.LegacyContactID, ''
                                       ,  td = ins.ClientID, ''
                                       ,  td = cli.ClientDescriptiveName, ''
                                       ,  td = cnv.NamePrefix, ''
                                       ,  td = cnv.FirstName, ''
                                       ,  td = cnv.LastName, ''
                                       ,  td = cnv.Title, ''
                                       ,  td = cnv.Department, ''
                                       ,  td = cnv.Phone, ''
                                       ,  td = cnv.Email, ''
                                       ,  td = cnv.Fax, ''
                                       ,  td = cnv.CellPhone, ''
                                       ,  td = cnv.Notes, ''
                                       ,  td = 'cnvContact', ''
                                       ,  td = cnv.ChangeDate, ''
                                       ,  td = cnv.ChangeBy, ''
                                    FROM  inserted                        AS ins
                              INNER JOIN  edata.Clients                   AS cli ON cli.ClientId  = ins.ClientID
                              INNER JOIN  Conversion.LegacyContacts       AS lgc ON lgc.ContactID = ins.ContactID
                              INNER JOIN  Conversion.vw_ConvertedContacts AS cnv ON cnv.ContactID = ins.ContactID
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
