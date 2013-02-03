/*
CREATE PROCEDURE [dbo].[stp_Document_MaturityDoc]
	@IssueID	int
AS 

SELECT i.IssueName, dbo.udf_CurrencyFormatter(i.IssueAmount, 0, 1) AS IssueAmount
FROM Issues i
WHERE i.IssueID = @IssueID
*/
