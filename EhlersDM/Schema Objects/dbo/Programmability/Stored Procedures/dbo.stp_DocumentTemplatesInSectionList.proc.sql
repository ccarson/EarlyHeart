/*
CREATE PROCEDURE [dbo].[stp_DocumentTemplatesInSectionList]
	@DocumentSectionID int
AS
-- =============================================
-- Author:		Brian Larson
-- Create date: 1/28/2011
-- Description: Get the list of defined document
--				templates for a selected document
--				section.
-- =============================================
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT 
		t.TemplateID,
		t.TemplateName AS SectionTemplateName,
		t.OrderWithinSection,
		t.Condition
	FROM
		Documents.Templates t
	WHERE
		t.DocumentSectionID = @DocumentSectionID
	
	UNION
	
	SELECT
		-1,
		'',
		1,
		''

	ORDER BY
		OrderWithinSection
END
*/