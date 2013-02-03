/*
-- =============================================
-- Author:		Brian Larson
-- Create date: 5/19/2010
-- Description:	Extracts the data, including
--				document section text, for
--				the Pre-Sale Report document.
-- =============================================
CREATE PROCEDURE [dbo].[stp_WordDocument_PreSaleReport_Data] 
	@IssueID		int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Get the required data for this report and store it in
	-- the #Data temporary table.
	SELECT 
		--dbo.udf_DateFormatter(i.PresaleDate, 'Long') AS PresaleDate,
		dbo.udf_DateFormatter(CONVERT(datetime, '1/1/2020'), 'Long') AS PresaleDate, 
		dbo.udf_DateFormatter(CASE WHEN DATEPART(dw, i.SaleDate) = 2 THEN DATEADD(d, -7, i.SaleDate)
			ELSE DATEADD(d, -1*(DATEPART(dw, i.SaleDate)+5), i.SaleDate)
			END, 'Long') AS StatementDistribDate,
		dbo.udf_DateFormatter(i.SaleDate, 'Long') AS SaleDate,
		dbo.udf_DateFormatter(i.SettlementDate, 'Long') AS SettlementDate,
		i.IssueName,
		dbo.udf_CurrencyFormatter(i.IssueAmount,1,1) AS IssueAmount, 
		ISNULL(c.ClientPrefix + ' ' , '') + c.ClientName AS FormattedName,
		c.TypeJurisdiction,
		--c.ClientLogo,
		NULL AS ClientLogo,
		dbo.udf_DateFormatter((SELECT MIN(PaymentDate) FROM IssueMaturities ci2  WHERE ci2.IssueID = i.IssueID), 'Short') AS FirstMaturityDate,
		dbo.udf_DateFormatter((SELECT MAX(PaymentDate) FROM IssueMaturities ci2  WHERE ci2.IssueID = i.IssueID), 'Short') AS LastMaturityDate,
		'1/1/2012' AS CallDate,
		'1/1/2013' AS CallableMaturityDate,
		'FA Name' As FAName,
		'FA@ehlers-inc.com' AS FAEmail,
		'612-555-8948' AS FAPhone,
		'SA Name' As SAName,
		'SA@ehlers-inc.com' AS SAEmail,
		'612-555-9383' AS SAPhone,
		'BSC Name' As BSCName,
		'BSC@ehlers-inc.com' AS BSCEmail,
		'612-555-9203' AS BSCPhone,
		'$265,000.00 Glader Boulevard and Lakelawn Drive Improvement Bond' + CHAR(13) + '$65,000.00 2010 Refunding Bond' + CHAR(13) + '$360,000.00 Wilderness Park Land Purchase Bond' As ConstituentIssueEntry
	FROM 
		Issues AS i 
	INNER JOIN 
		Clients AS c ON i.ClientID = c.ClientID
	--LEFT OUTER JOIN
	--	Employees FA ON i.FA1 = FA.Initials
	--LEFT OUTER JOIN
	--	Employees Analyst ON i.Analyst = Analyst.Initials
	--LEFT OUTER JOIN
	--	Employees BSC ON i.BSC = BSC.Initials		
	WHERE
		i.IssueID = @IssueID
		
END
*/
