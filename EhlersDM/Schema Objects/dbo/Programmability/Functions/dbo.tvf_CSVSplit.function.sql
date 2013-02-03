CREATE FUNCTION dbo.tvf_CSVSplit ( @pString        AS VARCHAR(8000)
                                 , @pDelimiter     AS CHAR(1) )
RETURNS TABLE 
WITH SCHEMABINDING AS
/*
************************************************************************************************************************************

   Function:    dbo.tvf_CSVSplit
     Author:    Chris Carson ( not the creator, see NOTES )
    Purpose:    splits a delimited string, wickedly fast


    revisor     date            description
    --------    -----------     ----------------------------
    ccarson     2011-08-13      originally implemented
    ccarson     2012-10-19      Implemented at Ehlers


    Processing Summary:
    1)  Create tally table with 10K rows
    2)  Find starting position for each element in the input string.  Starting position == position of delimiter + 1
    3)  Determine length of each element in the input string.  Length is distance between current delimiter and next delimiter
    4)  Use SUBSTRING with calculated starting positions and lengths to split out string

    Function Arguments:
    @pString        VARCHAR(8000)       Input string to be parsed
    @pDelimiter     CHAR(1)             Delimiter

    Notes:
    Upper Limit for this function is 8000 characters.  Switching input to VARCHAR(MAX) degrades performance significantly
    Function does not trim for spaces before and after elements.  Refer to test data at end of function

    References: http://www.sqlservercentral.com/articles/Tally+Table/72993/
                http://www.sqlservercentral.com/articles/T-SQL/74118/
                    ( fun ways to count quickly )

************************************************************************************************************************************
*/
RETURN
  WITH  E1  AS (
        SELECT  N = 1
        UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
        UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
        UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 ) ,

        E2  AS ( SELECT N = 1 FROM E1 AS a, E1 AS b ) ,
        E4  AS ( SELECT N = 1 FROM E2 AS a, E2 AS b ) ,

        tally AS (
        SELECT  TOP ( ISNULL( DATALENGTH( @pString ),0 ) )
                delimiterPosition = ROW_NUMBER() OVER (ORDER BY (SELECT NULL) )
          FROM  E4 ) ,

        start AS (
        SELECT  startingPosition = 1
            UNION ALL
        SELECT  delimiterPosition + 1
          FROM  tally
         WHERE  SUBSTRING( @pString, delimiterPosition, 1 ) = @pDelimiter ) ,

        length AS (
        SELECT  startingPosition = startingPosition
              , stringLength     = ISNULL( NULLIF( CHARINDEX( @pDelimiter, @pString, startingPosition ), 0 ) - startingPosition, 8000 )
          FROM  start )

SELECT  ItemNumber = ROW_NUMBER() OVER(ORDER BY startingPosition)
      , Item       = SUBSTRING( @pString, startingPosition, stringLength )
  FROM  length ;
