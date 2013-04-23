CREATE FUNCTION Documents.tvf_RatingsApplications ( @IssueID AS int )
RETURNS TABLE
WITH SCHEMABINDING
AS
/*
************************************************************************************************************************************

   Function:    Documents.tvf_RatingsApplications
     Author:    Chris Carson
    Purpose:    Returns ratings agencies who are rating an issue in a columnar format

    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         ###DATE###          created -- Issues Conversion

    Function Arguments:
    @IssueID         int        IssueID for which function will extract data

    Notes:

************************************************************************************************************************************
*/
RETURN

      WITH  agencies AS (
            SELECT  [1] =   CASE IsMoodyRated   WHEN 1 THEN  CAST( 'Moody''s Investor Service' AS VARCHAR ( 100 ) ) ELSE NULL END 
                 ,  [2] =   CASE IsSPRated      WHEN 1 THEN  CAST( 'xxx s and p xxx'           AS VARCHAR ( 100 ) ) ELSE NULL END 
                 ,  [3] =   CASE IsFitchRated   WHEN 1 THEN  CAST( 'xxx fitch xxx'             AS VARCHAR ( 100 ) ) ELSE NULL END 
              FROM  dbo.IssueRating
             WHERE  IssueID = @IssueID ) ,

            ratings AS (
            SELECT RatingService, Ordinal
              FROM agencies AS a
           UNPIVOT ( RatingService FOR Ordinal IN ( [1], [2], [3] ) ) AS x )

    SELECT N = ROW_NUMBER() OVER ( ORDER BY Ordinal )
         , RatingService
      FROM ratings ;
