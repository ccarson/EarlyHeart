/*
-- =============================================
-- Author:		Brian Larson
-- Create date: 11/23/2010
-- Description: Get the list of database fields  
--				that can be used in merge documents.
-- =============================================
CREATE PROCEDURE [dbo].[stp_DocumentDatabaseFieldList]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT 
		DescriptiveName
	FROM
		Documents.DatabaseFields
	WHERE 
		AvailableForMerge = 1
	ORDER BY
		DescriptiveName
END
*/