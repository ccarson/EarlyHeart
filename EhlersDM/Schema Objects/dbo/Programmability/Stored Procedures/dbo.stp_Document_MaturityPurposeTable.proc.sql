/*
CREATE PROCEDURE [dbo].[stp_Document_MaturityPurposeTable]
	@SubIssuePurposeID	int
AS 

SELECT 
	CONVERT(char(4), LevyYear) AS LevyYear,
	CONVERT(char(4), CollectYear) AS CollectYear,
	dbo.udf_DateFormatter(PaymentDate, 'Short') AS PaymentDate,
	dbo.udf_CurrencyFormatter(Principal, 0, 1) AS Principal,
	CONVERT(varchar(10), CONVERT(numeric(5,2), Rate * 100)) + '%' AS Rate,
	dbo.udf_CurrencyFormatter(Interest, 0, 1) AS Interest,
	dbo.udf_CurrencyFormatter([NetP&I], 0, 1) AS [NetP&I],
	dbo.udf_CurrencyFormatter([P&I+5.00%], 0, 1) AS [P&I+5.00%]
FROM dbo.udf_MaturityTable(@SubIssuePurposeID)
*/
