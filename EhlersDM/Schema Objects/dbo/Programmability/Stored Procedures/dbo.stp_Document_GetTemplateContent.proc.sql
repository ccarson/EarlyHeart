/*
-- =============================================
-- Author:		Brian Larson
-- Create date: 6/23/2010
-- Description:	Retrieve the content of a 
--				Document Template.
-- =============================================
CREATE PROCEDURE [dbo].[stp_Document_GetTemplateContent]
	@TemplateID			int,
	@TemplateVersion	int = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @TemplateVersion IS NULL
	BEGIN
		SELECT
			TemplateContent
		FROM
			Documents.TemplateVersions
		WHERE
			TemplateID = @TemplateID
		AND
			CurrentVersion = 1
	END
	ELSE
	BEGIN
		SELECT
			TemplateContent
		FROM
			Documents.TemplateVersions
		WHERE
			TemplateID = @TemplateID
		AND
			Version = @TemplateVersion
	END
END
*/