CREATE FUNCTION Conversion.tvf_transformPercentage( @pctValue AS VARCHAR(100) )
RETURNS TABLE 
WITH SCHEMABINDING AS
/*
************************************************************************************************************************************

   Function:    Conversion.tvf_transformPercentage
     Author:    Chris Carson
    Purpose:    converts legacy percentage values from strings to decimal


    revisor         date                description
    ---------       -----------         ----------------------------
    ccarson         2013-01-24          created

    Notes:
    ISNUMERIC function returns true for percentages, false for 'n/b' or NULL

************************************************************************************************************************************
*/
RETURN
SELECT  pctValue = CASE ISNUMERIC( LEFT( @pctValue, 1 ) )
                        WHEN 0 THEN CAST( 0 AS DECIMAL(12,8) )
                        ELSE CAST ( ISNULL( NULLIF( LEFT( @pctValue, LEN( @pctValue ) - 1 ), '' ), 0 ) AS DECIMAL(12,8) )
                   END ;