CREATE TRIGGER  tr_Election
            ON  dbo.Election
AFTER INSERT, UPDATE, DELETE
AS
/*
************************************************************************************************************************************

    Trigger:    tr_Election
     Author:    Chris Carson
    Purpose:    writes Election data back to legacy dbo.Elections

    revisor         date                description
    ---------       ----------          ----------------------------
    ccarson         2013-01-24          created
    ccarson         ###DATE###          revised error reporting

    Logic Summary:
    1)  Stop processing when trigger is fired from Conversion
    2)  Load ElectionIDs into temp storage
    3)  MERGE converted election data onto edata.Elections

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
          , @codeBlockDesc02    AS SYSNAME  = 'Load ElectionIDs into temp storage'
          , @codeBlockDesc03    AS SYSNAME  = 'MERGE converted election data onto edata.Elections' ;

    DECLARE @fromConversion AS VARBINARY (128) = CAST( 'fromConversion' AS VARBINARY (128) ) ;

    DECLARE @changedElections   AS TABLE ( ElectionID INT ) ;



/**/SELECT  @codeBlockNum = 01, @codeBlockDesc = @codeBlockDesc01 ; --  Stop processing when trigger is fired from Conversion
    IF  CONTEXT_INFO() = @fromConversion
        RETURN ;



/**/SELECT  @codeBlockNum = 02, @codeBlockDesc = @codeBlockDesc02 ; --  Load ElectionIDs into temp storage
    INSERT  @changedElections
    SELECT  ElectionID FROM inserted
        UNION
    SELECT  ElectionID FROM deleted ;

/**/SELECT  @codeBlockNum = 03, @codeBlockDesc = @codeBlockDesc03 ; --  MERGE converted election data onto edata.Elections
    SET IDENTITY_INSERT [$(edata)].dbo.Elections ON ;

      WITH  legacyElections AS (
            SELECT * FROM edata.Elections AS e
             WHERE ElectionId IN ( SELECT ElectionID FROM @changedElections ) ) ,

            changedElections AS (
            SELECT  ElectionID
                  , ClientID
                  , ElectionDate
                  , Amount
                  , Purpose
                  , Description
                  , Passed
                  , VotesYes
                  , VotesNo
              FROM  Conversion.vw_ConvertedElections AS e
             WHERE  ElectionID IN ( SELECT ElectionID FROM @changedElections ) )

     MERGE  legacyElections  AS tgt
     USING  changedElections AS src ON tgt.ElectionId = src.ElectionID
      WHEN  MATCHED THEN
            UPDATE SET ClientId     = src.ClientID
                     , ElectionDate = src.ElectionDate
                     , Amount       = src.Amount
                     , Purpose      = src.Purpose
                     , Description  = src.Description
                     , Passed       = src.Passed
                     , VotesYes     = src.VotesYes
                     , VotesNo      = src.VotesNo
      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( ElectionId, ClientId, ElectionDate, Amount
                        , Purpose, Description, Passed, VotesYes, VotesNo )
            VALUES ( src.ElectionID, src.ClientID, src.ElectionDate, src.Amount
                        , src.Purpose, src.Description, src.Passed, src.VotesYes, src.VotesNo )

      WHEN  NOT MATCHED BY SOURCE THEN
            DELETE ;

    SET IDENTITY_INSERT [$(edata)].dbo.Elections OFF ;

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


    IF  EXISTS ( SELECT 1 FROM inserted )
        SELECT  @errorData = ISNULL( @errorData, '' )
              + '<b>contents of inserted trigger table</b></br></br>'
              + '<table border="1">'
              + '<tr><th>ElectionID</th><th>ClientID</th><th>ElectionTypeID</th><th>ElectionDate</th>'
              + '<th>ElectionAmount</th><th>YesVotes</th><th>NoVotes</th><th>Description</th>'
              + '<th>ModifiedDate</th><th>ModifiedUser</th></tr>'
              + CAST ( ( SELECT  td = ElectionID, ''
                              ,  td = ClientID, ''
                              ,  td = ElectionTypeID, ''
                              ,  td = ElectionDate, ''
                              ,  td = ElectionAmount, ''
                              ,  td = YesVotes, ''
                              ,  td = NoVotes, ''
                              ,  td = Description, ''
                              ,  td = ModifiedDate, ''
                              ,  td = ModifiedUser, ''
                           FROM  inserted
                            FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
              + '</table></br></br>' ;

    IF  EXISTS ( SELECT 1 FROM deleted )
        SELECT  @errorData = ISNULL( @errorData, '' )
              + '<b>contents of deleted trigger table</b></br></br>'
              + '<table border="1">'
              + '<tr><th>ElectionID</th><th>ClientID</th><th>ElectionTypeID</th><th>ElectionDate</th>'
              + '<th>ElectionAmount</th><th>YesVotes</th><th>NoVotes</th><th>Description</th>'
              + '<th>ModifiedDate</th><th>ModifiedUser</th></tr>'
              + CAST ( ( SELECT  td = ElectionID, ''
                              ,  td = ClientID, ''
                              ,  td = ElectionTypeID, ''
                              ,  td = ElectionDate, ''
                              ,  td = ElectionAmount, ''
                              ,  td = YesVotes, ''
                              ,  td = NoVotes, ''
                              ,  td = Description, ''
                              ,  td = ModifiedDate, ''
                              ,  td = ModifiedUser, ''
                           FROM  deleted
                            FOR XML PATH('tr'), ELEMENTS XSINIL, TYPE ) AS VARCHAR(MAX) )
              + N'</table></br></br>'


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
