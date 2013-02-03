/*
CREATE PROCEDURE [dbo].[stp_Document_MaturityDocPurposes]
	@IssueID	int
AS 

SELECT si.SubIssueName, sip.PurposeName, dbo.udf_CurrencyFormatter(sip.PurposeAmount, 0, 1) AS PurposeAmount, CONVERT(varchar(10), SubIssuePurposeID) AS SubIssuePurposeID
FROM Issues i
JOIN SubIssues si ON i.IssueID = si.IssueID
JOIN SubIssuePurpose sip ON si.SubIssueID = sip.SubIssueID
WHERE i.IssueID = @IssueID
*/
