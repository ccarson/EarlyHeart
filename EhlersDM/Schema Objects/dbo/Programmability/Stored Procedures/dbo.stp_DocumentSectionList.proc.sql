/*
CREATE PROCEDURE [dbo].[stp_DocumentSectionList] 
	@DocumentID int,
	@IncludeSwitch tinyint = 1
AS
BEGIN
-- =============================================
-- Author:		Brian Larson
-- Create date: 6/22/2010
-- Description: Get the list of defined document
--				sections for a selected document.
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		DocumentSectionID,
		DocumentSectionName,
		ISNULL(DocumentPath, '') AS DocumentPath
	FROM
		Documents.DocumentSections
	WHERE
		DocumentID = @DocumentID
	AND
		(@IncludeSwitch = 1
		OR
		(@IncludeSwitch = 0 AND DocumentPath IS NOT NULL)
		OR
		(@IncludeSwitch = 2 AND DocumentPath IS NULL))

	
	UNION
	
	SELECT
		-1,
		'',
		''

	ORDER BY
		DocumentSectionName
END
*/