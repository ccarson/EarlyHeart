/*
CREATE PROCEDURE [dbo].[stp_GetTemplatesForSection]
	@DocumentID				int,
	@DocumentSectionCode	varchar(50)
AS
BEGIN
-- =============================================
-- Author:		Brian Larson
-- Create date: 6/15/2010
-- Description:	Returns information on all of
--				the templates defined for a 
--				given document section.
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
		SectionStoredProcedure,
		Condition AS TemplateCondition,
		TemplateName,
		TemplateType,
		tv.TemplateContent,
		ds.DocumentSectionID
	FROM	
		Documents.DocumentSections ds
	JOIN
		Documents.Templates t ON ds.DocumentSectionID = t.DocumentSectionID
	JOIN
		Documents.TemplateVersions tv ON t.TemplateID = tv.TemplateID
										AND tv.CurrentVersion = 1
	WHERE
		ds.DocumentID = @DocumentID
	AND
		ds.DocumentSectionCode = @DocumentSectionCode
	ORDER BY
		OrderWithinSection
END
*/