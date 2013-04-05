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
    IF  @@ROWCOUNT = 0 RETURN ;

BEGIN TRY
    

    SET NOCOUNT ON ;

    DECLARE @processFirms           AS VARBINARY(128) = CAST( 'processFirms' AS VARBINARY(128) )
          , @legacyChecksum         AS INT = 0
          , @convertedChecksum      AS INT = 0 ;


    DECLARE @codeBlockDesc01        AS VARCHAR (128)    = 'Stop processing when trigger is invoked by Conversion.processFirms'
          , @codeBlockDesc02        AS VARCHAR (128)    = 'Stop processing unless Firm data has actually changed'
          , @codeBlockDesc03        AS VARCHAR (128)    = 'MERGE new Firm data onto edata.dbo.Firms' ;


    DECLARE @codeBlockNum           AS INT
          , @codeBlockDesc          AS VARCHAR (128)
          , @errorTypeID            AS INT
          , @errorSeverity          AS INT
          , @errorState             AS INT
          , @errorNumber            AS INT
          , @errorLine              AS INT
          , @errorProcedure         AS VARCHAR (128)
          , @errorMessage           AS VARCHAR (MAX) = NULL
          , @errorData              AS VARCHAR (MAX) = NULL ;



/**/SELECT  @codeBlockNum   = 1
/**/      , @codeBlockDesc  = @codeBlockDesc01 ;  --  Stop processing when trigger is invoked by Conversion.processFirms

    IF  CONTEXT_INFO() = @processFirms
        RETURN ;



/**/SELECT  @codeBlockNum   = 2
/**/      , @codeBlockDesc  = @codeBlockDesc02 ; --  Stop processing unless Firm data has actually changed

    SELECT  @legacyChecksum = CHECKSUM_AGG( CHECKSUM(*) )
      FROM  Conversion.tvf_FirmChecksum( 'Legacy' ) AS f
     WHERE  EXISTS ( SELECT 1 FROM inserted AS i WHERE i.FirmID = f.FirmID ) ;

    SELECT  @convertedChecksum = CHECKSUM_AGG( CHECKSUM(*) )
      FROM  Conversion.tvf_FirmChecksum( 'Converted' ) AS f
     WHERE  EXISTS ( SELECT 1 FROM inserted AS i WHERE i.FirmID = f.FirmID ) ;

    IF  ( @legacyChecksum = @convertedChecksum )
        RETURN ;



/**/SELECT  @codeBlockNum   = 3
/**/      , @codeBlockDesc  = @codeBlockDesc03 ;  --  MERGE new Firm data onto edata.dbo.Firms

      WITH  changedFirms AS (
            SELECT  *
              FROM  Conversion.vw_ConvertedFirms
             WHERE  FirmID IN ( SELECT FirmID FROM inserted ) )
     MERGE  edata.Firms     AS tgt
     USING  changedFirms    AS src ON tgt.FirmID = src.FirmID
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
                      , ChangeCode = 'cvFirmUPD'
                      , ChangeBy   = src.ChangeBy
      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( FirmID, Firm, FirmStatus, ShortName, Phone, Fax, TollFree
                        , WebSite, GoodFaith, Notes, ChangeDate, ChangeCode, ChangeBy )
            VALUES ( src.FirmID, src.Firm, src.FirmStatus, src.ShortName, src.Phone, src.Fax, src.TollFree
                        , src.WebSite, src.GoodFaith, src.Notes, src.ChangeDate, 'cvFirmINS', src.ChangeBy ) ;


END TRY
BEGIN CATCH
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
                                        , td = ISNULL( ParentFirmID , 0 ), ''
                                        , td = ModifiedDate   , ''
                                        , td = ModifiedUser   , ''
                                    FROM  inserted
                                     FOR XML PATH('tr'), TYPE ) AS VARCHAR(MAX) )
                       + N'</table>' ;

    ROLLBACK TRANSACTION ;

    SELECT  @errorTypeID    = 1
          , @errorSeverity  = ERROR_SEVERITY()
          , @errorState     = ERROR_STATE()
          , @errorNumber    = ERROR_NUMBER()
          , @errorLine      = ERROR_LINE()
          , @errorProcedure = ISNULL( ERROR_PROCEDURE(), '-' )

    IF  @errorMessage IS NULL
    BEGIN
        SELECT  @errorMessage = N'Error occurred in Code Block %d, %s ' + CHAR(13)
                              + N'Error %d, Level %d, State %d, Procedure %s, Line %d, Message: ' + ERROR_MESSAGE() ;

        RAISERROR( @errorMessage, @errorSeverity, 1
                 , @codeBlockNum
                 , @codeBlockDesc
                 , @errorNumber
                 , @errorSeverity
                 , @errorState
                 , @errorProcedure
                 , @errorLine ) ;

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

    END
        ELSE
    BEGIN
        SELECT  @errorSeverity  = ERROR_SEVERITY()
              , @errorState     = ERROR_STATE()

        RAISERROR( @errorMessage, @errorSeverity, @errorState ) ;
    END

END CATCH
END
