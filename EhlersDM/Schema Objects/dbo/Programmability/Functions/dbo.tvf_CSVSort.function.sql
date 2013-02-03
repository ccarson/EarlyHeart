CREATE FUNCTION dbo.tvf_CSVSort ( @pString    AS VARCHAR(8000)
                                , @pDelimiter AS CHAR(1)
                                , @pSortOrder AS CHAR(1) )
RETURNS TABLE 
WITH SCHEMABINDING AS
/*
************************************************************************************************************************************

   Function:    dbo.tvf_CSVSort
     Author:    Chris Carson
    Purpose:    sorts a CSV delimited string


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Function Arguments:
    @pString        VARCHAR(8000)   CSV list to be ordered
    @pDelimiter     CHAR(1)         The delimiter ( usually a comma )
    @pSortOrder     CHAR(1)         The order for the sort

************************************************************************************************************************************
*/
RETURN
  WITH  parsedInput AS ( SELECT Item FROM dbo.tvf_CSVSplit( @pString, @pDelimiter ) )

SELECT  sortedString =
        STUFF( ( SELECT ',' + Item
                   FROM parsedInput
                  ORDER BY ',' + Item
                    FOR XML PATH ('') ), 1, 1, '' )
 WHERE  @pSortOrder = 'A'
     UNION ALL
SELECT  STUFF( ( SELECT ',' + Item
                   FROM parsedInput
                  ORDER BY ',' + Item DESC
                    FOR XML PATH ('') ), 1, 1, '' )
 WHERE  @pSortOrder = 'D' ;
