/*
-- =============================================
-- Author:		Brian Larson
-- Create date: 6/6/2011
-- Description: Delete a merge field.
-- =============================================
CREATE PROCEDURE [dbo].[stp_DocumentMergeFieldDelete]
	@DocumentSectionID		int,
	@FieldCode				varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @FoundCount		int
	DECLARE @MainSectionID	int

	-- See if this FieldCode is present in the current document section.
	SELECT 
		@FoundCount = COUNT(*)
	FROM 
		Documents.MergeFields
	WHERE
		DocumentSectionID = @DocumentSectionID
	AND
		FieldCode = @FieldCode
		
	
	IF @FoundCount > 0
	BEGIN
		-- The field code was present in the current document section.
		-- Delete it from there.
		DELETE FROM Documents.MergeFields
		WHERE
			DocumentSectionID = @DocumentSectionID
		AND
			FieldCode = @FieldCode

	END
	ELSE
	BEGIN
		-- The field code was not present in the current document section.
		-- Delete it from the main section.
		SELECT 
			@MainSectionID = mainSec.DocumentSectionID
		FROM
			Documents.DocumentSections curSec
		JOIN
			Documents.DocumentSections mainSec ON curSec.DocumentID = mainSec.DocumentID
												AND mainSec.DocumentSectionName = 'Main'
		WHERE
			curSec.DocumentSectionID = @DocumentSectionID
			


		DELETE FROM Documents.MergeFields
		WHERE
			DocumentSectionID = @MainSectionID
		AND
			FieldCode = @FieldCode

	END
		
END
*/