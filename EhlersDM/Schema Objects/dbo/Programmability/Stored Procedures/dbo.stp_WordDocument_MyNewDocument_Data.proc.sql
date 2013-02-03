/*
-- =============================================
-- Author:		Brian Larson
-- Create date: 9/13/2010
-- Description:	Extracts the data for
--				My New Document.
-- =============================================
CREATE PROCEDURE [dbo].[stp_WordDocument_MyNewDocument_Data] 
	@IssueID		int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Get the required data for this report and store it in
	-- the #Data temporary table.
	SELECT 
		i.IssueName,
		dbo.udf_CurrencyFormatter(i.IssueAmount,1,1) AS IssueAmount,
		TypeJurisdiction AS TypeOfJurisdiction
	FROM 
		Issues AS i 
	INNER JOIN 
		Clients AS c ON i.ClientID = c.ClientID
	WHERE
		i.IssueID = @IssueID
		
END
*/
