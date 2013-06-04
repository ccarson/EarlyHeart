CREATE TRIGGER  tr_ContactMailings
            ON  dbo.ContactMailings
AFTER INSERT, UPDATE, DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_ContactMailings
     Author:    Chris Carson
    Purpose:    writes Mailings changes back to legacy Contacts


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created
    ccarson         ###DATE###          revised error reporting

    Logic Summary:


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
          , @codeBlockDesc01    AS SYSNAME  = 'Stop processing when trigger is fired from Conversion'
          , @codeBlockDesc02    AS SYSNAME  = 'Load ContactIDs into temp storage'
          , @codeBlockDesc03    AS SYSNAME  = 'Load mailings data into temp storage'
          , @codeBlockDesc04    AS SYSNAME  = 'UPDATE dbo.FirmContacts from temp storage'
          , @codeBlockDesc05    AS SYSNAME  = 'UPDATE dbo.ClientContacts from temp storage' ;

    DECLARE @fromConversion     AS VARBINARY (128)  = CAST( 'fromConversion' AS VARBINARY (128) ) ;


    DECLARE @changedData        AS TABLE ( ContactID            INT
                                         , LegacyContactID      INT
                                         , LegacyTableName      VARCHAR (20)
                                         , Mailing              VARCHAR (50)
                                         , ChangeDate           DATETIME
                                         , ChangeBy             VARCHAR (20) ) ;


/**/SELECT  @codeBlockNum = 01, @codeBlockDesc = @codeBlockDesc01 ; --  Stop processing when trigger is fired from Conversion
    IF  CONTEXT_INFO() = @fromConversion
        RETURN ;



/**/SELECT  @codeBlockNum = 02, @codeBlockDesc = @codeBlockDesc02 ; --  Load ContactData into temp storage
    INSERT  @changedData ( ContactID, LegacyContactID, LegacyTableName, ChangeDate, ChangeBy )
    SELECT  ContactID, LegacyContactID, LegacyTableName, ChangeDate, ChangeBy
      FROM  Conversion.vw_ConvertedContacts
     WHERE  ContactID IN ( SELECT ContactID FROM inserted
                                UNION
                           SELECT ContactID FROM deleted ) ; 



/**/SELECT  @codeBlockNum = 03, @codeBlockDesc = @codeBlockDesc03 ; --  Load mailings data into temp storage
    UPDATE  @changedData
       SET  Mailing = m.Mailing
      FROM  Conversion.tvf_LegacyMailings( 'Converted' ) AS m
INNER JOIN  @changedData                                 AS c ON c.ContactID = m.ContactID ;



/**/SELECT  @codeBlockNum = 04, @codeBlockDesc = @codeBlockDesc04 ; --  UPDATE dbo.FirmContacts from temp storage
    UPDATE  edata.FirmContacts
       SET  Mailing     = chg.Mailing
          , ChangeCode  = 'cnvMailing'
          , ChangeDate  = chg.ChangeDate  
          , ChangeBy    = chg.ChangeBy    
      FROM  edata.FirmContacts  AS frc
INNER JOIN  @changedData        AS chg  ON chg.LegacyContactID = frc.ContactId
     WHERE  chg.LegacyTableName = 'FirmContacts' ;



/**/SELECT  @codeBlockNum = 05, @codeBlockDesc = @codeBlockDesc05 ; --  UPDATE dbo.ClientContacts from temp storage
    UPDATE  edata.ClientContacts
       SET  Mailing     = chg.Mailing
          , ChangeCode  = 'cnvMailing'
          , ChangeDate  = chg.ChangeDate  
          , ChangeBy    = chg.ChangeBy    
      FROM  edata.ClientContacts    AS clc
INNER JOIN  @changedData            AS chg  ON chg.LegacyContactID = clc.ContactId
     WHERE  chg.LegacyTableName = 'ClientContacts' ;


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

    SELECT  @errorData = '<b>contents of changed data table</b></br></br>'
                       + '<table border="1">'
                       + '<tr><th>ContactID</th><th>LegacyContactID</th><th>LegacyTableName</th>'
                       + '<th>Mailing</th><th>ModifiedDate</th><th>ModifiedUser</th></tr>'
                       + CAST ( ( SELECT  td = cnv.ContactID        , ''
                                        , td = chg.LegacyContactID  , ''
                                        , td = chg.LegacyTableName  , ''
                                        , td = chg.Mailing          , ''
                                        , td = chg.ChangeDate       , ''
                                        , td = chg.ChangeBy         , ''
                                    FROM  @changedData                      AS chg
                              INNER JOIN  Conversion.vw_ConvertedContacts   AS cnv 
                                      ON  cnv.LegacyContactID = chg.LegacyContactID AND cnv.LegacyTableName = chg.LegacyTableName 
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
