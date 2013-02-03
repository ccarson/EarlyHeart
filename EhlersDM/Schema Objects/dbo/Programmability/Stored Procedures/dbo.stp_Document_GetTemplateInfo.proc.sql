/*
-- =============================================
-- Author:		Brian Larson
-- Create date: 6/23/2010
-- Description:	Retrieve the information for a 
--				Document Template.
-- =============================================
CREATE PROCEDURE [dbo].[stp_Document_GetTemplateInfo]
	@TemplateID			int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
		TemplateName, 
		DocumentSectionID, 
		OrderWithinSection,
		Condition,
		ISNULL(ActiveVersion, 0) AS ActiveVersion,
		TemplateType
	FROM
		Documents.Templates
	WHERE
		TemplateID = @TemplateID
END
*/