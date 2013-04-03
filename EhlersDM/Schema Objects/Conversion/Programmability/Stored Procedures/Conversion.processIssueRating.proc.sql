CREATE PROCEDURE Conversion.processIssueRating ( @Agency AS VARCHAR (20) )
AS
/*
************************************************************************************************************************************

  Procedure:  Conversion.processIssueRating
     Author:  Chris Carson
    Purpose:  loads dbo.IssueRating from legacy ClientsRating data


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         ###DATE###          created ( Issues Conversion )

    Logic Summary:

    1)  Create temporary storage for data from edata.ClientsRating
    2)  Load temp storage with extracted data by ratings agency, eliminating duplicates
    3)  Sort and enumerate temp storage by RatedDate for each client and rating type
    4)  recursive CTE determines whether each new rating for a client represents an upgrade or downgrade from previous rating
    5)  load computed results into dbo.ClientRating
    6)  Invoke error handling on any business logic or audit count errors
    7)  Print control totals


    Notes:
    This proc uses a recursive CTE to compare records.
    It assigns a value to new records based on comparing current value to value of previous record
    Reference for recursive CTEs : http://msdn.microsoft.com/en-us/library/ms186243(v=sql.105).aspx

************************************************************************************************************************************
*/
BEGIN
BEGIN TRY

    SET NOCOUNT ON ;

    DECLARE @rc                         AS INT = 0
          , @errorMessage               AS VARCHAR(MAX) = NULL
          , @errorQuery                 AS VARCHAR(MAX) = NULL
          , @processName                AS VARCHAR(100) = 'processClientsRating' ;

    DECLARE @ConversionUser             AS VARCHAR(20)  = 'EhlersConversion'
          , @ConversionDate             AS DATETIME     = GETDATE()
          , @ClientRatingsCount         AS INT          = 0
          , @ratingsMoodyCount          AS INT          = 0
          , @ratingsSPCount             AS INT          = 0
          , @ratingsFitchCount          AS INT          = 0 ;



/**/SELECT  @codeBlockNum  = 2
/**/      , @codeBlockDesc = @codeBlockDesc02 ; -- INSERT dbo.IssueRating table with legacy records

    INSERT  dbo.IssueRating ( IssueID, RatingTypeID, IsNotRated, IsNotRatedCreditEnhanced )
    SELECT  iss.IssueID
          , rtt.RatingTypeID
          , 1
          , 1
      FROM  Conversion.vw_LegacyIssues AS iss
INNER JOIN  dbo.SecurityType           AS sct ON sct.SecurityTypeID = iss.SecurityType
INNER JOIN  dbo.RatingType             AS rtt ON rtt.Value = stt.Value ;


/**/SELECT  @codeBlockNum  = 2
/**/      , @codeBlockDesc = @codeBlockDesc02 ; -- UPDATE dbo.IssueRating based on Moody's ratings

      WITH  moody AS ( 
            SELECT IssueID FROM edata.Issues 
             WHERE ISNULL ( RatingMoody, '' ) NOT IN ( '', 'NR' ) ) 

    UPDATE  dbo.IssueRating
       SET  IsMoodyRated    = 1
          , IsNotRated      = 0 
      FROM  dbo.IssueRating AS isr
INNER JOIN  moody           AS moo ON moo.IssueID = isr.IssueID ) ; 


/**/SELECT  @codeBlockNum  = 3
/**/      , @codeBlockDesc = @codeBlockDesc02 ; -- UPDATE dbo.IssueRating based on Moody's CE ratings

      WITH  moodyCE AS ( 
            SELECT IssueID FROM edata.Issues 
             WHERE ISNULL ( CERatingMoody, '' ) NOT IN ( '', 'NR' ) ) 

    UPDATE  dbo.IssueRating
       SET  IsMoodyRated             = 1
          , IsNotRated               = 0 
          , IsNotRatedCreditEnhanced = 0 
      FROM  dbo.IssueRating AS isr
INNER JOIN  moodyCE         AS moo ON moo.IssueID = isr.IssueID ) ; 


/**/SELECT  @codeBlockNum  = 4
/**/      , @codeBlockDesc = @codeBlockDesc04 ; -- UPDATE dbo.IssueRating based on Standard & Poor's ratings

      WITH  standardPoor AS ( 
            SELECT IssueID FROM edata.Issues 
             WHERE ISNULL ( RatingSP, '' ) NOT IN ( '', 'NR' ) ) 

    UPDATE  dbo.IssueRating
       SET  IsSPRated   = 1
          , IsNotRated  = 0 
      FROM  dbo.IssueRating AS isr
INNER JOIN  standardPoor    AS sap ON sap.IssueID = isr.IssueID ) ; 


/**/SELECT  @codeBlockNum  = 5
/**/      , @codeBlockDesc = @codeBlockDesc05 ; -- UPDATE dbo.IssueRating based on S&P CE ratings

      WITH  standardPoorCE AS ( 
            SELECT IssueID FROM edata.Issues 
             WHERE ISNULL ( CERatingSP, '' ) NOT IN ( '', 'NR' ) ) 

    UPDATE  dbo.IssueRating
       SET  IsSPRated                = 1
          , IsNotRated               = 0 
          , IsNotRatedCreditEnhanced = 0 
      FROM  dbo.IssueRating AS isr
INNER JOIN  standardPoorCE  AS sap ON moo.IssueID = isr.IssueID ) ; 





/**/SELECT  @codeBlockNum  = 3
/**/      , @codeBlockDesc = @codeBlockDesc03 ; -- Sort and enumerate temp storage by RatedDate for each client and rating type
      WITH  inputData AS (
            SELECT  ClientID
                  , RatingTypeID
                  , RatingID
                  , RatedDate
                  , N = ROW_NUMBER() OVER ( PARTITION BY ClientID, RatingTypeID ORDER BY RatedDate )
              FROM  #legacyData ) ,

/**/SELECT  @codeBlockNum  = 4
/**/      , @codeBlockDesc = @codeBlockDesc04 ; -- recursive CTE determines whether each new rating for a client represents an upgrade or downgrade from previous rating
            results AS (
            SELECT  ClientID
                  , RatingTypeID
                  , RatingID
                  , RatedDate
                  , N
                  , Description = CAST( 'Original' AS VARCHAR(30) )
              FROM  inputData WHERE N = 1
                UNION ALL
            SELECT  i.ClientID
                  , i.RatingTypeID
                  , i.RatingID
                  , i.RatedDate
                  , i.N
                  , Description = CAST( CASE
                                            WHEN i.RatingID < r.RatingID THEN 'Upgrade'
                                            WHEN i.RatingID > r.RatingID THEN 'Downgrade'
                                            ELSE 'No Change'
                                        END AS VARCHAR(30) )
              FROM  inputData AS i
        INNER JOIN  results   AS r
                ON  r.ClientID = i.ClientID AND r.RatingTypeID = i.RatingTypeID AND r.N + 1 = i.n )

/**/SELECT  @codeBlockNum  = 5
/**/      , @codeBlockDesc = @codeBlockDesc05 ; -- load computed results into dbo.ClientRating
    INSERT  dbo.ClientRating ( ClientID, RatingID, RatingTypeID, RatedDate, Event, ModifiedDate, ModifiedUser )
    SELECT  ClientID, RatingID, RatingTypeID, RatedDate, Description, @ConversionDate, @ConversionUser
      FROM  results
     WHERE  Description <> 'No Change' ;

    SELECT  @clientRatingsCount = @@ROWCOUNT ;

    GOTO    endOfProc ;

END TRY
BEGIN CATCH
    EXECUTE dbo.processEhlersError ;
END CATCH


processingError:
/**/SELECT  @codeBlockNum  = 6
/**/      , @codeBlockDesc = @codeBlockDesc06 ; -- Invoke error handling on any business logic or audit count errors
    EXECUTE dbo.processEhlersError    @processName
                                    , @errorMessage
                                    , @errorQuery ;

endOfProc:

/**/SELECT  @codeBlockNum  = 7
/**/      , @codeBlockDesc = @codeBlockDesc07 ; -- Print control totals
    PRINT 'Conversion.processClientsRating for ' + UPPER( @Agency ) ;
    PRINT 'CONTROL TOTALS ' ;
    PRINT '    Converted  records    = ' + CAST( @clientRatingsCount AS VARCHAR(20) ) ;
    PRINT '' ;

    RETURN @rc ;
END
