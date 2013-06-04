CREATE TRIGGER  tr_FirmCategories
            ON  dbo.FirmCategories
AFTER INSERT, UPDATE, DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    dbo.tr_FirmCategories
     Author:    Chris Carson
    Purpose:    writes FirmCategories changes back to legacy dbo.Firms


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created
    ccarson         ###DATE###          revised error reporting

    Logic Summary:

    1)  Stop processing when trigger is fired from Conversion
    2)  INSERT FirmID and Modified data into temp storage
    3)  UPDATE temp storage with legacy version of FirmCategory data
    4)  UPDATE edata.Firms.FirmCategory with new data

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
          , @codeBlockDesc02    AS SYSNAME  = 'MERGE updated trigger data into edata.Firms' ;

    DECLARE @fromConversion     AS VARBINARY (128)  = CAST( 'fromConversion' AS VARBINARY (128) ) ;



/**/SELECT  @codeBlockNum = 01, @codeBlockDesc = @codeBlockDesc01 ; -- Stop processing when trigger is fired from Conversion
    IF  CONTEXT_INFO() = @fromConversion
        RETURN ;



/**/SELECT  @codeBlockNum = 02, @codeBlockDesc = @codeBlockDesc02 ; -- MERGE updated trigger data into edata.Firms
      WITH  firmsData AS (
            SELECT  FirmID, ModifiedUser = MAX(ModifiedUser), ModifiedDate = MAX(ModifiedDate)
              FROM  inserted
             GROUP  BY FirmID
                UNION ALL
            SELECT  FirmID, MAX(ModifiedUser), MAX(ModifiedDate) FROM deleted
             WHERE  FirmID NOT IN ( SELECT FirmID FROM inserted )
             GROUP  BY FirmID ) ,

            updatedData AS (
            SELECT  TOP 100 PERCENT
                    FirmID       = f.FirmID
                  , FirmCategory = ISNULL( fc.FirmCategory, '' )
                  , ChangeCode   = 'cvFirmCat'
                  , ChangeBy     = f.ModifiedUser
                  , ChangeDate   = f.ModifiedDate
              FROM  firmsData AS f
         LEFT JOIN  Conversion.tvf_LegacyFirmCategories ( 'Converted' ) AS fc ON fc.FirmID = f.FirmID
             ORDER  BY f.FirmID )

     MERGE  edata.Firms AS tgt
     USING  updatedData AS src ON src.FirmID = tgt.FirmId
      WHEN  MATCHED THEN
            UPDATE SET  FirmCategory    = src.FirmCategory
                      , ChangeCode      = src.ChangeCode
                      , ChangeBy        = src.ChangeBy
                      , ChangeDate      = src.ChangeDate ;

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

      WITH  firmsData AS (
            SELECT  FirmID, ModifiedUser = MAX(ModifiedUser), ModifiedDate = MAX(ModifiedDate)
              FROM  inserted
             GROUP  BY FirmID
                UNION ALL
            SELECT  FirmID, MAX(ModifiedUser), MAX(ModifiedDate) FROM deleted
             WHERE  FirmID NOT IN ( SELECT FirmID FROM inserted )
             GROUP  BY FirmID ) ,

            updatedData AS (
            SELECT  TOP 100 PERCENT
                    FirmID       = f.FirmID
                  , FirmCategory = ISNULL( fc.FirmCategory, '' )
                  , ChangeCode   = 'cvFirmCat'
                  , ChangeBy     = f.ModifiedUser
                  , ChangeDate   = f.ModifiedDate
              FROM  firmsData AS f
         LEFT JOIN  Conversion.tvf_LegacyFirmCategories ( 'Converted' ) AS fc ON fc.FirmID = f.FirmID
             ORDER  BY f.FirmID )

    SELECT  @errorData = '<b>contents of temp storage</b></br></br>'
                       + '<table border="1">'
                       + '<tr><th>FirmID</th><th>FirmCategory data</th>'
                       + '<th>ModifiedDate</th><th>ModifiedUser</th></tr>'
                       + CAST ( ( SELECT  td = FirmID, ''
                                        , td = FirmCategory, ''
                                        , td = ChangeDate, ''
                                        , td = ChangeBy, ''
                                    FROM  updatedData
                                   ORDER  BY 1
                                     FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
                       + '</table>' ;

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
