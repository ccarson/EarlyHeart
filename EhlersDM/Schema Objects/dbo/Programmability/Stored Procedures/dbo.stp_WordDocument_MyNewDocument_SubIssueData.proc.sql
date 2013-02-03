/*
-- =============================================
-- Author:		Brian Larson
-- Create date: 9/17/2010
-- Description:	Extracts the data for
--				My New Document SubIssues.
-- =============================================
CREATE PROCEDURE [dbo].[stp_WordDocument_MyNewDocument_SubIssueData] 
	@IssueID		int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Get the required data for this report and store it in
	-- the #Data temporary table.
	SELECT 
		si.SubIssueName,
		dbo.udf_CurrencyFormatter(si.SubIssueAmount,1,1) AS SubIssueAmount,
		si.StatutoryAuthority AS SubIssueStatutoryAuthority
	FROM 
		SubIssues AS si 
	WHERE
		si.IssueID = @IssueID
		
END
*/
