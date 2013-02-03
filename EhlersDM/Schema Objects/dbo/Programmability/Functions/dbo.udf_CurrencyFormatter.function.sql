/*
-- =============================================
-- Author:		Brian Larson
-- Create date: 5/21/2010
-- Description:	Formats a currency value.
-- =============================================
CREATE FUNCTION [dbo].[udf_CurrencyFormatter]
(
	@Currency		numeric(30,2), 
	@TrailingZeros	bit	= 0,
	@DollarSign		bit = 1,
	@Comma			bit = 0
)
RETURNS varchar(20)
WITH SCHEMABINDING AS
BEGIN
	DECLARE @CurrencyStr	varchar(20)
	DECLARE @Formatted		varchar(20)
	DECLARE @LeftOfDec		int

	SET @CurrencyStr = CONVERT(numeric(20,2), @Currency)
		
	IF @DollarSign = 1
	BEGIN
		SET @Formatted = '$'
	END
	ELSE
	BEGIN
		SET @Formatted = ''
	END
	
	SET @LeftOfDec = CHARINDEX('.', @CurrencyStr)
	
	SELECT @Formatted = @Formatted +
						CASE @LeftOfDec 
							WHEN 13 THEN LEFT(@CurrencyStr, 3) + ',' + SUBSTRING(@CurrencyStr, 4,3) + ',' + SUBSTRING(@CurrencyStr, 7,3) + ',' + RIGHT(@CurrencyStr, 6)
							WHEN 12 THEN LEFT(@CurrencyStr, 2) + ',' + SUBSTRING(@CurrencyStr, 3,3) + ',' + SUBSTRING(@CurrencyStr, 6,3) + ',' + RIGHT(@CurrencyStr, 6)
							WHEN 11 THEN LEFT(@CurrencyStr, 1) + ',' + SUBSTRING(@CurrencyStr, 2,3) + ',' + SUBSTRING(@CurrencyStr, 5,3) + ',' + RIGHT(@CurrencyStr, 6)
							WHEN 10 THEN LEFT(@CurrencyStr, 3) + ',' + SUBSTRING(@CurrencyStr, 4,3) + ',' + RIGHT(@CurrencyStr, 6)
							WHEN 9 THEN LEFT(@CurrencyStr, 2) + ',' + SUBSTRING(@CurrencyStr, 3,3) + ',' + RIGHT(@CurrencyStr, 6)
							WHEN 8 THEN LEFT(@CurrencyStr, 1) + ',' + SUBSTRING(@CurrencyStr, 2,3) + ',' + RIGHT(@CurrencyStr, 6)
							WHEN 7 THEN LEFT(@CurrencyStr, 3) + ',' + RIGHT(@CurrencyStr, 6)
							WHEN 6 THEN LEFT(@CurrencyStr, 2) + ',' + RIGHT(@CurrencyStr, 6)
							WHEN 5 THEN LEFT(@CurrencyStr, 1) + ',' + RIGHT(@CurrencyStr, 6)
							ELSE @CurrencyStr
						END
						
	
	IF @TrailingZeros = 0
	BEGIN
		SET @Formatted = LEFT(@Formatted, LEN(@Formatted)-3)
	END
	
	IF @Comma = 0
	BEGIN
	  SET @Formatted = @CurrencyStr
	END  
	
	RETURN @Formatted
	--RETURN CONVERT(varchar(20), @LeftOfDec)
END

--123123123123.00
*/
