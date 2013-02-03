/*
-- =============================================
-- Author:		Brian Larson
-- Create date: 9/17/2010
-- Description:	Extracts the data for
--				My New Document Purposes.
-- =============================================
CREATE PROCEDURE [dbo].[stp_WordDocument_MyNewDocument_PurposeData] 
	@IssueID		int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Get the required data for this report and store it in
	-- the #Data temporary table.
	SELECT 
		sp.PurposeName,
		dbo.udf_CurrencyFormatter(sp.PurposeAmount,1,1) AS PurposeAmount,
		si.StatutoryAuthority,
		ISNULL(CONVERT(char(4), YEAR(sp.ProjectCompletionDate)), 'Unkn') AS CompletionYear
	FROM 
		SubIssues AS si 
	INNER JOIN 
		SubIssuePurpose AS sp ON si.SubIssueID = sp.SubIssueID
	WHERE
		si.IssueID = @IssueID
		
END
*/
