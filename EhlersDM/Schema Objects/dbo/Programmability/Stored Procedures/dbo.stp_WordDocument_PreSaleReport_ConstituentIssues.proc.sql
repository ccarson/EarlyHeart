/*
-- =============================================
-- Author:		Brian Larson
-- Create date: 5/19/2010
-- Description:	Extracts the data, including
--				document section text, for
--				the Pre-Sale Report document.
-- =============================================
CREATE PROCEDURE [dbo].[stp_WordDocument_PreSaleReport_ConstituentIssues] 
	@IssueID int,
	@IncludeKeyData	bit = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Get the required data for this report and store it in
	-- the #Data temporary table.
	SELECT 
		'Chapter ' + ci.StatutoryAuthority AS StatutoryAuthorityName,
		dbo.udf_FundingSourceList(ci.SubIssueID, 2, 1) AS NumberOfFundingSources,
		CONVERT(varchar(20), ci.SubIssueID) AS ConstituentIssueID,
		ci.SubIssueName AS ConstituentIssueLongName,
		ci.SubIssueShortName AS ConstituentIssueShortName,
		dbo.udf_CurrencyFormatter(ci.SubIssueAmount,1,1) AS ConstituentIssueAmount,
		ci.SubIssueName AS ConstituentIssueLongDescription,
		ci.SubIssueShortName AS ConstituentIssueShortDescription,
		dbo.udf_FundingSourceList(ci.SubIssueID, 'Y', 0) AS SecuredFundingSources,
		dbo.udf_FundingSourceList(ci.SubIssueID, 'Y', 1) AS SecuredFundingSourceCount,
		dbo.udf_FundingSourceList(ci.SubIssueID, 'N', 0) AS OtherFundingSources,
		dbo.udf_FundingSourceList(ci.SubIssueID, 'N', 1) AS OtherFundingSourceCount
	FROM 
		Issues AS i 
	LEFT OUTER JOIN 
		SubIssues ci ON i.IssueID = ci.IssueID
	WHERE
		i.IssueID = @IssueID
		
END
*/
