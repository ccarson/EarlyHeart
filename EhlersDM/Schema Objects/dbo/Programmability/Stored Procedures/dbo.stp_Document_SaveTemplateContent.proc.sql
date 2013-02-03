/*
-- =============================================
-- Author:		Brian Larson
-- Create date: 6/8/2010
-- Description:	Store a byte array in the 
--				Templates table.
-- =============================================
CREATE PROCEDURE [dbo].[stp_Document_SaveTemplateContent] 
	@TemplateID	int,
	@Content	nvarchar(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Version int

	-- Find the max version number for this template.
	SELECT
		@Version = MAX(Version)
	FROM
		Documents.TemplateVersions
	WHERE
		TemplateID = @TemplateID

	IF @Version IS NULL
	BEGIN
		SET @Version = 0
	END

	-- Change the Current flag to indicate none of the existing versions
	-- is the current version of the Content.
	UPDATE
		Documents.TemplateVersions
	SET 
		CurrentVersion = 0
	WHERE
		TemplateID = @TemplateID


	SET @Version = @Version + 1

	-- Create a new template version record for this version.
	INSERT INTO Documents.TemplateVersions (TemplateID,  Version,  CurrentVersion, TemplateContent)
									VALUES (@TemplateID, @Version, 1,              @Content)

	-- Update the Templates table to reflect the current version.
	UPDATE
		Documents.Templates
	SET
		ActiveVersion = @Version
	WHERE
		TemplateID = @TemplateID

	-- Delete any versions that are not the current version and are more than 5 revisions old.
	DELETE FROM
		Documents.TemplateVersions
	WHERE
		TemplateID = @TemplateID
	AND
		Version < @Version-4
	AND
		CurrentVersion = 0

END
*/