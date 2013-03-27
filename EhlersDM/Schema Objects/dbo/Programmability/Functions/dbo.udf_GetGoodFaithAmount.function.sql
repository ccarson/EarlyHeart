CREATE FUNCTION [dbo].[udf_GetGoodFaithAmount]( @input AS DECIMAL )
RETURNS DECIMAL
WITH SCHEMABINDING AS
-- =============================================
-- Author:      Mike Kiemen
-- Create date: 3/30/2012
-- Description: Returns current % of amount for a good faith value
-- =============================================
BEGIN
    DECLARE @ret    AS DECIMAL ;

    SELECT  @ret = @input * .02 ;

    RETURN  @ret ;
END


