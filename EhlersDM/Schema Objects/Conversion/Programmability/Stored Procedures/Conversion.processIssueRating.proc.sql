CREATE PROCEDURE Conversion.processIssueRating
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

    DECLARE @processStartTime   AS VARCHAR (30)     = CONVERT( VARCHAR(30), GETDATE(), 121 )
          , @processEndTime     AS VARCHAR (30)     = NULL
          , @processElapsedTime AS INT              = 0 ;


    DECLARE @codeBlockDesc01    AS SYSNAME          = 'SELECT initial control counts'
          , @codeBlockDesc02    AS SYSNAME          = 'INSERT dbo.IssueRating table with legacy records'
          , @codeBlockDesc03    AS SYSNAME          = 'UPDATE dbo.IssueRating based on Moody''s ratings'
          , @codeBlockDesc04    AS SYSNAME          = 'UPDATE dbo.IssueRating based on Moody''s CE ratings'
          , @codeBlockDesc05    AS SYSNAME          = 'UPDATE dbo.IssueRating based on Standard & Poor''s ratings'
          , @codeBlockDesc06    AS SYSNAME          = 'UPDATE dbo.IssueRating based on S&P CE ratings'
          , @codeBlockDesc07    AS SYSNAME          = 'UPDATE dbo.IssueRating based on Fitch''s ratings'
          , @codeBlockDesc08    AS SYSNAME          = 'UPDATE dbo.IssueRating based on S&P CE ratings'
          , @codeBlockDesc09    AS SYSNAME          = 'UPDATE dbo.IssueRating with ModifiedDate and ModifiedUser'
          , @codeBlockDesc10    AS SYSNAME          = 'SELECT final control counts'
          , @codeBlockDesc11    AS SYSNAME          = 'Control Total Validation'
          , @codeBlockDesc12    AS SYSNAME          = 'Print control totals' ;


    DECLARE @codeBlockNum       AS INT
          , @codeBlockDesc      AS SYSNAME
          , @errorTypeID        AS INT
          , @errorSeverity      AS INT
          , @errorState         AS INT
          , @errorNumber        AS INT
          , @errorLine          AS INT
          , @errorProcedure     AS VARCHAR (128)
          , @errorMessage       AS VARCHAR (MAX)    = NULL
          , @errorData          AS VARCHAR (MAX)    = NULL ;

    DECLARE @controlTotalsError AS VARCHAR (200)    = N'Control Total Failure:  %s = %d, %s = %d' ;

    DECLARE @existingCount      AS INT = 0
          , @fitchCERatings     AS INT = 0
          , @fitchRatings       AS INT = 0
          , @moodyCERatings     AS INT = 0
          , @moodyRatings       AS INT = 0
          , @newCount           AS INT = 0
          , @newRatings         AS INT = 0
          , @ratedIssues        AS INT = 0
          , @recordINSERTs      AS INT = 0
          , @spCERatings        AS INT = 0
          , @spRatings          AS INT = 0
          , @total              AS INT = 0 ;

    DECLARE @ConversionUser     AS VARCHAR(20)      = 'EhlersConversion' ;

    DECLARE @updates            AS TABLE ( IssueID INT ) ;
    DECLARE @inserts            AS TABLE ( IssueID INT ) ;


/**/SELECT  @codeBlockNum   = 1
/**/      , @codeBlockDesc  = @codeBlockDesc01 ; -- SELECT initial control counts

    SELECT  @existingCount = COUNT(*) FROM dbo.IssueRating ;


/**/SELECT  @codeBlockNum   = 2
/**/      , @codeBlockDesc  = @codeBlockDesc02 ; -- INSERT dbo.IssueRating table with legacy records

    INSERT  dbo.IssueRating ( IssueID, RatingTypeID, IsNotRated, IsNotRatedCreditEnhanced )
    OUTPUT  inserted.IssueID INTO @inserts( IssueID )
    SELECT  iss.IssueID
          , rtt.RatingTypeID
          , 1
          , 1
      FROM  Conversion.vw_LegacyIssues AS iss
INNER JOIN  dbo.SecurityType           AS sct ON sct.SecurityTypeID = iss.SecurityType
INNER JOIN  dbo.RatingType             AS rtt ON rtt.Value = sct.Value
     WHERE  NOT EXISTS ( SELECT 1 FROM dbo.IssueRating AS isr WHERE isr.IssueID = iss.IssueID ) ;
    SELECT  @recordINSERTs = @@ROWCOUNT ;


/**/SELECT  @codeBlockNum   = 3
/**/      , @codeBlockDesc  = @codeBlockDesc03 ; -- UPDATE dbo.IssueRating based on Moody's ratings

      WITH  moody AS (
            SELECT IssueID FROM edata.Issues
             WHERE ISNULL ( RatingMoody, '' ) NOT IN ( '', 'NR' ) )

    UPDATE  dbo.IssueRating
       SET  IsMoodyRated    = 1
          , IsNotRated      = 0
    OUTPUT  inserted.IssueID INTO @updates( IssueID )
      FROM  dbo.IssueRating AS isr
INNER JOIN  moody           AS moo ON moo.IssueID = isr.IssueID
INNER JOIN  @inserts        AS ins ON ins.IssueID = isr.IssueID ;
    SELECT  @moodyRatings = @@ROWCOUNT ;

/**/SELECT  @codeBlockNum   = 4
/**/      , @codeBlockDesc  = @codeBlockDesc04 ; -- UPDATE dbo.IssueRating based on Moody's CE ratings

      WITH  moodyCE AS (
            SELECT IssueID FROM edata.Issues
             WHERE ISNULL ( CERatingMoody, '' ) NOT IN ( '', 'NR' ) )

    UPDATE  dbo.IssueRating
       SET  IsMoodyRated             = 1
          , IsNotRated               = 0
          , IsNotRatedCreditEnhanced = 0
    OUTPUT  inserted.IssueID INTO @updates( IssueID )
      FROM  dbo.IssueRating AS isr
INNER JOIN  moodyCE         AS moo ON moo.IssueID = isr.IssueID
INNER JOIN  @inserts        AS ins ON ins.IssueID = isr.IssueID ;
    SELECT  @moodyCERatings = @@ROWCOUNT ;

    
/**/SELECT  @codeBlockNum   = 5
/**/      , @codeBlockDesc  = @codeBlockDesc05 ; -- UPDATE dbo.IssueRating based on Standard & Poor's ratings

      WITH  standardPoor AS (
            SELECT IssueID FROM edata.Issues
             WHERE ISNULL ( RatingSP, '' ) NOT IN ( '', 'NR' ) )

    UPDATE  dbo.IssueRating
       SET  IsSPRated   = 1
          , IsNotRated  = 0
    OUTPUT  inserted.IssueID INTO @updates( IssueID )
      FROM  dbo.IssueRating AS isr
INNER JOIN  standardPoor    AS sap ON sap.IssueID = isr.IssueID
INNER JOIN  @inserts        AS ins ON ins.IssueID = isr.IssueID ;
    SELECT  @spRatings = @@ROWCOUNT ;


/**/SELECT  @codeBlockNum   = 6
/**/      , @codeBlockDesc  = @codeBlockDesc06 ; -- UPDATE dbo.IssueRating based on S&P CE ratings

      WITH  standardPoorCE AS (
            SELECT IssueID FROM edata.Issues
             WHERE ISNULL ( CERatingSP, '' ) NOT IN ( '', 'NR' ) )

    UPDATE  dbo.IssueRating
       SET  IsSPRated                = 1
          , IsNotRated               = 0
          , IsNotRatedCreditEnhanced = 0
    OUTPUT  inserted.IssueID INTO @updates( IssueID )
      FROM  dbo.IssueRating AS isr
INNER JOIN  standardPoorCE  AS sap ON sap.IssueID = isr.IssueID
INNER JOIN  @inserts        AS ins ON ins.IssueID = isr.IssueID ;
    SELECT  @spCERatings = @@ROWCOUNT ;


/**/SELECT  @codeBlockNum   = 7
/**/      , @codeBlockDesc  = @codeBlockDesc07 ; -- UPDATE dbo.IssueRating based on Fitch's ratings

      WITH  fitch AS (
            SELECT IssueID FROM edata.Issues
             WHERE ISNULL ( RatingFitch, '' ) NOT IN ( '', 'NR' ) )

    UPDATE  dbo.IssueRating
       SET  IsFitchRated    = 1
          , IsNotRated      = 0
    OUTPUT  inserted.IssueID INTO @updates( IssueID )
      FROM  dbo.IssueRating AS isr
INNER JOIN  fitch           AS fit ON fit.IssueID = isr.IssueID
INNER JOIN  @inserts        AS ins ON ins.IssueID = isr.IssueID ;
    SELECT  @fitchRatings = @@ROWCOUNT ;
    

/**/SELECT  @codeBlockNum   = 8
/**/      , @codeBlockDesc  = @codeBlockDesc08 ; -- UPDATE dbo.IssueRating based on S&P CE ratings

      WITH  fitchCE AS (
            SELECT IssueID FROM edata.Issues
             WHERE ISNULL ( CERatingFitch, '' ) NOT IN ( '', 'NR' ) )

    UPDATE  dbo.IssueRating
       SET  IsFitchRated                = 1
          , IsNotRated                  = 0
          , IsNotRatedCreditEnhanced    = 0
    OUTPUT  inserted.IssueID INTO @updates( IssueID )
      FROM  dbo.IssueRating AS isr
INNER JOIN  fitchCE         AS fit ON fit.IssueID = isr.IssueID
INNER JOIN  @inserts        AS ins ON ins.IssueID = isr.IssueID ;
    SELECT  @fitchCERatings = @@ROWCOUNT ;



/**/SELECT  @codeBlockNum   = 9
/**/      , @codeBlockDesc  = @codeBlockDesc09 ; -- UPDATE dbo.IssueRating with ModifiedDate and ModifiedUser

    UPDATE  dbo.IssueRating
       SET  ModifiedDate    = GETDATE()
          , ModifiedUser    = @ConversionUser
     WHERE  EXISTS ( SELECT 1 FROM @updates AS u
                      WHERE u.IssueID = dbo.IssueRating.IssueID ) ;
    SELECT  @newRatings = @@ROWCOUNT ;


/**/SELECT  @codeBlockNum   = 10
/**/      , @codeBlockDesc  = @codeBlockDesc10 ; -- SELECT final control counts

    SELECT  @ratedIssues     = COUNT( DISTINCT IssueID ) FROM @updates ;
    SELECT  @newCount        = COUNT(*) FROM dbo.IssueRating ;


/**/SELECT  @codeBlockNum   = 11
/**/      , @codeBlockDesc  = @codeBlockDesc11 ; -- Control Total Validation

    SELECT @total =  @existingCount + @recordINSERTs
    IF  ( @total <> ( @existingCount + @recordINSERTs ) )
        RAISERROR( @controlTotalsError, 16, 1, 'Final Count', @newCount, 'Starting Count + Inserts', @total ) ;

    IF  ( @newRatings <> @ratedIssues )
        RAISERROR( @controlTotalsError, 16, 1, 'New Ratings', @newRatings, 'Total Updated', @ratedIssues ) ;


/**/SELECT  @codeBlockNum   = 12
/**/      , @codeBlockDesc  = @codeBlockDesc12 ; -- Print control totals

    SELECT  @processEndTime     = CONVERT( VARCHAR(30), GETDATE(), 121 )
          , @processElapsedTime = DATEDIFF( ms, CAST( @processStartTime AS DATETIME ), CAST( @processEndTime AS DATETIME ) ) ;

    RAISERROR( 'Conversion.processIssueRatings CONTROL TOTALS ', 0, 0 ) ;
    RAISERROR( 'Existing Issue Ratings                  = % 8d', 0, 0, @existingCount ) ;
    RAISERROR( '     + new records                      = % 8d', 0, 0, @recordINSERTs ) ;
    RAISERROR( '                                           ======= ', 0, 0 ) ;
    RAISERROR( 'Total IssueRatings                      = % 8d', 0, 0, @newCount ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( 'Database Change Details', 0, 0 ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( '     Moody Ratings                      = % 8d', 0, 0, @moodyRatings ) ;
    RAISERROR( '     Moody CE Ratings                   = % 8d', 0, 0, @moodyCERatings ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( '     Standard & Poor Ratings            = % 8d', 0, 0, @spRatings ) ;
    RAISERROR( '     Standard & Poor CE Ratings         = % 8d', 0, 0, @spCERatings ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( '     Fitch Ratings                      = % 8d', 0, 0, @fitchRatings ) ;
    RAISERROR( '     Fitch CE Ratings                   = % 8d', 0, 0, @fitchCERatings ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( 'TOTAL new Issues rated                  = % 8d', 0, 0, @ratedIssues ) ;
    RAISERROR( '', 0, 0 ) ;
    RAISERROR( 'processIssueRatings START : %s', 0, 0, @processStartTime ) ;
    RAISERROR( 'processIssueRatings   END : %s', 0, 0, @processEndTime ) ;
    RAISERROR( '             Elapsed Time : %d ms', 0, 0, @processElapsedTime ) ;


END TRY

BEGIN CATCH
    EXECUTE dbo.processEhlersError ;
END CATCH

END
