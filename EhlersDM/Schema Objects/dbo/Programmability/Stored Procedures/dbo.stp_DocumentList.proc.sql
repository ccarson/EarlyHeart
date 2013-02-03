/*
CREATE PROCEDURE [dbo].[stp_DocumentList] 
AS
-- =============================================
-- Author:		Brian Larson
-- Create date: 6/8/2010
-- Description: Get the list of defined documents.
-- =============================================
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		DocumentID,
		DocumentName
	FROM
		Documents.Documents
	
	UNION
	
	SELECT
		-1,
		''
			
	ORDER BY
		DocumentName
END
*/