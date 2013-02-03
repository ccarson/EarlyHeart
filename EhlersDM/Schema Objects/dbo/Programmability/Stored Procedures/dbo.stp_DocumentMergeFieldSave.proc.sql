/*
-- =============================================
-- Author:		Brian Larson
-- Create date: 6/22/2010
-- Description: Save a new merge field.
-- =============================================
CREATE PROCEDURE [dbo].[stp_DocumentMergeFieldSave]
	@FieldName				varchar(50),
	@DocumentSectionID		int,
	@StoreWithMainSection	bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @SectionIDToUse	int
	
	IF @StoreWithMainSection = 1
	BEGIN
		SELECT 
			@SectionIDToUse = mainSec.DocumentSectionID
		FROM
			Documents.DocumentSections curSec
		JOIN
			Documents.DocumentSections mainSec ON curSec.DocumentID = mainSec.DocumentID
												AND mainSec.DocumentSectionName = 'Main'
		WHERE
			curSec.DocumentSectionID = @DocumentSectionID
	END
	ELSE
	BEGIN
		SET @SectionIDToUse = @DocumentSectionID
	END
	
	
	INSERT INTO Documents.MergeFields (DocumentSectionID, FieldName,  FieldCode)
								VALUES(@SectionIDToUse,   @FieldName, REPLACE(@FieldName, ' ', ''))
END
*/