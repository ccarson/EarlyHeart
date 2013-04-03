CREATE PROCEDURE Import.loadPurposesFromMunex  ( @IssueID          AS VARCHAR(30)
                                               , @PurposeIDs       AS VARCHAR(MAX)
                                               , @PurposeNames     AS VARCHAR(MAX) )
AS
/*
************************************************************************************************************************************

  Procedure:    Import.loadPurposesFromMunex
     Author:    Chris Carson
    Purpose:    updates Ehlers with purpose data from Munex Import


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Logic Summary:
    1)  INSERT input data into IssuePostBond ( CASTing relevant data as required )

************************************************************************************************************************************
*/
BEGIN

    SET NOCOUNT ON ; 

    DECLARE @codeBlockDesc01        AS VARCHAR (128)    = 'SELECT purposeIDs into temp storage'
          , @codeBlockDesc02        AS VARCHAR (128)    = 'SELECT purpose names into temp storage'
          , @codeBlockDesc03        AS VARCHAR (128)    = 'UPDATE temp storage '
          , @codeBlockDesc04        AS VARCHAR (128)    = 'Stop processing if there are no data changes'
          , @codeBlockDesc05        AS VARCHAR (128)    = 'INSERT new data into temp storage'
          , @codeBlockDesc06        AS VARCHAR (128)    = 'INSERT updated data into temp storage'
          , @codeBlockDesc07        AS VARCHAR (128)    = 'UPDATE changed data to remove invalid ObligorClientID'
          , @codeBlockDesc08        AS VARCHAR (128)    = 'MERGE temp storage into dbo.Issues'
          , @codeBlockDesc09        AS VARCHAR (128)    = 'SELECT final control counts'
          , @codeBlockDesc10        AS VARCHAR (128)    = 'Control Total Validation'
          , @codeBlockDesc11        AS VARCHAR (128)    = 'Reset CONTEXT_INFO to remove restrictions on triggers'
          , @codeBlockDesc12        AS VARCHAR (128)    = 'Print control totals' ;


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


    DECLARE @changesCount       AS INT = 0
          , @convertedActual    AS INT = 0
          , @convertedCount     AS INT = 0
          , @legacyCount        AS INT = 0
          , @newCount           AS INT = 0
          , @recordINSERTs      AS INT = 0
          , @recordMERGEs       AS INT = 0
          , @recordUPDATEs      AS INT = 0
          , @total              AS INT = 0
          
          , @updatedCount       AS INT = 0 ;




END