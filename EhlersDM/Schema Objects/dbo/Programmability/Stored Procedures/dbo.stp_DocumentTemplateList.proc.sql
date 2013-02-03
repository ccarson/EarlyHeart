/*
-- =============================================
-- Author:		Brian Larson
-- Create date: 6/23/2010
-- Description: Get the list of defined document
--				templates for a selected document.
-- =============================================
CREATE PROCEDURE [dbo].[stp_DocumentTemplateList]
	@DocumentID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		t.TemplateID,
		ds.DocumentSectionName + ' - ' + t.TemplateName AS SectionTemplateName,
		ds.DocumentSectionName,
		t.OrderWithinSection
	FROM
		Documents.Templates t
	JOIN
		Documents.DocumentSections ds ON t.DocumentSectionID = ds.DocumentSectionID
	WHERE
		ds.DocumentID = @DocumentID
	
	UNION
	
	SELECT
		-1,
		'',
		'',
		1

	ORDER BY
		DocumentSectionName,
		OrderWithinSection
END
*/