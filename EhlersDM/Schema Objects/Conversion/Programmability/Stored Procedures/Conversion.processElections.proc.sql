CREATE PROCEDURE Conversion.processElections
AS
/*
************************************************************************************************************************************

  Procedure:  Conversion.processElections
     Author:  Chris Carson
    Purpose:  converts legacy Firms data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2012-11-30          created

    Logic Summary:


    Notes:

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;


    DECLARE @rc                      AS int = 0
          , @processName             AS varchar   (100) = 'processElections'
          , @processDate             AS datetime        = GETDATE() 
          , @errorMessage            AS varchar   (MAX) = NULL
          , @errorQuery              AS varchar   (MAX) = NULL
          , @processElections        AS varbinary (128) = CAST( 'processElections' AS varbinary (128) ) ;


    DECLARE @actualConvertedElections AS INT = 0 
          , @convertedElections       AS INT = 0 
          , @electionChanges          AS INT = 0 
          , @electionINSERTs          AS INT = 0 
          , @electionMERGEs           AS INT = 0 
          , @ElectionUPDATEs          AS INT = 0 
          , @legacyElections          AS INT = 0 
          , @newElections             AS INT = 0 
          , @updatedElections         AS INT = 0 ;


    DECLARE @changedElections       AS TABLE ( ElectionID          int
                                             , legacyChecksum      varbinary (128)
                                             , convertedChecksum   varbinary (128) ) ;


    DECLARE @electionMergeResults   AS TABLE ( Action      nvarchar (10)
                                             , ElectionID  int ) ;


BEGIN TRY

--  1)  Set CONTEXT_INFO to prevent converted tables from triggering changes
    SET CONTEXT_INFO @processElections ;


--  2)  Take initial counts of legacy and converted data ( for control totals )
    SELECT  @legacyElections    = COUNT(*) FROM Conversion.vw_LegacyElections ;
    SELECT  @convertedElections = COUNT(*) FROM Conversion.vw_ConvertedElections ;


--  3)  Create temp storage for changed data
    CREATE TABLE    #processElectionsData (
        ElectionID      int     NOT NULL PRIMARY KEY CLUSTERED
      , ClientID        int
      , ElectionDate    date
      , Amount          decimal (15,2)
      , Purpose         int
      , Description     varchar(100)
      , VotesYes        int
      , VotesNo         int ) ;



--  4)  Check for changes on edata.Firms, bypass if no changes
    INSERT  @changedElections
    SELECT  ElectionID        = l.ElectionID
          , legacyChecksum    = l.ElectionChecksum
          , convertedChecksum = c.ElectionChecksum
      FROM  Conversion.tvf_ElectionChecksum( 'Legacy' )    AS l
 LEFT JOIN  Conversion.tvf_ElectionChecksum( 'Converted' ) AS c
        ON  l.ElectionID = c.ElectionID
     WHERE  c.ElectionChecksum IS NULL OR l.ElectionChecksum <> c.ElectionChecksum ;
    SELECT  @ElectionChanges = @@ROWCOUNT ;


    IF  ( @ElectionChanges = 0 )
        BEGIN
            SELECT @actualConvertedElections = @convertedElections ;
            PRINT 'no changes on edata.Elections, exiting' ;
            GOTO  endOfProc ;
        END
    ELSE
        PRINT 'Migrating edata.Elections changes' ;


--  5)  Load data from vw_LegacyFirms that needs to be INSERTed
    INSERT  #processElectionsData
    SELECT  ElectionID, ClientID, ElectionDate
                , Amount, Purpose, Description
                , VotesYes, VotesNo
      FROM  Conversion.vw_LegacyElections            AS a
     WHERE  EXISTS ( SELECT 1 FROM @changedElections AS b
                      WHERE a.ElectionID = b.ElectionID
                            AND b.convertedChecksum IS NULL ) ;
    SELECT  @newElections = @@ROWCOUNT ;


--  6)  Load data from vw_LegacyFirms that needs to be UPDATEd
    INSERT  #processElectionsData
    SELECT  ElectionID, ClientID, ElectionDate
                , Amount, Purpose, Description
                , VotesYes, VotesNo
      FROM  Conversion.vw_LegacyElections            AS a
     WHERE  EXISTS ( SELECT 1 FROM @changedElections AS b
                      WHERE a.ElectionID = b.ElectionID
                            AND b.legacyChecksum <> b.convertedChecksum ) ;
    SELECT  @updatedElections = @@ROWCOUNT ;


--  7)  Throw error if no records are loaded
    IF  ( @ElectionChanges <> @newElections + @updatedElections )
    BEGIN
        SELECT  @errorMessage = 'Error:  changes on edata.Elections detected but not captured'
              , @errorQuery   = NULL
              , @rc = 16 ;
        GOTO    processingError ;
    END


--  8)  MERGE #processElectionsData with dbo.Elections
    SET IDENTITY_INSERT dbo.Election ON ;

     MERGE  dbo.Election           AS tgt
     USING  #processElectionsData  AS src
        ON  tgt.ElectionID = src.ElectionID
      WHEN  MATCHED THEN
            UPDATE  SET   ClientID        = src.ClientID
                        , ElectionTypeID  = src.Purpose
                        , ElectionDate    = src.ElectionDate
                        , ElectionAmount  = src.Amount
                        , YesVotes        = src.VotesYes
                        , NoVotes         = src.VotesNo
                        , Description     = src.Description
                        , ModifiedDate    = @processDate
                        , ModifiedUser    = @processName
      WHEN  NOT MATCHED BY TARGET THEN
            INSERT ( ElectionID, ClientID, ElectionTypeID
                        , ElectionDate, ElectionAmount
                        , YesVotes, NoVotes, Description
                        , ModifiedDate, ModifiedUser )
            VALUES ( src.ElectionID, src.ClientID, src.Purpose
                        , src.ElectionDate, src.Amount
                        , src.VotesYes, src.VotesNo, src.Description
                        , @processDate, @processName )
    OUTPUT  $action, inserted.ElectionID INTO @electionMergeResults ;
    SELECT  @electionMERGEs = @@ROWCOUNT ;

    SET IDENTITY_INSERT dbo.Election OFF ;

    IF  @electionMERGEs <> @electionChanges
    BEGIN
        SELECT  @errorMessage = 'Processing Error: Election changes expected = ' + CAST( @electionChanges  AS VARCHAR(20) )
                              + '                  Election changes actual   = ' + CAST( @electionMERGEs   AS VARCHAR(20) ) + ' .'
              , @errorQuery   = NULL
              , @rc = 16 ;

        GOTO    processingError ;
    END

    SELECT  @electionINSERTs = ( SELECT COUNT(*) FROM @electionMergeResults WHERE action = 'INSERT' )
          , @electionUPDATEs = ( SELECT COUNT(*) FROM @electionMergeResults WHERE action = 'UPDATE' ) ;

    SELECT  @actualConvertedElections = @convertedElections + @electionINSERTs ;

END TRY
BEGIN CATCH
    EXECUTE dbo.processEhlersError ;
END CATCH

    GOTO    endOfProc ;

processingError:
--  9)  Invoke error handling on any business logic or audit count errors
    EXECUTE dbo.processEhlersError    @processName
                                    , @errorMessage
                                    , @errorQuery ;

endOfProc:
-- 10)  Reset CONTEXT_INFO to re-enable converted table triggers
    SET CONTEXT_INFO 0x0 ;


-- 11)  Print control totals
    PRINT 'Conversion.processElections ' ;
    PRINT 'CONTROL TOTALS ' ;
    PRINT '    Converted Election records   = ' + CAST( @convertedElections       AS VARCHAR(20) ) ;
    PRINT '         new Elections           = ' + CAST( @newElections             AS VARCHAR(20) ) ;
    PRINT '         changed Elections       = ' + CAST( @updatedElections         AS VARCHAR(20) ) ;
    PRINT '' ;
    PRINT '    EXPECTED CONVERTED FIRMS     = ' + CAST( @legacyElections          AS VARCHAR(20) ) ;
    PRINT '' ;
    PRINT '    dbo.Election records         = ' + CAST( @convertedElections       AS VARCHAR(20) ) ;
    PRINT '         INSERTs                 = ' + CAST( @ElectionINSERTs          AS VARCHAR(20) ) ;
    PRINT '         UPDATEs                 = ' + CAST( @ElectionUPDATEs          AS VARCHAR(20) ) ;
    PRINT '' ;
    PRINT '    ACTUAL COUNT                 = ' + CAST( @actualConvertedElections AS VARCHAR(20) ) ;
    PRINT '' ;

    RETURN  @rc ;

END