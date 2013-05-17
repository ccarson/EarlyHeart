CREATE PROCEDURE Conversion.processClientsRating ( @Agency AS VARCHAR (20) ) 
AS
/*
************************************************************************************************************************************

  Procedure:  Conversion.processClientsRating
     Author:  Chris Carson
    Purpose:  loads legacy ClientsRating into new Ehlers database


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

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
          
BEGIN TRY

--  1)  Create temporary storage for data from edata.ClientsRating
    IF  OBJECT_ID('tempdb..#legacyData') IS NOT NULL DROP TABLE #legacyData ;

    CREATE  TABLE #legacyData ( 
            ClientID        INT
          , RatingTypeID    INT
          , RatedDate       DATE
          , RatingID        INT  ) ;


--  2)  Load temp storage with extracted data by ratings agency, eliminating duplicates
      WITH  ratings AS (
            SELECT  RatingID    =  RatingID
                  , Rating      =  Value
              FROM  dbo.Rating AS r
             WHERE  r.RatingAgency = @Agency AND IssueUseOnly = 0 ) 
                              
    INSERT  #legacyData
    SELECT  DISTINCT 
            ClientID        = i.ClientID      
          , RatingTypeID    = rt.RatingTypeID
          , RatedDate       = ISNULL( i.SaleDate, i.DatedDate )
          , RatingID        = r.RatingID
      FROM  edata.Issues        AS i  
INNER JOIN  dbo.SecurityType    AS st ON st.LegacyValue = i.SecurityType
INNER JOIN  dbo.RatingType      AS rt ON rt.Value = st.Value
INNER JOIN  ratings             AS r 
        ON  ( r.Rating = i.RatingMoody AND @Agency = 'Moody' )         OR
            ( r.Rating = i.RatingSP    AND @Agency = 'StandardPoor' )  OR
            ( r.Rating = i.RatingFitch AND @Agency = 'Fitch' )   
     WHERE  EXISTS ( SELECT 1 FROM dbo.Client AS c WHERE c.ClientID = i.ClientID ) ;
    

--  3)  Sort and enumerate temp storage by RatedDate for each client and rating type
      WITH  inputData AS (
            SELECT  ClientID
                  , RatingTypeID
                  , RatingID
                  , RatedDate
                  , N = ROW_NUMBER() OVER ( PARTITION BY ClientID, RatingTypeID ORDER BY RatedDate )
              FROM  #legacyData ) ,

--  4)  recursive CTE determines whether each new rating for a client represents an upgrade or downgrade from previous rating
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

--  5)  load computed results into dbo.ClientRating
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
--  6)  Invoke error handling on any business logic or audit count errors
    EXECUTE dbo.processEhlersError    @processName
                                    , @errorMessage
                                    , @errorQuery ;

endOfProc:

--  7)  Print control totals
    PRINT 'Conversion.processClientsRating for ' + UPPER( @Agency ) ;
    PRINT 'CONTROL TOTALS ' ;
    PRINT '    Converted  records    = ' + CAST( @clientRatingsCount AS VARCHAR(20) ) ;
    PRINT '' ;

    RETURN @rc ;
END
