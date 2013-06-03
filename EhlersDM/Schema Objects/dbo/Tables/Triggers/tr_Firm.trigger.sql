CREATE TRIGGER  tr_Firm
            ON  dbo.Firm
AFTER INSERT, UPDATE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_Firm
     Author:    Chris Carson
    Purpose:    writes Firm data back to legacy edata.dbo.Firms

    revisor         date                description
    ---------       ----------          ----------------------------
    ccarson         2013-01-24          created
    ccarson         ###DATE###          revised error reporting

    Logic Summary:
    1)  Stop processing when trigger is invoked by Conversion.processFirms
    2)  Stop processing unless Firm data has actually changed
    3)  Merge data from dbo.Firm back to edata.dbo.Firms

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
          , @codeBlockDesc01    AS SYSNAME  = 'Stop processing when trigger is fired from Conversion'
          , @codeBlockDesc02    AS SYSNAME  = 'Stop processing unless Firm data has actually changed'
          , @codeBlockDesc03    AS SYSNAME  = 'MERGE new Firm data onto edata.Firms' ;



    DECLARE @fromConversion     AS VARBINARY (128)  = CAST( 'fromConversion' AS VARBINARY (128) )
          , @legacyChecksum     AS INT
          , @convertedChecksum  AS INT ;



/**/SELECT  @codeBlockNum = 01, @codeBlockDesc = @codeBlockDesc01 ; --  Stop processing when trigger is fired from Conversion
    IF  CONTEXT_INFO() = @fromConversion
        RETURN ;



/**/SELECT  @codeBlockNum = 02, @codeBlockDesc = @codeBlockDesc02 ; --  Stop processing unless Firm data has actually changed
    SELECT  @legacyChecksum = CHECKSUM_AGG( CHECKSUM(*) )
      FROM  Conversion.tvf_FirmChecksum( 'Legacy' )
     WHERE  FirmID IN ( SELECT FirmID FROM inserted ) ;

    SELECT  @convertedChecksum = CHECKSUM_AGG( CHECKSUM(*) )
      FROM  Conversion.tvf_FirmChecksum( 'Converted' )
     WHERE  FirmID IN ( SELECT FirmID FROM inserted ) ;

    IF  @legacyChecksum = @convertedChecksum
        RETURN ;



/**/SELECT  @codeBlockNum = 03, @codeBlockDesc = @codeBlockDesc03 ; --  MERGE new Firm data onto edata.Firms
      WITH  changedFirms AS (
            SELECT * FROM Conversion.vw_ConvertedFirms
             WHERE FirmID IN ( SELECT FirmID FROM inserted ) )

     MERGE  edata.Firms     AS tgt
     USING  changedFirms    AS src ON tgt.FirmId = src.FirmID
      WHEN  MATCHED THEN
            UPDATE SET  Firm       = src.Firm
                      , FirmStatus = src.FirmStatus
                      , ShortName  = src.ShortName
                      , Phone      = src.Phone
                      , Fax        = src.Fax
                      , TollFree   = src.TollFree
                      , WebSite    = src.WebSite
                      , GoodFaith  = src.GoodFaith
                      , Notes      = src.Notes
                      , ChangeDate = src.ChangeDate
                      , ChangeCode = 'cvUPDATE'
                      , ChangeBy   = src.ChangeBy
      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( FirmId, Firm, FirmStatus, ShortName, Phone, Fax, TollFree
                        , WebSite, GoodFaith, Notes, ChangeDate, ChangeCode, ChangeBy )
            VALUES ( src.FirmID, src.Firm, src.FirmStatus, src.ShortName, src.Phone, src.Fax, src.TollFree
                        , src.WebSite, src.GoodFaith, src.Notes, src.ChangeDate, 'cvINSERT', src.ChangeBy ) ;


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
                       + '<tr><th>FirmID</th><th>FirmName</th><th>ShortName</th><th>Active</th>'
                       + '<th>FirmPhone</th><th>FirmTollFree</th><th>FirmFax</th><th>FirmEmail</th>'
                       + '<th>FirmWebSite</th><th>FirmABANumber</th><th>DTCAgent</th><th>FirmNotes</th>'
                       + '<th>GoodFaith</th><th>ParentFirmID</th><th>ModifiedDate</th><th>ModifiedUser</th></tr>'
                       + CAST ( ( SELECT  td = FirmID         , ''
                                        , td = FirmName       , ''
                                        , td = ShortName      , ''
                                        , td = Active         , ''
                                        , td = FirmPhone      , ''
                                        , td = FirmTollFree   , ''
                                        , td = FirmFax        , ''
                                        , td = FirmEmail      , ''
                                        , td = FirmWebSite    , ''
                                        , td = FirmABANumber  , ''
                                        , td = DTCAgent       , ''
                                        , td = FirmNotes      , ''
                                        , td = GoodFaith      , ''
                                        , td = ParentFirmID   , ''
                                        , td = ModifiedDate   , ''
                                        , td = ModifiedUser   , ''
                                    FROM  inserted
                                     FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
                       + '</table></br></br>' ;


    SELECT  @errorData = @errorData
                       + '<b>contents of deleted trigger table</b></br></br>'
                       + '<table border="1">'
                       + '<tr><th>FirmID</th><th>FirmName</th><th>ShortName</th><th>Active</th>'
                       + '<th>FirmPhone</th><th>FirmTollFree</th><th>FirmFax</th><th>FirmEmail</th>'
                       + '<th>FirmWebSite</th><th>FirmABANumber</th><th>DTCAgent</th><th>FirmNotes</th>'
                       + '<th>GoodFaith</th><th>ParentFirmID</th><th>ModifiedDate</th><th>ModifiedUser</th></tr>'
                       + CAST ( ( SELECT  td = FirmID         , ''
                                        , td = FirmName       , ''
                                        , td = ShortName      , ''
                                        , td = Active         , ''
                                        , td = FirmPhone      , ''
                                        , td = FirmTollFree   , ''
                                        , td = FirmFax        , ''
                                        , td = FirmEmail      , ''
                                        , td = FirmWebSite    , ''
                                        , td = FirmABANumber  , ''
                                        , td = DTCAgent       , ''
                                        , td = FirmNotes      , ''
                                        , td = GoodFaith      , ''
                                        , td = ParentFirmID   , ''
                                        , td = ModifiedDate   , ''
                                        , td = ModifiedUser   , ''
                                    FROM  deleted
                                     FOR  XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
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
